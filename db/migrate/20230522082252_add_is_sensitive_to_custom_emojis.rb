# frozen_string_literal: true

class AddIsSensitiveToCustomEmojis < ActiveRecord::Migration[6.1]
  def change
    add_column :custom_emojis, :is_sensitive, :boolean, null: false, default: false
  end
end
