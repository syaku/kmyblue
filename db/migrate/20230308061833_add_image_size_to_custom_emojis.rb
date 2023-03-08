class AddImageSizeToCustomEmojis < ActiveRecord::Migration[6.1]
  def change
    add_column :custom_emojis, :image_width, :integer
    add_column :custom_emojis, :image_height, :integer
  end
end
