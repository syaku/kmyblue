# frozen_string_literal: true

# == Schema Information
#
# Table name: antenna_domains
#
#  id         :bigint(8)        not null, primary key
#  antenna_id :bigint(8)        not null
#  name       :string
#  exclude    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AntennaDomain < ApplicationRecord
  belongs_to :antenna

  validate :same_domain

  def same_domain
    raise Mastodon::ValidationError, I18n.t('antennas.errors.same_domain') if AntennaDomain.exists?(antenna_id: antenna_id, name: name, exclude: exclude)
  end
end
