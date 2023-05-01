# frozen_string_literal: true

class ActivityPub::DistributionWorker < ActivityPub::RawDistributionWorker
  # Distribute a new status or an edit of a status to all the places
  # where the status is supposed to go or where it was interacted with
  def perform(status_id)
    @status  = Status.find(status_id)
    @account = @status.account

    distribute!
  rescue ActiveRecord::RecordNotFound
    true
  end

  protected

  def inboxes
    @inboxes ||= status_reach_finder.inboxes
  end

  def inboxes_for_misskey
    @inboxes_for_misskey ||= status_reach_finder.inboxes_for_misskey
  end

  def status_reach_finder
    @status_reach_finder ||= StatusReachFinder.new(@status)
  end

  def payload
    @payload ||= Oj.dump(serialize_payload(activity, ActivityPub::ActivitySerializer, signer: @account))
  end

  def payload_for_misskey
    @payload ||= Oj.dump(serialize_payload(activity, ActivityPub::ActivityForMisskeySerializer, signer: @account))
  end

  def activity
    ActivityPub::ActivityPresenter.from_status(@status)
  end

  def options
    { 'synchronize_followers' => @status.private_visibility? }
  end
end
