class AddSomeToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :domain_blocks, :reject_hashtag, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_straight_follow, :boolean, null: false, default: false
    add_column :domain_blocks, :reject_new_follow, :boolean, null: false, default: false
  end
end
