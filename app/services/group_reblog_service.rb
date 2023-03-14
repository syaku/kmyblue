# frozen_string_literal: true

class GroupReblogService < BaseService
  include RoutingHelper

  ACTIVITYPUB_CONTINUOUS_SIZE = 30

  def call(status)
    visibility = status.visibility.to_sym
    return nil if !%i(public public_unlisted unlisted private direct).include?(visibility)

    accounts = status.mentions.map(&:account) | status.active_mentions.map(&:account)
    transcription = %i(private direct).include?(visibility)

    accounts.each do |account|
      next unless account.local?
      next unless status.account.following?(account)
      next unless account.group?
      next if account.id == status.account_id
      next if transcription && !account.group_allow_private_message

      if status.account.activitypub? && ACTIVITYPUB_CONTINUOUS_SIZE > 0
        next if account.group_activitypub_count >= ACTIVITYPUB_CONTINUOUS_SIZE
        account.group_activitypub_count = account.group_activitypub_count + 1
        account.save!
      else
        if account.group_activitypub_count > 0
          account.group_activitypub_count = 0
          account.save!
        end
      end

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

        text = status.account.local? ? status.text : strip_tags(status.text.gsub(/<br>/, "\n").gsub(/<br \/>/, "\n").gsub(/<\/p>/, "\n\n").strip)

        PostStatusService.new.call(
          account,
          text: "Private message by @#{username}\n\\-\\-\\-\\-\n#{text}",
          thread: status.thread,
          media_ids: media_attachments.map(&:id),
          sensitive: status.sensitive,
          spoiler_text: status.spoiler_text,
          visibility: :private,
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
