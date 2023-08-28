# frozen_string_literal: true

class PublicStatusesIndex < Chewy::Index
  DEVELOPMENT_SETTINGS = {
    filter: {
      english_stop: {
        type: 'stop',
        stopwords: '_english_',
      },

      english_stemmer: {
        type: 'stemmer',
        language: 'english',
      },

      english_possessive_stemmer: {
        type: 'stemmer',
        language: 'possessive_english',
      },
    },

    analyzer: {
      content: {
        tokenizer: 'uax_url_email',
        filter: %w(
          english_possessive_stemmer
          lowercase
          asciifolding
          cjk_width
          english_stop
          english_stemmer
        ),
      },
    },
  }.freeze

  PRODUCTION_SETTINGS = {
    filter: {
      english_stop: {
        type: 'stop',
        stopwords: '_english_',
      },

      english_stemmer: {
        type: 'stemmer',
        language: 'english',
      },

      english_possessive_stemmer: {
        type: 'stemmer',
        language: 'possessive_english',
      },
    },

    analyzer: {
      content: {
        tokenizer: 'uax_url_email',
        filter: %w(
          english_possessive_stemmer
          lowercase
          asciifolding
          cjk_width
          english_stop
          english_stemmer
        ),
      },
      sudachi_analyzer: {
        filter: [],
        type: 'custom',
        tokenizer: 'sudachi_tokenizer',
      },
    },
    tokenizer: {
      sudachi_tokenizer: {
        resources_path: '/etc/elasticsearch/sudachi',
        split_mode: 'A',
        type: 'sudachi_tokenizer',
        discard_punctuation: 'true',
      },
    },
  }.freeze

  settings index: index_preset(refresh_interval: '30s', number_of_shards: 5), analysis: PRODUCTION_SETTINGS

  index_scope ::Status.unscoped
                      .kept
                      .indexable
                      .includes(:media_attachments, :preloadable_poll, :preview_cards)

  root date_detection: false do
    field(:id, type: 'keyword')
    field(:account_id, type: 'long')
    field(:text, type: 'text', analyzer: 'sudachi_analyzer', value: ->(status) { status.searchable_text }) { field(:stemmed, type: 'text', analyzer: 'content') }
    field(:language, type: 'keyword')
    field(:domain, type: 'keyword', value: ->(status) { status.account.domain || '' })
    field(:properties, type: 'keyword', value: ->(status) { status.searchable_properties })
    field(:created_at, type: 'date')
  end
end
