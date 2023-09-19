# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::NoteSerializer do
  subject { JSON.parse(@serialization.to_json) }

  let!(:account) { Fabricate(:account) }
  let!(:other) { Fabricate(:account) }
  let!(:parent) { Fabricate(:status, account: account, visibility: :public) }
  let!(:reply_by_account_first) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_account_next) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_other_first) { Fabricate(:status, account: other, thread: parent, visibility: :public) }
  let!(:reply_by_account_third) { Fabricate(:status, account: account, thread: parent, visibility: :public) }
  let!(:reply_by_account_visibility_direct) { Fabricate(:status, account: account, thread: parent, visibility: :direct) }
  let!(:referred) { nil }
  let(:convert_to_quote) { false }

  before(:each) do
    parent.references << referred if referred.present?
    account.user&.settings&.[]=('single_ref_to_quote', true) if convert_to_quote
    @serialization = ActiveModelSerializers::SerializableResource.new(parent, serializer: described_class, adapter: ActivityPub::Adapter)
  end

  it 'has a Note type' do
    expect(subject['type']).to eql('Note')
  end

  it 'has a replies collection' do
    expect(subject['replies']['type']).to eql('Collection')
  end

  it 'has a replies collection with a first Page' do
    expect(subject['replies']['first']['type']).to eql('CollectionPage')
  end

  it 'includes public self-replies in its replies collection' do
    expect(subject['replies']['first']['items']).to include(reply_by_account_first.uri, reply_by_account_next.uri, reply_by_account_third.uri)
  end

  it 'does not include replies from others in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(reply_by_other_first.uri)
  end

  it 'does not include replies with direct visibility in its replies collection' do
    expect(subject['replies']['first']['items']).to_not include(reply_by_account_visibility_direct.uri)
  end

  context 'when has quote but no_convert setting' do
    let(:referred) { Fabricate(:status) }

    it 'has as reference' do
      expect(subject['quoteUri']).to be_nil
    end
  end

  context 'when has quote and convert setting' do
    let(:referred) { Fabricate(:status) }
    let(:convert_to_quote) { true }

    it 'has as quote' do
      expect(subject['quoteUri']).to_not be_nil
      expect(subject['_misskey_quote'] == subject['quoteUri']).to be true
    end
  end
end
