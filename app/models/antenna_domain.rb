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

end
