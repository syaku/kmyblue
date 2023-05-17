# frozen_string_literal: true

class AddRejectReplyExcludeFollowersToDomainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :domain_blocks, :reject_reply_exclude_followers, :boolean, null: false, default: false
    add_index :domain_blocks, :reject_reply_exclude_followers
  end
end
