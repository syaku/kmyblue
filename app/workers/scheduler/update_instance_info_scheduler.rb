# frozen_string_literal: true

class Scheduler::UpdateInstanceInfoScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 1

  def perform
    Instance.select(:domain).reorder(nil).find_in_batches do |instances|
      FetchInstanceInfoWorker.push_bulk(instances) do |instance|
        [instance.domain]
      end
    end
  end
end
