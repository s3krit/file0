# frozen_string_literal: true

require 'securerandom'
require_relative 'word_bank'

module File0
  class RandomPhrase
    DEFAULT_OPTIONS = {
      adjectives: 2,
      nouns: 1
    }.freeze

    def self.generate(options = {})
      options.merge!(DEFAULT_OPTIONS)

      ''.dup.tap do |phrase|
        options.each do |word_type, count|
          count.times do
            const_name = word_type.to_s.upcase
            available_words = File0::WordBank.const_get(const_name).length
            selection = SecureRandom.random_number(available_words)
            phrase << File0::WordBank.const_get(const_name)[selection].to_s.downcase.capitalize
          end
        end
      end
    end
  end
end
