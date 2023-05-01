# frozen_string_literal: true

class AddImageSizeToCustomEmojis < ActiveRecord::Migration[6.1]
  def change
    change_table :custom_emojis, bulk: true do |t|
      t.integer :image_width
      t.integer :image_height
    end
  end

  def down
    change_table :custom_emojis, bulk: true do |t|
      t.remove :image_width
      t.remove :image_height
    end
  end
end
