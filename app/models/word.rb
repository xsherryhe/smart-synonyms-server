class Word
  attr_reader :errors

  def initialize(word)
    return unless validate(word)

    initialize_lemmas_and_adjusted_word(word)
  end

  def word
    @adjusted_word
  end

  def glosses
    return [] if @lemmas.empty?

    @adverb_only ? adj_glosses : word_glosses
  end

  def as_json(_options = {})
    { word:, glosses: }
  end

  private

  def validate(word)
    if word.empty? || word.length > 30
      @errors = ["Word is #{word.empty? ? 'required' : 'too long'}"]
      return false
    end

    true
  end

  def initialize_lemmas_and_adjusted_word(word)
    [word, word.downcase, word.downcase.capitalize].each do |possible_word|
      @adjusted_word = possible_word
      @lemmas = Lemma.find_all(@adjusted_word)
      break if @lemmas.any?
    end
    return @adjusted_word = nil unless @lemmas.any?

    handle_adverb_only_case
  end

  def handle_adverb_only_case
    @adverb_only = @lemmas.all? { |lemma| lemma.pos == 'r' }
    return unless @adverb_only

    @adverb_lemma = @lemmas.first
    @adj_synset = @adverb_lemma.related_adj_synset
    @adjusted_word = @adverb_lemma.related_adj_word
  end

  def word_glosses
    @lemmas.filter_map do |lemma|
      next if lemma.pos == 'r'

      synsets = lemma.synsets.first(3)
      {
        id: lemma.pos + synsets.first.pos_offset.to_s, pos: lemma.pos,
        synsets: synsets.map(&:as_json)
      }
    end
  end

  def adj_glosses
    [{
      id: @adj_synset.pos + @adj_synset.pos_offset.to_s, pos: @adj_synset.pos,
      synsets: [@adj_synset.as_json]
    }]
  end
end
