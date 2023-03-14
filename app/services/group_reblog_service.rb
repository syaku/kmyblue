# frozen_string_literal: true

class GroupReblogService < BaseService

  def call(status)
    visibility = status.visibility.to_sym
    return nil if visibility != :public && visibility != :public_unlisted && visibility != :unlisted

    accounts = status.mentions.map(&:account) | status.active_mentions.map(&:account)

    accounts.each do |account|
      next unless account.local?
      next if account.group_message_following_only && !account.following?(status.account)

      ReblogService.new.call(account, status, { visibility: status.visibility }) if account.group?
    end
  end
end
