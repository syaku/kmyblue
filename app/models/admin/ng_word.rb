# frozen_string_literal: true

class Admin::NgWord
  class << self
    def reject?(text)
      ng_words.any? { |word| text.include?(word) }
    end

    private

    def ng_words
      Setting.ng_words
    end
  end
end
