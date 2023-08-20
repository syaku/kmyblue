# frozen_string_literal: true

# == Schema Information
#
# Table name: antenna_accounts
#
#  id         :bigint(8)        not null, primary key
#  antenna_id :bigint(8)        not null
#  account_id :bigint(8)        not null
#  exclude    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AntennaAccount < ApplicationRecord
  belongs_to :antenna
  belongs_to :account

  validate :duplicate_account
  validate :limit_per_antenna

  private

  def duplicate_account
    raise Mastodon::ValidationError, I18n.t('antennas.errors.duplicate_account') if AntennaAccount.exists?(antenna_id: antenna_id, account_id: account_id, exclude: exclude)
  end

  def limit_per_antenna
    raise Mastodon::ValidationError, I18n.t('antennas.errors.limit.accounts') if AntennaAccount.where(antenna_id: antenna_id).count >= Antenna::ACCOUNTS_PER_ANTENNA_LIMIT
  end
end
