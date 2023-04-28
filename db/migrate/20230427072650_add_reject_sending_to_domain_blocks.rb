class AddRejectSendingToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :domain_blocks, :reject_send_not_public_searchability, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_send_unlisted_dissubscribable, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_send_public_unlisted, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_send_dissubscribable, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_send_media, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_send_sensitive, :boolean, null: false, default: false
  end
end
