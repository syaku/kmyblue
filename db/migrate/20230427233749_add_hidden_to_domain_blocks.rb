class AddHiddenToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :domain_blocks, :hidden, :boolean, null: false, default: false
    add_column :domain_blocks, :hidden_anonymous, :boolean, null: false, default: false
  end
end
