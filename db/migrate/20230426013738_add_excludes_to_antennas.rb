class AddExcludesToAntennas < ActiveRecord::Migration[6.1]
  def change
    add_column :antennas, :exclude_domains, :jsonb
    add_column :antennas, :exclude_accounts, :jsonb
    add_column :antennas, :exclude_tags, :jsonb
  end
end
