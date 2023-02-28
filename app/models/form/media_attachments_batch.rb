# frozen_string_literal: true

class Form::MediaAttachmentsBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern
  include Payloadable

  attr_accessor :query

  def save
  end
end
