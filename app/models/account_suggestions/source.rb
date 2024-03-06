# frozen_string_literal: true

# Reverted this commit.temporarily because load issues.
# Whenever a manual merge occurs, be sure to check the following commits.
# Hash: ee8d0b94473df357677cd1f82581251ce0423c01
# Message: Fix follow suggestions potentially including silenced or blocked accounts (#29306)

class AccountSuggestions::Source
  DEFAULT_LIMIT = 10

  def get(_account, **kwargs)
    raise NotImplementedError
  end

  protected

  def base_account_scope(account)
    Account
      .searchable
      .where.not(follows_sql, id: account.id)
      .where.not(follow_requests_sql, id: account.id)
      .not_excluded_by_account(account)
      .not_domain_blocked_by_account(account)
      .where.not(id: account.id)
      .where.not(follow_recommendation_mutes_sql, id: account.id)
  end

  def follows_sql
    <<~SQL.squish
      EXISTS (SELECT 1 FROM follows WHERE follows.target_account_id = accounts.id AND follows.account_id = :id)
    SQL
  end

  def follow_requests_sql
    <<~SQL.squish
      EXISTS (SELECT 1 FROM follow_requests WHERE follow_requests.target_account_id = accounts.id AND follow_requests.account_id = :id)
    SQL
  end

  def follow_recommendation_mutes_sql
    <<~SQL.squish
      EXISTS (SELECT 1 FROM follow_recommendation_mutes WHERE follow_recommendation_mutes.target_account_id = accounts.id AND follow_recommendation_mutes.account_id = :id)
    SQL
  end
end
