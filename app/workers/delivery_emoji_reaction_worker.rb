# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountScope

  def perform(payload_json, emoji_reaction_id, status_id, _my_account_id = nil)
    emoji_reaction = emoji_reaction_id ? EmojiReaction.find(emoji_reaction_id) : nil
    status = Status.find(status_id)

    if status.present?
      scope = scope_status(status)

      policy = status.account.emoji_reaction_policy
      return if policy == :block_and_hide

      scope.includes(:user).find_each do |account|
        next if account.user.present? && (account.user.setting_stop_emoji_reaction_streaming || !account.user.setting_enable_emoji_reaction)
        next unless redis.exists?("subscribed:timeline:#{account.id}")
        next if emoji_reaction.present? && account.excluded_from_timeline_domains.include?(emoji_reaction.account.domain)
        next if policy != :allow && !status.account.show_emoji_reaction?(account)

        redis.publish("timeline:#{account.id}", payload_json)
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
