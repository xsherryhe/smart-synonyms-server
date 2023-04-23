require 'test_helper'
require 'mock_classes'

class LemmaTest < ActiveSupport::TestCase
  describe 'Lemma::find' do
    it 'returns a lemma when passed a word and part of speech with an entry in the database' do
      lemma = Lemma.find('apple', 'noun')
      assert_instance_of(Lemma, lemma)
    end

    it 'returns nil when passed a word and part of speech with no entry in the database' do
      lemma = Lemma.find('abc', 'verb')
      assert_nil(lemma)
    end
  end

  describe 'Lemma#synsets' do
    it 'returns an array' do
      Synset.stub :new, MockSynset.new do
        lemma = Lemma.find('apple', 'noun')
        synsets = lemma.synsets
        assert_instance_of(Array, synsets)
      end
    end

    it 'returns an array of synsets' do
      Synset.stub :new, MockSynset.new do
        lemma = Lemma.find('apple', 'noun')
        synset = lemma.synsets.first
        assert_instance_of(MockSynset, synset)
      end
    end
  end

  describe 'Lemma#related_adj_synset' do
    it 'returns the value of related_adj_synset from its first synset' do
      mock_synset = MockSynset.new
      def mock_synset.related_adj_synset
        'foobar'
      end

      Synset.stub :new, mock_synset do
        lemma = Lemma.find('slowly', 'adv')
        adj_synset = lemma.related_adj_synset
        assert_equal(adj_synset, 'foobar')
      end
    end
  end

  describe 'Lemma#related_adj_word' do
    it 'returns the value of first_word from its related_adj_synset' do
      Synset.stub :new, MockSynset.new do
        lemma = Lemma.find('slowly', 'adv')
        adj_word = lemma.related_adj_word
        assert_equal(adj_word, 'barfoo')
      end
    end
  end
end
