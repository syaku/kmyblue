# frozen_string_literal: true

class Admin::SensitiveWord
  class << self
    def sensitive?(text, spoiler_text)
      exposure_text = (spoiler_text.presence || text)
      (spoiler_text.blank? && sensitive_words.any? { |word| text.include?(word) }) ||
        sensitive_words_for_full.any? { |word| exposure_text.include?(word) }
    end

    def modified_text(text, spoiler_text)
      spoiler_text.present? ? "#{spoiler_text}\n\n#{text}" : text
    end

    private

    def sensitive_words
      Setting.sensitive_words || []
    end

    def sensitive_words_for_full
      Setting.sensitive_words_for_full || []
    end
  end
end
