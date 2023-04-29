require 'test_helper'
require 'mock_classes'

class WordTest < ActiveSupport::TestCase
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
      Lemma.stub :find_all, [] do
        word_data = Word.new('aBc')
        word = word_data.word
        assert_nil(word)
      end
    end

    it 'returns the formatted version of an input word' do
      Lemma.stub :find_all, Array.new(3) { MockLemma.new } do
        word_data = Word.new('apple_tree')
        word = word_data.word
        assert_equal('apple tree', word)
      end
    end
  end

  describe 'Word#glosses' do
    describe 'when the word is not an adverb' do
      it 'returns an array' do
        Lemma.stub :find_all, Array.new(3) { MockLemma.new } do
          word_data = Word.new('apple')
          glosses = word_data.glosses
          assert_instance_of(Array, glosses)
        end
      end

      it 'returns an array of hashes having a string id' do
        Lemma.stub :find_all, Array.new(3) { MockLemma.new } do
          word_data = Word.new('apple')
          id = word_data.glosses.first[:id]
          assert_instance_of(String, id)
        end
      end

      it 'returns an array of hashes having a pos property' do
        Lemma.stub :find_all, Array.new(3) { MockLemma.new } do
          word_data = Word.new('apple')
          pos = word_data.glosses.first[:pos]
          assert_includes(%w[n v a], pos)
        end
      end
    end

    describe 'when the word is an adverb' do
      before :each do
        @mock_lemma = MockLemma.new

        def @mock_lemma.pos
          'r'
        end
      end

      it 'returns an array' do
        Lemma.stub :find_all, Array.new(3, @mock_lemma) do
          word_data = Word.new('slowly')
          glosses = word_data.glosses
          assert_instance_of(Array, glosses)
        end
      end

      it 'returns an array of hashes having a string id' do
        Lemma.stub :find_all, Array.new(3, @mock_lemma) do
          word_data = Word.new('slowly')
          id = word_data.glosses.first[:id]
          assert_instance_of(String, id)
        end
      end

      it 'returns an array of hashes having a pos property of a' do
        Lemma.stub :find_all, Array.new(3, @mock_lemma) do
          word_data = Word.new('slowly')
          pos = word_data.glosses.first[:pos]
          assert_equal('a', pos)
        end
      end
    end
  end
end
