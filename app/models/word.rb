class Word
  def initialize(word)
    @lemmas = WordNet::Lemma.find_all(word)
  end

  def glosses
    return [] if @lemmas.empty?

    glosses = @lemmas.filter_map do |lemma|
      lemma.pos == 'r' ? nil : lemma_glosses(lemma)
    end
    glosses.any? ? glosses : adj_glosses
  end

  private

  def lemma_glosses(lemma)
    {
      word: lemma.word,
      pos: lemma.pos,
      synsets: lemma.synsets.first(3).map do |synset|
        { pos_offset: synset.pos_offset, gloss: synset.gloss }
      end
    }
  end

  def adj_glosses
    adj_synset = @lemmas.first.synsets.first.relation('\\').first
    [[adj_synset.words.first, adj_synset.pos, adj_synset.gloss]]
  end
end
