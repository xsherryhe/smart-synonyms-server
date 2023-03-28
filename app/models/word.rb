class Word
  def initialize(word)
    @lemmas = WordNet::Lemma.find_all(word)
  end

  def glosses
    return [] if @lemmas.empty?

    filter_mapped_glosses = @lemmas.filter_map do |lemma|
      lemma.pos == 'r' ? nil : lemma_glosses(lemma)
    end
    filter_mapped_glosses.any? ? filter_mapped_glosses : adj_glosses
  end

  def as_json(_ = {})
    glosses
  end

  private

  def lemma_glosses(lemma)
    synsets = lemma.synsets.first(3)
    {
      id: lemma.pos + synsets.first.pos_offset.to_s,
      word: lemma.word,
      pos: lemma.pos,
      synsets: synsets.map do |synset|
        { pos_offset: synset.pos_offset, gloss: synset.gloss }
      end
    }
  end

  def adj_glosses
    adj_synset = @lemmas.first.synsets.first.relation('\\').first
    [{
      word: adj_synset.words.first,
      pos: adj_synset.pos,
      synsets: [{ pos_offset: adj_synset.pos_offset, gloss: adj_synset.gloss }]
    }]
  end
end
