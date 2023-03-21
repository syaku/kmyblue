# frozen_string_literal: true

class UpdateStatusExpirationService < BaseService
  SCAN_EXPIRATION_RE = /#exp((\d.\d|\d)+)([dms]+)/

  def call(status)
    existing_expiration = ScheduledExpirationStatus.find_by(status: status)
    existing_expiration.destroy! if existing_expiration

    expiration = status.text.scan(SCAN_EXPIRATION_RE).first
    return if !expiration

    expiration_num = expiration[0].to_f
    expiration_option = expiration[1]

    expired_at = Time.now.utc + (expiration_option == 'd' ? expiration_num.days : expiration_option == 's' ? expiration_num.seconds : expiration_num.minutes)
    ScheduledExpirationStatus.create!(account: status.account, status: status, scheduled_at: expired_at)
  end
end
