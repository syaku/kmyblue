class AddEmojiReactionsCountToStatusStats < ActiveRecord::Migration[6.1]
  def change
    add_column :status_stats, :emoji_reactions_count, :integer, null: false, default: 0
  end
end
