# frozen_string_literal: true

class Scheduler::SidekiqHealthScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform
    url = ENV.fetch('SIDEKIQ_HEALTH_FETCH_URL', nil)
    Request.new(:head, url).perform if url.present?
  end
end
