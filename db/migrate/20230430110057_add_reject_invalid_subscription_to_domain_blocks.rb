class AddRejectInvalidSubscriptionToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :domain_blocks, :reject_send_unlisted_dissubscribable, :boolean, null: false, default: false
    end
    add_column :domain_blocks, :detect_invalid_subscription, :boolean, null: false, default: false
  end
end
