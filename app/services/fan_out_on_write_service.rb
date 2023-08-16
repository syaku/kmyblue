# frozen_string_literal: true

class FanOutOnWriteService < BaseService
  include Redisable

  # Push a status into home and mentions feeds
  # @param [Status] status
  # @param [Hash] options
  # @option options [Boolean] update
  # @option options [Array<Integer>] silenced_account_ids
  def call(status, options = {})
    @status    = status
    @account   = status.account
    @options   = options

    check_race_condition!
    warm_payload_cache!

    fan_out_to_local_recipients!
    if broadcastable?
      fan_out_to_public_recipients!
      fan_out_to_public_streams!
    elsif broadcastable_unlisted?
      fan_out_to_public_recipients!
      fan_out_to_public_unlisted_streams!
    elsif broadcastable_unlisted2?
      fan_out_to_unlisted_streams!
    end
  end

  private

  def check_race_condition!
    # I don't know why but at some point we had an issue where
    # this service was being executed with status objects
    # that had a null visibility - which should not be possible
    # since the column in the database is not nullable.
    #
    # This check re-queues the service to be run at a later time
    # with the full object, if something like it occurs

    raise Mastodon::RaceConditionError if @status.visibility.nil?
  end

  def fan_out_to_local_recipients!
    deliver_to_self!
    notify_mentioned_accounts!
    notify_about_update! if update?

    case @status.visibility.to_sym
    when :public, :unlisted, :public_unlisted, :login, :private
      deliver_to_all_followers!
      deliver_to_lists!
      deliver_to_antennas! if [:public, :public_unlisted, :login].include?(@status.visibility.to_sym) && !@account.dissubscribable
      deliver_to_stl_antennas!
    when :limited
      deliver_to_lists_mentioned_accounts_only!
      deliver_to_mentioned_followers!
    else
      deliver_to_mentioned_followers!
      deliver_to_conversation!
    end
  end

  def fan_out_to_public_recipients!
    deliver_to_hashtag_followers!
  end

  def fan_out_to_public_streams!
    broadcast_to_hashtag_streams!
    broadcast_to_public_streams!
  end

  def fan_out_to_public_unlisted_streams!
    broadcast_to_hashtag_streams!
    broadcast_to_public_unlisted_streams!
  end

  def fan_out_to_unlisted_streams!
    broadcast_to_hashtag_streams!
  end

  def deliver_to_self!
    FeedManager.instance.push_to_home(@account, @status, update: update?) if @account.local?
  end

  def notify_mentioned_accounts!
    @status.active_mentions.where.not(id: @options[:silenced_account_ids] || []).joins(:account).merge(Account.local).select(:id, :account_id).reorder(nil).find_in_batches do |mentions|
      LocalNotificationWorker.push_bulk(mentions) do |mention|
        [mention.account_id, mention.id, 'Mention', 'mention']
      end
    end
  end

  def notify_about_update!
    @status.reblogged_by_accounts.merge(Account.local).select(:id).reorder(nil).find_in_batches do |accounts|
      LocalNotificationWorker.push_bulk(accounts) do |account|
        [account.id, @status.id, 'Status', 'update']
      end
    end
  end

  def deliver_to_all_followers!
    @account.followers_for_local_distribution.select(:id).reorder(nil).find_in_batches do |followers|
      FeedInsertWorker.push_bulk(followers) do |follower|
        [@status.id, follower.id, 'home', { 'update' => update? }]
      end
    end
  end

  def deliver_to_hashtag_followers!
    TagFollow.where(tag_id: @status.tags.map(&:id)).select(:id, :account_id).reorder(nil).find_in_batches do |follows|
      FeedInsertWorker.push_bulk(follows) do |follow|
        [@status.id, follow.account_id, 'tags', { 'update' => update? }]
      end
    end
  end

  def deliver_to_lists!
    @account.lists_for_local_distribution.select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [@status.id, list.id, 'list', { 'update' => update? }]
      end
    end
  end

  def deliver_to_lists_mentioned_accounts_only!
    mentioned_account_ids = @status.mentions.pluck(:account_id)
    @account.lists_for_local_distribution.where(account_id: mentioned_account_ids).select(:id).reorder(nil).find_in_batches do |lists|
      FeedInsertWorker.push_bulk(lists) do |list|
        [@status.id, list.id, 'list', { 'update' => update? }]
      end
    end
  end

  def deliver_to_stl_antennas!
    antennas = Antenna.available_stls
    antennas = antennas.where(account_id: Account.without_suspended.joins(:user).select('accounts.id').where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.ago))

    home_post = !@account.domain.nil? || @status.reblog? || [:public, :public_unlisted, :login].exclude?(@status.visibility.to_sym)
    antennas = antennas.where(account: @account.followers).or(antennas.where(account: @account)).where.not(list_id: 0) if home_post

    collection = AntennaCollection.new(@status, @options[:update], home_post)

    antennas.in_batches do |ans|
      ans.each do |antenna|
        next if antenna.expired?

        collection.push(antenna)
      end
    end

    collection.deliver!
  end

  def deliver_to_antennas!
    tag_ids = @status.tags.pluck(:id)
    domain = @account.domain || Rails.configuration.x.local_domain

    antennas = Antenna.availables
    antennas = antennas.left_joins(:antenna_domains).where(any_domains: true).or(Antenna.left_joins(:antenna_domains).where(antenna_domains: { name: domain }))
    antennas = antennas.where(with_media_only: false) unless @status.with_media?
    antennas = antennas.where(ignore_reblog: false) unless @status.reblog?
    antennas = antennas.where(stl: false)

    antennas = Antenna.where(id: antennas.select(:id))
    antennas = antennas.left_joins(:antenna_accounts).where(any_accounts: true).or(Antenna.left_joins(:antenna_accounts).where(antenna_accounts: { account: @account }))

    tag_ids = @status.tags.pluck(:id)
    antennas = Antenna.where(id: antennas.select(:id))
    antennas = antennas.left_joins(:antenna_tags).where(any_tags: true).or(Antenna.left_joins(:antenna_tags).where(antenna_tags: { tag_id: tag_ids }))

    antennas = antennas.where(account_id: Account.without_suspended.joins(:user).select('accounts.id').where('users.current_sign_in_at > ?', User::ACTIVE_DURATION.ago))

    collection = AntennaCollection.new(@status, @options[:update], false)

    antennas.in_batches do |ans|
      ans.each do |antenna|
        next unless antenna.enabled?
        next if antenna.keywords.any? && antenna.keywords.none? { |keyword| @status.text.include?(keyword) }
        next if antenna.exclude_keywords&.any? { |keyword| @status.text.include?(keyword) }
        next if antenna.exclude_accounts&.include?(@status.account_id)
        next if antenna.exclude_domains&.include?(domain)
        next if antenna.exclude_tags&.any? { |tag_id| tag_ids.include?(tag_id) }

        collection.push(antenna)
      end
    end

    collection.deliver!
  end

  def deliver_to_mentioned_followers!
    @status.mentions.joins(:account).merge(@account.followers_for_local_distribution).select(:id, :account_id).reorder(nil).find_in_batches do |mentions|
      FeedInsertWorker.push_bulk(mentions) do |mention|
        [@status.id, mention.account_id, 'home', { 'update' => update? }]
      end
    end
  end

  def broadcast_to_hashtag_streams!
    @status.tags.map(&:name).each do |hashtag|
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}", anonymous_payload)
      redis.publish("timeline:hashtag:#{hashtag.mb_chars.downcase}:local", anonymous_payload) if @status.local?
    end
  end

  def broadcast_to_public_streams!
    return if @status.reply? && @status.in_reply_to_account_id != @account.id

    redis.publish('timeline:public', anonymous_payload)
    redis.publish(@status.local? ? 'timeline:public:local' : 'timeline:public:remote', anonymous_payload)

    if @status.with_media?
      redis.publish('timeline:public:media', anonymous_payload)
      redis.publish(@status.local? ? 'timeline:public:local:media' : 'timeline:public:remote:media', anonymous_payload)
    end
  end

  def broadcast_to_public_unlisted_streams!
    return if @status.reply? && @status.in_reply_to_account_id != @account.id

    redis.publish(@status.local? ? 'timeline:public:local' : 'timeline:public:remote', anonymous_payload)

    if @status.with_media?
      redis.publish(@status.local? ? 'timeline:public:local:media' : 'timeline:public:remote:media', anonymous_payload)
    end
  end

  def deliver_to_conversation!
    AccountConversation.add_status(@account, @status) unless update?
  end

  def warm_payload_cache!
    Rails.cache.write("fan-out/#{@status.id}", rendered_status)
  end

  def anonymous_payload
    @anonymous_payload ||= Oj.dump(
      event: update? ? :'status.update' : :update,
      payload: rendered_status
    )
  end

  def rendered_status
    @rendered_status ||= InlineRenderer.render(@status, nil, :status)
  end

  def update?
    @options[:update]
  end

  def broadcastable?
    (@status.public_visibility? || @status.login_visibility?) && !@status.reblog? && !@account.silenced?
  end

  def broadcastable_unlisted?
    @status.public_unlisted_visibility? && !@status.reblog? && !@account.silenced?
  end

  def broadcastable_unlisted2?
    @status.unlisted_visibility? && @status.public_searchability? && !@status.reblog? && !@account.silenced?
  end

  class AntennaCollection
    def initialize(status, update, stl_home = false) # rubocop:disable Style/OptionalBooleanParameter
      @status = status
      @update = update
      @stl_home = stl_home
      @home_account_ids = []
      @list_ids = []
    end

    def push(antenna)
      if antenna.list_id.zero?
        @home_account_ids << antenna.account_id
      else
        @list_ids << antenna.list_id
      end
    end

    def deliver!
      lists = @list_ids.uniq
      homes = @home_account_ids.uniq

      if lists.any?
        FeedInsertWorker.push_bulk(lists) do |list|
          [@status.id, list, 'list', { 'update' => @update, 'stl_home' => @stl_home || false }]
        end
      end

      if homes.any?
        FeedInsertWorker.push_bulk(homes) do |home|
          [@status.id, home, 'home', { 'update' => @update }]
        end
      end
    end
  end
end
