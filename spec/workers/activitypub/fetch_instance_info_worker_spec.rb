# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::FetchInstanceInfoWorker do
  subject { described_class.new }

  let(:wellknown_nodeinfo) do
    {
      links: [
        {
          rel: 'http://nodeinfo.diaspora.software/ns/schema/2.0',
          href: 'https://example.com/nodeinfo/2.0',
        },
      ],
    }
  end

  let(:nodeinfo) do
    {
      version: '2.0',
      software: {
        name: 'mastodon',
        version: '4.2.0-beta1',
      },
      protocols: ['activitypub'],
    }
  end

  let(:wellknown_nodeinfo_json) { Oj.dump(wellknown_nodeinfo) }
  let(:nodeinfo_json) { Oj.dump(nodeinfo) }

  context 'when success' do
    before do
      stub_request(:get, 'https://example.com/.well-known/nodeinfo').to_return(status: 200, body: wellknown_nodeinfo_json)
      stub_request(:get, 'https://example.com/nodeinfo/2.0').to_return(status: 200, body: nodeinfo_json)
      Fabricate(:account, domain: 'example.com')
      Instance.refresh
    end

    it 'performs a mastodon instance' do
      subject.perform('example.com')

      info = InstanceInfo.find_by(domain: 'example.com')
      expect(info).to_not be_nil
      expect(info.software).to eq 'mastodon'
      expect(info.version).to eq '4.2.0-beta1'
    end
  end

  context 'when failed' do
    before do
      stub_request(:get, 'https://example.com/.well-known/nodeinfo').to_return(status: 404)
      Fabricate(:account, domain: 'example.com')
      Instance.refresh
    end

    it 'performs a mastodon instance' do
      expect { subject.perform('example.com') }.to raise_error(ActivityPub::FetchInstanceInfoWorker::RequestError, 'Request for example.com returned HTTP 404')

      info = InstanceInfo.find_by(domain: 'example.com')
      expect(info).to be_nil
    end
  end
end
