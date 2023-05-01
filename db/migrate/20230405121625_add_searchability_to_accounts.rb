# frozen_string_literal: true

class AddSearchabilityToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :searchability, :integer, null: false, default: 0
  end
end
