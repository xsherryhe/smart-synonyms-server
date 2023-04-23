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

  def related_adj_synset
    mock_synset = MockSynset.new

    def mock_synset.pos
      'a'
    end
    mock_synset
  end

  def related_adj_word
    %w[a b c d e 1 2 3].sample
  end
end
