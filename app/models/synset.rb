class Synset < WordNet::Synset
  attr_accessor :words

  def initialize(pos, pos_offset)
    super
    @words = words_from_word_counts
  end

  def sample_synonyms(options = {})
    synsets = synonym_synsets(options)
    fill_to(5, options, synsets, synsets).sample(5).map do |synset|
      { definition: synset.definition, words: synset.words }
    end
  end

  def synonym_synsets(options = {})
    raw_synonym_synsets.filter_map do |synset|
      if (exclude = options[:exclude])
        synset.words.reject! { |word| word.match?(/[ \-]#{exclude}|#{exclude}[ \-]|^#{exclude}$/) }
      end
      synset if synset.words.any?
    end
  end

  def definition
    gloss[0...gloss.index('; "')]
  end

  def as_json(options = {})
    { words:,
      definition:,
      synonyms: sample_synonyms(exclude: options[:exclude_from_synonyms]) }
  end

  private

  def words_from_word_counts
    @word_counts.keys.map { |word| word.gsub(/\(.*\)/, '').tr('_', ' ') }
  end

  def raw_synonym_synsets
    (hypernyms + hyponyms + (pos == 'a' ? relation('&') : [])).map do |wordnet_synset|
      Synset.new(wordnet_synset.pos, wordnet_synset.pos_offset)
    end
  end

  def fill_to(count, options, synsets, all_synsets)
    return all_synsets if all_synsets.size >= count

    new_synsets = synsets.reduce([]) do |arr, synset|
      arr + synset.synonym_synsets(options)
    end
    return all_synsets if new_synsets.empty?

    fill_to(count, options, new_synsets, all_synsets + new_synsets)
  end
end
