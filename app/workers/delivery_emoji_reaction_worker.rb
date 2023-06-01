# frozen_string_literal: true

class DeliveryEmojiReactionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable
  include AccountScope

  def perform(payload_json, status_id, _my_account_id = nil)
    status = Status.find(status_id.to_i)

    if status.present?
      scope_status(status).includes(:user).find_each do |account|
        redis.publish("timeline:#{account.id}", payload_json) if (!account.respond_to?(:user) || !account.user&.setting_stop_emoji_reaction_streaming) && redis.exists?("subscribed:timeline:#{account.id}")
      end
    end

    true
  rescue ActiveRecord::RecordNotFound
    true
  end
end
