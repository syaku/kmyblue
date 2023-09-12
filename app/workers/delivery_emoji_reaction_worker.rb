# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountScope

  def perform(payload_json, status_id, reacted_account_id)
    status = Status.find(status_id)
    reacted_account = Account.find(reacted_account_id)

    if status.present?
      scope = scope_status(status)

      policy = status.account.emoji_reaction_policy
      return if policy == :block_and_hide

      scope.includes(:user).find_each do |account|
        next if account.user.present? && (account.user.setting_stop_emoji_reaction_streaming || !account.user.setting_enable_emoji_reaction)
        next unless redis.exists?("subscribed:timeline:#{account.id}")
        next if account.excluded_from_timeline_domains.include?(reacted_account.domain)
        next if policy != :allow && !status.account.show_emoji_reaction?(account)

        redis.publish("timeline:#{account.id}", payload_json)
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
