# frozen_string_literal: true

Fabricator(:circle_status) do
  circle { Fabricate.build(:circle) }
  status { Fabricate.build(:status) }
end
