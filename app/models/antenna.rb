# == Schema Information
#
# Table name: antennas
#
#  id               :bigint(8)        not null, primary key
#  account_id       :bigint(8)        not null
#  list_id          :bigint(8)        not null
#  title            :string           default(""), not null
#  keywords         :jsonb
#  exclude_keywords :jsonb
#  any_domains      :boolean          default(TRUE), not null
#  any_tags         :boolean          default(TRUE), not null
#  any_accounts     :boolean          default(TRUE), not null
#  any_keywords     :boolean          default(TRUE), not null
#  available        :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  expires_at       :datetime
#
class Antenna < ApplicationRecord
  include Expireable

  has_many :antenna_domains, inverse_of: :antenna, dependent: :destroy
  has_many :antenna_tags, inverse_of: :antenna, dependent: :destroy
  has_many :antenna_accounts, inverse_of: :antenna, dependent: :destroy

  belongs_to :account
  belongs_to :list

  scope :all_keywords, -> { where(any_keywords: true) }
  scope :all_domains, -> { where(any_domains: true) }
  scope :all_accounts, -> { where(any_accounts: true) }
  scope :all_tags, -> { where(any_tags: true) }
  scope :availables, -> { where(available: true).where(Arel.sql('any_keywords = FALSE OR any_domains = FALSE OR any_accounts = FALSE OR any_tags = FALSE')) }

  def enabled?
    available && !expires? && !(any_keywords && any_domains && any_accounts && any_tags)
  end

  def expires_in
    return @expires_in if defined?(@expires_in)
    return nil if expires_at.nil?

    [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week].find { |expires_in| expires_in.from_now >= expires_at }
  end

  def expires?
    expires_at.present? && expires_at < Time.now.utc
  end

  def context
    context = []
    context << 'domain' if !any_domains
    context << 'tag' if !any_tags
    context << 'keyword' if !any_keywords
    context << 'account' if !any_accounts
    context
  end

  def list=(list_id)
    list_id = list_id.to_i if list_id.is_a?(String)
    if list_id.is_a?(Numeric)
      self[:list_id] = list_id
    else
      self[:list] = list_id
    end
  end

  def keywords_raw
    return '' if !keywords.present?

    keywords.join("\n")
  end

  def keywords_raw=(raw)
    keywords = raw.split(/\R/).filter { |r| r.present? }.uniq
    self[:keywords] = keywords
    self[:any_keywords] = !keywords.any? && !exclude_keywords&.any?
  end

  def exclude_keywords_raw
    return '' if !exclude_keywords.present?

    exclude_keywords.join("\n")
  end

  def exclude_keywords_raw=(raw)
    exclude_keywords = raw.split(/\R/).filter { |r| r.present? }.uniq
    self[:exclude_keywords] = exclude_keywords
    self[:any_keywords] = !keywords&.any? && !exclude_keywords.any?
  end

  def tags_raw
    antenna_tags.where(exclude: false).map(&:tag).map(&:name).join("\n")
  end

  def tags_raw=(raw)
    return if tags_raw == raw

    tag_names = raw.split(/\R/).filter { |r| r.present? }.map { |r| r.start_with?('#') ? r[1..-1] : r }.uniq

    antenna_tags.where(exclude: false).destroy_all
    Tag.find_or_create_by_names(tag_names).each do |tag|
      antenna_tags.create!(tag: tag, exclude: false)
    end
    self[:any_tags] = !tag_names.any?
  end

  def exclude_tags_raw
    antenna_tags.where(exclude: true).map(&:tag).map(&:name).join("\n")
  end

  def exclude_tags_raw=(raw)
    return if exclude_tags_raw == raw

    tag_names = raw.split(/\R/).filter { |r| r.present? }.map { |r| r.start_with?('#') ? r[1..-1] : r }.uniq

    antenna_tags.where(exclude: true).destroy_all
    Tag.find_or_create_by_names(tag_names).each do |tag|
      antenna_tags.create!(tag: tag, exclude: true)
    end
  end

  def domains_raw
    antenna_domains.where(exclude: false).map(&:name).join("\n")
  end

  def domains_raw=(raw)
    return if domains_raw == raw

    domain_names = raw.split(/\R/).filter { |r| r.present? }.uniq

    antenna_domains.where(exclude: false).destroy_all
    domain_names.each do |domain|
      antenna_domains.create!(name: domain, exclude: false)
    end
    self[:any_domains] = !domain_names.any?
  end
  
  def exclude_domains_raw
    antenna_domains.where(exclude: true).map(&:name).join("\n")
  end

  def exclude_domains_raw=(raw)
    return if exclude_domains_raw == raw

    domain_names = raw.split(/\R/).filter { |r| r.present? }.uniq

    antenna_domains.where(exclude: true).destroy_all
    domain_names.each do |domain|
      antenna_domains.create!(name: domain, exclude: true)
    end
  end

  def accounts_raw
    antenna_accounts.where(exclude: false).map(&:account).map { |account| account.domain ? "@#{account.username}@#{account.domain}" : "@#{account.username}" }.join("\n")
  end

  def accounts_raw=(raw)
    return if accounts_raw == raw

    account_names = raw.split(/\R/).filter { |r| r.present? }.map { |r| r.start_with?('@') ? r[1..-1] : r }.uniq

    hit = false
    antenna_accounts.where(exclude: false).destroy_all
    account_names.each do |name|
      username, domain = name.split('@')
      account = Account.find_by(username: username, domain: domain)
      if account.present?
        antenna_accounts.create!(account: account, exclude: false)
        hit = true
      end
    end
    self[:any_accounts] = !hit
  end

  def exclude_accounts_raw
    antenna_accounts.where(exclude: true).map(&:account).map { |account| account.domain ? "@#{account.username}@#{account.domain}" : "@#{account.username}" }.join("\n")
  end

  def exclude_accounts_raw=(raw)
    return if exclude_accounts_raw == raw

    account_names = raw.split(/\R/).filter { |r| r.present? }.map { |r| r.start_with?('@') ? r[1..-1] : r }.uniq

    hit = false
    antenna_accounts.where(exclude: true).destroy_all
    account_names.each do |name|
      username, domain = name.split('@')
      account = Account.find_by(username: username, domain: domain)
      if account.present?
        antenna_accounts.create!(account: account, exclude: true)
        hit = true
      end
    end
  end
  
end
