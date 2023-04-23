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

end
