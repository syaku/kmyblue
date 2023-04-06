class AddSearchabilityToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :searchability, :integer, null: false, default: 3
  end
end
