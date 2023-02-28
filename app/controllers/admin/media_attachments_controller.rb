# frozen_string_literal: true

module Admin
  class MediaAttachmentsController < BaseController
    def index
      authorize :account, :index?

      @media_attachments = filtered_attachments.page(params[:page])
      @form              = Form::MediaAttachmentsBatch.new
    end

    private

    def filtered_attachments
      MediaAttachment.recently_attachments
    end
  end
end
