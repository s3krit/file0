# frozen_string_literal: true

require 'test/unit'
require_relative '../random_phrase'

class RandomPhraseTest < Test::Unit::TestCase
  def test_unique_phrase_generation
    phrases = (1..10_000).map { File0::RandomPhrase.generate }
    assert_equal 10_000, phrases.uniq.count
  end
end
