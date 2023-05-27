# frozen_string_literal: true

class EmojiReactionValidator < ActiveModel::Validator
  SUPPORTED_EMOJIS = Oj.load_file(Rails.root.join('app', 'javascript', 'mastodon', 'features', 'emoji', 'emoji_map.json').to_s).keys.freeze

  def validate(emoji_reaction)
    return if emoji_reaction.name.blank?

    emoji_reaction.errors.add(:name, I18n.t('reactions.errors.unrecognized_emoji')) if emoji_reaction.custom_emoji_id.blank? && !unicode_emoji?(emoji_reaction.name)
  end

  private

  def unicode_emoji?(name)
    SUPPORTED_EMOJIS.include?(name)
  end
end
