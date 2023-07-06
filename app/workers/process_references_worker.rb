# frozen_string_literal: true

class ProcessReferencesWorker
  include Sidekiq::Worker

  def perform(status_id, ids, urls: nil)
    ProcessReferencesService.new.call(Status.find(status_id), ids || [], urls: urls)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
