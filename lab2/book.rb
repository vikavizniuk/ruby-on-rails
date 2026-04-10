class Book
  attr_accessor :title, :authors, :genres, :status

  def initialize(title:, authors:, genres: [], status:)
    @title = title
    @authors = authors
    @genres = genres
    @status = status
  end

  def to_h
    {
      title: title,
      authors: authors,
      genres: genres,
      status: status
    }
  end

  def self.from_h(hash)
    normalized = hash.transform_keys(&:to_sym)

    new(
      title: normalized[:title],
      authors: normalized[:authors] || [],
      genres: normalized[:genres] || [],
      status: normalized[:status]
    )
  end
end
