# frozen_string_literal: true

# == Schema Information
#
# Table name: antenna_tags
#
#  id         :bigint(8)        not null, primary key
#  antenna_id :bigint(8)        not null
#  tag_id     :bigint(8)        not null
#  exclude    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AntennaTag < ApplicationRecord
  belongs_to :antenna
  belongs_to :tag

  validate :duplicate_tag
  validate :limit_per_antenna

  private

  def duplicate_tag
    raise Mastodon::ValidationError, I18n.t('antennas.errors.duplicate_tag') if AntennaTag.exists?(antenna_id: antenna_id, tag_id: tag_id, exclude: exclude)
  end

  def limit_per_antenna
    raise Mastodon::ValidationError, I18n.t('antennas.errors.limit.tags') if AntennaTag.where(antenna_id: antenna_id).count >= Antenna::TAGS_PER_ANTENNA_LIMIT
  end
end
