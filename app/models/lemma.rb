class Lemma < WordNet::Lemma
  def self.find(word, pos)
    pos = POS_SHORTHAND[pos] || pos

    cache = @@cache[pos] ||= build_cache(pos)
    found = cache[word]
    Lemma.new(*found) if found
  end

  def synsets
    @synset_offsets.map { |offset| Synset.new(@pos, offset) }
  end

  def related_adj_synset
    synsets.first.related_adj_synset
  end

  def related_adj_word
    related_adj_synset.first_word
  end
end
