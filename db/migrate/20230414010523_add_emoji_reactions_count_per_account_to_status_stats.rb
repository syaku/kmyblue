class AddEmojiReactionsCountPerAccountToStatusStats < ActiveRecord::Migration[6.1]
  def change
    add_column :status_stats, :emoji_reaction_accounts_count, :integer, null: false, default: 0
  end
end
