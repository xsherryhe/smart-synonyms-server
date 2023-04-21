require 'test_helper'

class WordTest < ActiveSupport::TestCase
  class MockSynset
    def as_json
      %w[a b c d e 1 2 3].sample
    end

    def pos_offset
      rand(1000)
    end
  end

  class MockLemma
    def pos
      %w[n v a].sample
    end

    def synsets
      Array.new(3) { MockSynset.new }
    end
  end

  describe 'Word#word' do
    it 'returns the input word when lemmas of the input word are found' do
      Lemma.stub :find_all, lambda { |word|
        word == 'aBc' ? Array.new(3) { MockLemma.new } : []
      } do
        word_data = Word.new('aBc')
        word = word_data.word
        assert_equal('aBc', word)
      end
    end

    it 'returns the lowercase input word when lemmas of the input word in lowercase are found' do
      Lemma.stub :find_all, lambda { |word|
        word == 'abc' ? Array.new(3) { MockLemma.new } : []
      } do
        word_data = Word.new('aBc')
        word = word_data.word
        assert_equal('abc', word)
      end
    end

    it 'returns the capitalized input word when lemmas of the capitalized input word are found' do
      Lemma.stub :find_all, lambda { |word|
        word == 'Abc' ? Array.new(3) { MockLemma.new } : []
      } do
        word_data = Word.new('aBc')
        word = word_data.word
        assert_equal('Abc', word)
      end
    end

    it 'returns nil when no version of the input word is found as a lemma' do
      Lemma.stub :find_all, ->(_word) { [] } do
        word_data = Word.new('aBc')
        word = word_data.word
        assert_nil(word)
      end
    end
  end

  ## Glosses -- returns array of hashes with id, pos, synsets array
    ## Test non-adverb
    ## Test adverb -- stub MockLemma#pos
  # describe 'Word#glosses' do
  #   setup do
  #     Lemma.stub :find_all, Minitest::Mock.new do
  #       Array.new(3) { MockLemma.new }
  #     end
  #   end

  #   describe 'when the word is not an adverb' do
  #     it 'returns an array' do
  #       word_data = Word.new('apple')
  #       glosses = word_data.glosses
  #       assert_instance_of(Array, glosses)
  #     end

  #     it 'returns an array of hashes having a string id' do
  #       word_data = Word.new('apple')
  #       id = word_data.glosses.first.id
  #       assert_instance_of(String, id)
  #     end

  #     it 'returns an array of hashes having a pos property' do
  #       word_data = Word.new('apple')
  #       id = word_data.glosses.first.id
  #       assert_includes(%w[n v a], id)
  #     end
  #   end
  # end
end
