require 'json'
require 'yaml'
require_relative 'book'

class BookManager
  STATUS = ['read', 'want_to_read', 'reading'].freeze

  attr_reader :collection

  def initialize(collection = {})
    @collection = collection
  end

  def list_books
    puts "\nКаталог книг:"
    if @collection.empty?
      puts 'Список порожній.'
      return
    end

    @collection.each do |id, book|
      puts "ID: #{id} | Назва: #{book.title} | Статус: #{book.status}"
    end
  end

  def add_book(title, author, genre, status)
    unless valid_status?(status)
      return
    end

    new_id = (@collection.keys.max || 0) + 1
    @collection[new_id] = Book.new(
      title: title,
      authors: [author],
      genres: [genre].compact,
      status: status
    )

    puts "Книгу '#{title}' успішно додано."
  end

  def edit_book(id, new_data)
    book = @collection[id]

    unless book
      puts "Помилка: Книгу з ID #{id} не знайдено."
      return
    end

    if new_data.key?(:status) && !valid_status?(new_data[:status])
      return
    end

    new_data.each do |key, value|
      setter = "#{key}="
      book.public_send(setter, value) if book.respond_to?(setter)
    end

    puts "Дані книги №#{id} успішно оновлено."
  end

  def delete_book(id)
    if @collection.key?(id)
      @collection.delete(id)
      puts "Запис №#{id} видалено."
    else
      puts "Помилка: Книги з ID #{id} не існує."
    end
  end

  def find_by_title(query)
    @collection.select do |_id, book|
      book.title.downcase.include?(query.downcase)
    end
  end

  def filter_by_genre(genre)
    puts "Книги жанру '#{genre}':"
    @collection.select do |_id, book|
      book.genres&.include?(genre)
    end
  end

  def filter_by_status(status)
    puts "Книги зі статусом '#{status}':"
    return {} unless valid_status?(status)

    @collection.select do |_id, book|
      book.status == status
    end
  end

  def save_to_json(filename)
    serializable = @collection.transform_values(&:to_h)

    File.open(filename, 'w') do |file|
      file.write(JSON.pretty_generate(serializable))
    end

    puts "Збережено у #{filename}"
  end

  def self.load_from_json(filename)
    data = JSON.parse(File.read(filename))
    normalize_collection(data)
  rescue Errno::ENOENT
    puts "Файл '#{filename}' не знайдено, повертаю порожній хеш."
    {}
  end

  def save_to_yaml(filename)
    File.open(filename, 'w') do |file|
      file.write(YAML.dump(@collection))
    end

    puts "Збережено у #{filename}"
  end

  def self.load_from_yaml(filename)
    data = YAML.load_file(filename)
    normalize_yaml_collection(data)
  rescue Errno::ENOENT
    puts "Файл '#{filename}' не знайдено, повертаю порожній хеш."
    {}
  end

  def self.normalize_collection(data)
    data.each_with_object({}) do |(key, value), collection|
      id = key.to_i
      collection[id] = value.is_a?(Book) ? value : Book.from_h(value)
    end
  end

  def self.normalize_yaml_collection(data)
    data.each_with_object({}) do |(key, value), collection|
      id = key.to_i
      collection[id] = value.is_a?(Book) ? value : Book.from_h(value)
    end
  end

  private

  def valid_status?(status)
    return true if STATUS.include?(status)

    puts "Помилка: Статус '#{status}' невалідний. Доступні: #{STATUS.join(', ')}"
    false
  end
end
