# frozen_string_literal: true

class AddMarkdownToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :markdown, :boolean, default: false
  end
end
