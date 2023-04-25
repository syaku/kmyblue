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

  validates :account_id, uniqueness: { scope: :antenna_id }

end
