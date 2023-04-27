# frozen_string_literal: true

class REST::Admin::DomainBlockSerializer < ActiveModel::Serializer
  attributes :id, :domain, :created_at, :severity,
             :reject_media, :reject_favourite, :reject_reply, :reject_reports,
             :reject_send_not_public_searchability, :reject_send_unlisted_dissubscribable,
             :reject_send_public_unlisted, :reject_send_dissubscribable, :reject_send_media, :reject_send_sensitive, 
             :private_comment, :public_comment, :obfuscate

  def id
    object.id.to_s
  end
end
