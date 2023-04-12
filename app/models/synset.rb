class Synset < WordNet::Synset
  attr_accessor :words

  def initialize(pos, pos_offset, origin_word = nil)
    super(pos, pos_offset)
    @origin_word = origin_word
    @words = words_from_word_counts
    @gloss = @gloss.gsub(/[`'][^`']+[`']/) { |str| "\"#{str[1...-1]}\"" }
    @gloss_split_index = @gloss.index('; "')
  end

  def sample_synonyms(options = {})
    fill_to(5, options).map(&:as_json)
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
    @gloss[0...@gloss_split_index]
  end

  def examples
    return [] unless @gloss_split_index

    @gloss[@gloss_split_index + 2..].split('; ').map { |example| example.delete('"') }
  end

  def relation(pointer_symbol)
    @pointers.select { |pointer| pointer.symbol == pointer_symbol }
             .map! { |pointer| Synset.new(pointer.pos, pointer.offset) }
  end

  def as_json(_options = {})
    { pos_offset:,
      words:,
      definition:,
      examples: }
  end

  def as_json_with_synonyms(options = {})
    as_json(options).merge({ synonyms: sample_synonyms(exclude: @origin_word) })
  end

  private

  def words_from_word_counts
    @word_counts.keys
                .map { |word| word.gsub(/\(.*\)/, '').tr('_', ' ') }
                .sort_by { |word| word == @origin_word ? 0 : 1 }
  end

  def raw_synonym_synsets
    hypernyms + hyponyms + (pos == 'a' ? relation('&') : [])
  end

  def fill_to(count, options, synsets = [self], all_synsets = [], visited = Set.new([@pos_offset]))
    return all_synsets.sample(count) if all_synsets.size >= count

    new_synsets = generate_new_synsets(options, synsets, visited)
    return all_synsets.sample(count) if new_synsets.empty?

    fill_to(count, options, new_synsets, all_synsets + new_synsets, visited)
  end

  def generate_new_synsets(options, synsets, visited)
    new_synsets = []
    synsets.each do |synset|
      synset.synonym_synsets(options).each do |new_synset|
        next if visited.include?(new_synset.pos_offset)

        new_synsets << new_synset
        visited.add(new_synset.pos_offset)
      end
    end
    new_synsets
  end
end
