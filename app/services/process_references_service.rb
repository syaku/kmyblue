# frozen_string_literal: true

class ProcessReferencesService < BaseService
  include Payloadable
  include FormattingHelper

  DOMAIN = ENV['WEB_DOMAIN'] || ENV.fetch('LOCAL_DOMAIN', nil)
  REFURL_EXP = /(RT|QT|BT|RN|RE)((:|;)?\s+|:|;)(#{URI::DEFAULT_PARSER.make_regexp(%w(http https))})/
  MAX_REFERENCES = 5

  def call(status, reference_parameters, urls: nil)
    @status = status
    @reference_parameters = reference_parameters || []
    @urls = urls || []

    @references_count = old_references.size

    return unless added_references.size.positive? || removed_references.size.positive?

    StatusReference.transaction do
      remove_old_references
      add_references

      @status.save!
    end

    Rails.cache.delete("status_reference:#{@status.id}")

    create_notifications!
  end

  def self.need_process?(status, reference_parameters, urls)
    reference_parameters.any? || (urls || []).any? || FormattingHelper.extract_status_plain_text(status).scan(REFURL_EXP).pluck(3).uniq.any?
  end

  def self.perform_worker_async(status, reference_parameters, urls)
    return unless need_process?(status, reference_parameters, urls)

    Rails.cache.write("status_reference:#{status.id}", true, expires_in: 10.minutes)
    ProcessReferencesWorker.perform_async(status.id, reference_parameters, urls)
  end

  private

  def references
    @references = @reference_parameters + scan_text!
  end

  def old_references
    @old_references = @status.references.pluck(:id)
  end

  def added_references
    (references - old_references).uniq
  end

  def removed_references
    (old_references - references).uniq
  end

  def scan_text!
    text = @status.account.local? ? @status.text : @status.text.gsub(%r{</?[^>]*>}, '')
    @scan_text = fetch_statuses!(text.scan(REFURL_EXP).pluck(3).uniq).map(&:id).uniq.filter { |status_id| !status_id.zero? }
  end

  def fetch_statuses!(urls)
    (urls + @urls)
      .map { |url| ResolveURLService.new.call(url) }
      .filter { |status| status }
  end

  def add_references
    return if added_references.empty?

    @added_objects = []

    statuses = Status.where(id: added_references)
    statuses.each do |status|
      @added_objects << @status.reference_objects.new(target_status: status)
      status.increment_count!(:status_referred_by_count)
      @references_count += 1

      break if @references_count >= MAX_REFERENCES
    end
  end

  def create_notifications!
    return if @added_objects.blank?

    local_reference_objects = @added_objects.filter { |ref| ref.target_status.account.local? }
    return if local_reference_objects.empty?

    LocalNotificationWorker.push_bulk(local_reference_objects) do |ref|
      [ref.target_status.account_id, ref.id, 'StatusReference', 'status_reference']
    end
  end

  def remove_old_references
    return if removed_references.empty?

    statuses = Status.where(id: removed_references)

    @status.reference_objects.where(target_status: statuses).destroy_all
    statuses.each do |status|
      status.decrement_count!(:status_referred_by_count)
      @references_count -= 1
    end
  end
end
