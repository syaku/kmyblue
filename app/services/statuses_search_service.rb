# frozen_string_literal: true

class StatusesSearchService < BaseService
  def call(query, account = nil, options = {})
    @query   = query&.strip
    @account = account
    @options = options
    @limit   = options[:limit].to_i
    @offset  = options[:offset].to_i
    @searchability = options[:searchability]&.to_sym

    status_search_results
  end

  private

  def status_search_results
    request             = parsed_query.request
    results             = request.collapse(field: :id).order(id: { order: :desc }).limit(@limit).offset(@offset).objects.compact
    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def following_account_ids
    return @following_account_ids if defined?(@following_account_ids)

    account_exists_sql     = Account.where('accounts.id = follows.target_account_id').where(searchability: %w(public private)).reorder(nil).select(1).to_sql
    status_exists_sql      = Status.where('statuses.account_id = follows.target_account_id').where(reblog_of_id: nil).where(searchability: %w(public private)).reorder(nil).select(1).to_sql
    following_accounts     = Follow.where(account_id: @account.id).merge(Account.where("EXISTS (#{account_exists_sql})").or(Account.where("EXISTS (#{status_exists_sql})")))
    @following_account_ids = following_accounts.pluck(:target_account_id)
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query), current_account: @account, searchability: @searchability)
  end
end
