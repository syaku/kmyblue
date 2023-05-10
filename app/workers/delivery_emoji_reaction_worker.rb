# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountLimitable

  def perform(payload_json, status_id, my_account_id = nil)
    redis.publish("timeline:#{my_account_id}", payload_json) if my_account_id.present?

    status = Status.find(status_id.to_i)

    if status.present?
      scope_status(status).includes(:user).find_each do |account|
        redis.publish("timeline:#{account.id}", payload_json) if !account.user&.setting_stop_emoji_reaction_streaming && redis.exists?("subscribed:timeline:#{account.id}")
      end

      if [:public, :unlisted, :public_unlisted].exclude?(status.visibility.to_sym) && status.account_id != my_account_id &&
         redis.exists?("subscribed:timeline:#{status.account_id}")
        redis.publish("timeline:#{status.account_id}", payload_json)
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
