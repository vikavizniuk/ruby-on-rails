require_relative 'book_manager'

class App
  JSON_FILE = 'library.json'
  YAML_FILE = 'library.yaml'
  STATUS_OPTIONS = BookManager::STATUS.join(', ')
  STATUS_PROMPT = "Статус (#{STATUS_OPTIONS}): "
  NEW_STATUS_PROMPT = "Новий статус (#{STATUS_OPTIONS}, Enter якщо без змін): "

  def initialize
    @manager = load_collection
  end

  def run
    loop do
      show_menu
      choice = gets.chomp

      case choice
      when '1'
        list_books
      when '2'
        add_book
      when '3'
        edit_book
      when '4'
        delete_book
      when '5'
        find_by_title
      when '6'
        filter_by_genre
      when '7'
        filter_by_status
      when '0'
        puts 'Вихід з програми.'
        break
      else
        puts 'Невірний вибір. Спробуйте ще раз.'
      end
    end
  ensure
    @manager.save_to_yaml(YAML_FILE) if @manager
  end

  private

  def load_collection
    if File.exist?(YAML_FILE)
      begin
        collection = BookManager.load_from_yaml(YAML_FILE)
        puts "Завантажено дані з #{YAML_FILE}"
        return BookManager.new(collection)
      rescue StandardError
        puts "Не вдалося завантажити #{YAML_FILE}, пробую #{JSON_FILE}."
      end
    end

    if File.exist?(JSON_FILE)
      begin
        collection = BookManager.load_from_json(JSON_FILE)
        puts "Завантажено дані з #{JSON_FILE}"
        return BookManager.new(collection)
      rescue StandardError
        puts "Не вдалося завантажити #{JSON_FILE}."
      end
    end

    puts 'Починаю з порожньої колекції.'
    BookManager.new
  end

  def show_menu
    puts "\nМеню:"
    puts '1. Показати всі книги'
    puts '2. Додати книгу'
    puts '3. Редагувати книгу'
    puts '4. Видалити книгу'
    puts '5. Пошук за назвою'
    puts '6. Фільтр за жанром'
    puts '7. Фільтр за статусом'
    puts '0. Вийти'
    print 'Ваш вибір: '
  end

  def list_books
    @manager.list_books
  end

  def add_book
    print 'Назва: '
    title = gets.chomp

    print 'Автор: '
    author = gets.chomp

    print 'Жанр: '
    genre = gets.chomp

    print STATUS_PROMPT
    status = gets.chomp

    @manager.add_book(title, author, genre, status)
  end

  def edit_book
    print 'ID книги: '
    id = gets.chomp.to_i

    print 'Нова назва (Enter якщо без змін): '
    title = gets.chomp

    print 'Новий автор (Enter якщо без змін): '
    author = gets.chomp

    print 'Новий жанр (Enter якщо без змін): '
    genre = gets.chomp

    print NEW_STATUS_PROMPT
    status = gets.chomp

    new_data = {}
    new_data[:title] = title unless title.empty?
    new_data[:authors] = [author] unless author.empty?
    new_data[:genres] = [genre] unless genre.empty?
    new_data[:status] = status unless status.empty?

    @manager.edit_book(id, new_data)
  end

  def delete_book
    print 'ID книги: '
    id = gets.chomp.to_i
    @manager.delete_book(id)
  end

  def find_by_title
    print 'Пошуковий запит: '
    query = gets.chomp 
    print_collection(@manager.find_by_title(query))
  end

  def filter_by_genre
    print 'Жанр: '
    genre = gets.chomp
    print_collection(@manager.filter_by_genre(genre))
  end

  def filter_by_status
    print STATUS_PROMPT
    status = gets.chomp
    print_collection(@manager.filter_by_status(status))
  end

  def print_collection(collection)
    if collection.empty?
      puts 'Нічого не знайдено.'
      return
    end

    collection.each do |id, book|
      puts "ID: #{id} | Назва: #{book.title} | Статус: #{book.status}"
    end
  end
end

App.new.run
