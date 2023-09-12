# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountScope

  def perform(payload_json, emoji_reaction_id, _status_id, _my_account_id = nil)
    emoji_reaction = EmojiReaction.find(emoji_reaction_id)
    status = emoji_reaction&.status

    if status.present?
      return if status.account.excluded_from_timeline_domains.include?(emoji_reaction.account.domain)

      scope = scope_status(status)

      policy = status.account.emoji_reaction_policy
      return if policy == :block_and_hide

      scope = scope.merge(policy_scope(status.account)) unless policy == :allow

      scope.includes(:user).find_each do |account|
        next unless (account.user.nil? || (!account.user&.setting_stop_emoji_reaction_streaming && !account.user&.setting_enable_emoji_reaction)) && redis.exists?("subscribed:timeline:#{account.id}")
        next if account.excluded_from_timeline_domains.include?(emoji_reaction.account.domain)

        redis.publish("timeline:#{account.id}", payload_json)
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end

  def policy_scope(account)
    case account.emoji_reaction_policy
    when :blocked, :block_and_hide
      nil
    when :followees_only
      account.following
    when :followers_only
      account.followers
    when :mutuals_only
      account.mutuals
    when :outside_only
      Account.where(id: account.following.pluck(:id) + account.followers.pluck(:id))
    else
      Account
    end
  end
end
