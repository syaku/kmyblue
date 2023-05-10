# frozen_string_literal: true

class AddEmojiReactionStreamingToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :stop_emoji_reaction_streaming, :boolean, default: false
  end
end
