class AddMinEmojisToAccountStatusesCleanupPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :account_statuses_cleanup_policies, :min_emojis, :integer
    add_column :account_statuses_cleanup_policies, :keep_self_emoji, :boolean, default: true, null: false
  end
end
