class AddRejectFavouriteToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :domain_blocks, :reject_favourite, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_reply, :boolean, null: false, default: false
  end
end
