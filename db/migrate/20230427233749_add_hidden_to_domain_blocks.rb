# frozen_string_literal: true

class AddHiddenToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    change_table :domain_blocks, bulk: true do |t|
      t.boolean :hidden, null: false, default: false
      t.boolean :hidden_anonymous, null: false, default: false
    end
  end

  def down
    change_table :domain_blocks, bulk: true do |t|
      t.remove :hidden
      t.remove :hidden_anonymous
    end
  end
end
