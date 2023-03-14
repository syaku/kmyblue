# frozen_string_literal: true

class GroupReblogService < BaseService
  include RoutingHelper

  def call(status)
    visibility = status.visibility.to_sym
    return nil if !%i(public public_unlisted unlisted private).include?(visibility)

    accounts = status.mentions.map(&:account) | status.active_mentions.map(&:account)
    transcription = visibility == :private

    accounts.each do |account|
      next unless account.local?
      next if account.group_message_following_only && !account.following?(status.account)
      next unless account.group?
      next if account.id == status.account_id

      ReblogService.new.call(account, status, { visibility: status.visibility }) if !transcription

      if transcription
        username = status.account.local? ? status.account.username : "#{status.account.username}@#{status.account.domain}"

        media_attachments = status.media_attachments.map do |media|
          url = media.needs_redownload? ? media_proxy_url(media.id, :original) : full_asset_url(media.file.url(:original))
          MediaAttachment.create(
            account: account,
            remote_url: media_url(media),
            thumbnail_remote_url: media_preview_url(media),
          ).tap do |attachment|
            attachment.download_file!
            attachment.save
          end
        end

        PostStatusService.new.call(
          account,
          text: "Private message by @#{username}\n\\-\\-\\-\\-\n#{status.text}",
          thread: status.thread,
          media_ids: media_attachments.map(&:id),
          sensitive: status.sensitive,
          spoiler_text: status.spoiler_text,
          visibility: status.visibility,
          language: status.language,
          poll: status.poll,
          with_rate_limit: true
        )
      end
    end
  end

  def media_url(media)
    if media.not_processed?
      nil
    elsif media.needs_redownload?
      media_proxy_url(media.id, :original)
    else
      full_asset_url(media.file.url(:original))
    end
  end

  def media_preview_url(media)
    if media.needs_redownload?
      media_proxy_url(media.id, :small)
    elsif media.thumbnail.present?
      full_asset_url(media.thumbnail.url(:original))
    elsif media.file.styles.key?(:small)
      full_asset_url(media.file.url(:small))
    end
  end
end
