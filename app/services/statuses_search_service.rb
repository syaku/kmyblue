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
    definition_should = [
      publicly_searchable,
      non_publicly_searchable,
      searchability_limited,
    ]
    definition_should << searchability_public if %i(public).include?(@searchability)
    definition_should << searchability_private if %i(public private).include?(@searchability)

    definition = parsed_query.apply(
      Chewy::Search::Request.new(StatusesIndex, PublicStatusesIndex).filter(
        bool: {
          should: definition_should,
          minimum_should_match: 1,
        }
      )
    )

    results             = definition.collapse(field: :id).order(id: { order: :desc }).limit(@limit).offset(@offset).objects.compact
    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  rescue Faraday::ConnectionFailed, Parslet::ParseFailed
    []
  end

  def publicly_searchable
    {
      term: { _index: PublicStatusesIndex.index_name },
    }
  end

  def non_publicly_searchable
    {
      bool: {
        must: [
          {
            term: { _index: StatusesIndex.index_name },
          },
          {
            exists: {
              field: 'searchability',
            },
          },
          {
            term: { searchable_by: @account.id },
          },
        ],
        must_not: [
          {
            term: { searchability: 'limited' },
          },
        ],
      },
    }
  end

  def searchability_public
    {
      bool: {
        must: [
          {
            exists: {
              field: 'searchability',
            },
          },
          {
            term: { searchability: 'public' },
          },
        ],
      },
    }
  end

  def searchability_private
    {
      bool: {
        must: [
          {
            exists: {
              field: 'searchability',
            },
          },
          {
            term: { searchability: 'private' },
          },
          {
            terms: { account_id: following_account_ids },
          },
        ],
      },
    }
  end

  def searchability_limited
    {
      bool: {
        must: [
          {
            exists: {
              field: 'searchability',
            },
          },
          {
            term: { searchability: 'limited' },
          },
          {
            term: { account_id: @account.id },
          },
        ],
      },
    }
  end

  def following_account_ids
    return @following_account_ids if defined?(@following_account_ids)

    account_exists_sql     = Account.where('accounts.id = follows.target_account_id').where(searchability: %w(public private)).reorder(nil).select(1).to_sql
    status_exists_sql      = Status.where('statuses.account_id = follows.target_account_id').where(reblog_of_id: nil).where(searchability: %w(public private)).reorder(nil).select(1).to_sql
    following_accounts     = Follow.where(account_id: @account.id).merge(Account.where("EXISTS (#{account_exists_sql})").or(Account.where("EXISTS (#{status_exists_sql})")))
    @following_account_ids = following_accounts.pluck(:target_account_id)
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query))
  end
end
