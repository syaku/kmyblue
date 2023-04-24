class AddDissubscribableToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :antennas, :with_media_only, :boolean, null: false, default: false, index: true
    add_column :accounts, :dissubscribable, :boolean, null: false, default: false
  end
end
