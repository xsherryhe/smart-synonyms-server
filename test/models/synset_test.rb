require 'test_helper'

class SynsetTest < ActiveSupport::TestCase
  describe 'Synset' do
    before :all do
      @sample_pos = 'a'
      @sample_pos_offset = WordNet::Synset.find('orange', 'adj').first.pos_offset
      @sample_pos_offset2 = WordNet::Synset.find('cold', 'adj').first.pos_offset
    end

    describe 'Synset#first_word' do
      it 'returns a word from the synset' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        first_word = synset.first_word
        assert_includes(['orange', 'orangish'], first_word)
      end

      describe 'when an origin word is passed in to Synset.new' do
        it 'returns the origin word' do
          synset = Synset.new(@sample_pos, @sample_pos_offset, 'orangish')
          first_word = synset.first_word
          assert_equal('orangish', first_word)
        end
      end
    end

    describe 'Synset#sample_synonyms' do
      it 'returns an array of 5 items' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.sample_synonyms
        assert_equal(5, synonyms.size)
      end

      it 'returns an array of hashes' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.sample_synonyms
        synonyms.each { |synonym| assert_instance_of(Hash, synonym) }
      end

      it 'does not return any hashes with the same pos_offset property as itself' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.sample_synonyms
        synonyms.each { |synonym| refute_equal(synonym[:pos_offset], @sample_pos_offset) }
      end

      it 'does not return any duplicate hashes' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.sample_synonyms
        seen_synonyms = []
        synonyms.each do |synonym|
          refute_includes(seen_synonyms, synonym[:pos_offset])
          seen_synonyms << synonym[:pos_offset]
        end
      end
    end

    describe 'Synset#synonym_synsets' do
      it 'returns an array of Synsets' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.synonym_synsets
        synonyms.each { |synonym| assert_instance_of(Synset, synonym) }
      end

      it 'returns an array of synonyms for the original synset' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        synonyms = synset.synonym_synsets.map(&:words)
        assert_equal([['chromatic']], synonyms)
      end

      describe 'when an excluded word is specified in options' do
        it 'does not return any Synsets with the excluded word' do
          synset = Synset.new(@sample_pos, @sample_pos_offset)
          synonyms = synset.synonym_synsets({ exclude: 'chromatic' })
          synonyms.each { |synonym| refute_includes(synonym.words, 'chromatic') }
        end
      end
    end

    describe 'Synset#definition' do
      it 'returns a string with the definition of the synset' do
        synset = Synset.new(@sample_pos, @sample_pos_offset)
        definition = synset.definition
        assert_equal('of the color between red and yellow; similar to the color of a ripe orange', definition)
      end
    end

    describe 'Synset#examples' do
      it 'returns an array of examples for the synset' do
        synset = Synset.new(@sample_pos, @sample_pos_offset2)
        examples = synset.examples
        assert_equal(['a cold climate', 'a cold room', 'dinner has gotten cold', 
                      'cold fingers', 'if you are cold, turn up the heat', 'a cold beer'],
                     examples)
      end
    end

    describe 'Synset#relation' do
      it 'returns an array of Synsets' do
        synset = Synset.new(@sample_pos, @sample_pos_offset2)
        relations = synset.relation('!')
        relations.each { |relation| assert_instance_of(Synset, relation) }
      end

      it 'returns an array of synsets with the specified relation to the original synset' do
        synset = Synset.new(@sample_pos, @sample_pos_offset2)
        relations = synset.relation('!').map(&:words)
        assert_equal([['hot']], relations)
      end
    end

    describe 'Synset#related_adj_synset' do
      before :all do
        @adv_pos = 'r'
        @adv_pos_offset = WordNet::Synset.find('slowly', 'adv').first.pos_offset
      end
      it 'returns a Synset' do
        synset = Synset.new(@adv_pos, @adv_pos_offset)
        adj_synset = synset.related_adj_synset
        assert_instance_of(Synset, adj_synset)
      end

      it 'returns an adjective synset that the adverb synset is derived from' do
        synset = Synset.new(@adv_pos, @adv_pos_offset)
        adj_synset_words = synset.related_adj_synset.words
        assert_equal(['slow'], adj_synset_words)
      end
    end
  end
end
