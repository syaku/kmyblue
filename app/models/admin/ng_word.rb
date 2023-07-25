# frozen_string_literal: true

class Admin::NgWord
  class << self
    def reject?(text)
      ng_words.any? { |word| text.include?(word) }
    end

    def hashtag_reject?(hashtag_count)
      post_hash_tags_max.positive? && post_hash_tags_max < hashtag_count
    end

    def hashtag_reject_with_extractor?(text)
      hashtag_reject?(Extractor.extract_hashtags(text)&.size || 0)
    end

    private

    def ng_words
      Setting.ng_words || []
    end

    def post_hash_tags_max
      value = Setting.post_hash_tags_max
      value.is_a?(Integer) && value.positive? ? value : 0
    end
  end
end
