require 'json'
require 'yaml'

STATUS = ["read", "want_to_read", "reading"]
def list_books(collection)
  puts "\nКаталог книг:"
  if collection.empty?
    puts "Список порожній."
  else
    collection.each do |id, data|
      puts "ID: #{id} | Назва: #{data[:title]} | Статус: #{data[:status]}"
    end
  end
end

def add_book(collection, title, author, genre, status)
  unless STATUS.include?(status)
    puts "Помилка: Статус '#{status}' невалідний. Доступні: #{STATUS.join(', ')}"
    return
  end

  new_id = 0
  collection.each_key do |id|
    new_id = id if id > new_id
  end
  new_id += 1

  collection[new_id] = {
    title: title,
    authors: [author],
    genres: [genre],
    status: status
  }
  puts "Книгу '#{title}' успішно додано."
end

def edit_book(collection, id, new_data)
  if collection.has_key?(id)
    if new_data.has_key?(:status) && !STATUS.include?(new_data[:status])
      puts "Помилка: Статус '#{new_data[:status]}' невалідний. Доступні: #{STATUS.join(', ')}"
      return
    end

    current_book = collection[id]

    new_data.each do |key, value|
      current_book[key] = value
    end
    
    puts "Дані книги №#{id} успішно оновлено."
  else
    puts "Помилка: Книгу з ID #{id} не знайдено."
  end
end

def delete_book(collection, id)
  if collection.has_key?(id)
    collection.delete(id)
    puts "Запис №#{id} видалено."
  else
    puts "Помилка: Книги з ID #{id} не існує."
  end
end

def find_by_title(collection, query)
  puts "Результати пошуку для '#{query}':"
  found = false
  
  collection.each do |id, data|
    if data[:title].downcase.include?(query.downcase)
      puts "Знайдено: [#{id}] #{data[:title]}"
      found = true
    end
  end
  
  puts "Нічого не знайдено." unless found
end

def filter_by_genre(collection, genre)
  puts "Книги жанру '#{genre}':"
  collection.select do |id, data|
    unless data[:genres].nil? 
    data[:genres].include?(genre)
    end
  end
end

def filter_by_status(collection, status)
  puts "Книги зі статусом '#{status}':"
  unless STATUS.include?(status)
    puts "Помилка: Статус '#{status}' невалідний. Доступні: #{STATUS.join(', ')}"
    return
  end

  collection.select do |id, data|
    unless data[:status].nil?
      data[:status].include?(status)
    end
  end
end

def save_to_json(collection, filename)
  File.open(filename, "w") do |f|
    f.write(JSON.pretty_generate(collection))
  end
  puts "Збережено у #{filename}"
end

def load_from_json(filename)
  file_content = File.read(filename)
  data = JSON.parse(file_content, symbolize_names: true)
  clean_data = {}
  data.each { |k, v| clean_data[k.to_s.to_i] = v }
  clean_data
rescue Errno::ENOENT
  puts "Файл '#{filename}' не знайдено, повертаю порожній хеш."
  {}
end

def save_to_yaml(collection, filename)
  File.open(filename, "w") do |f|
    f.write(YAML.dump(collection))
  end
  puts "Збережено у #{filename}"
end

def load_from_yaml(filename)
  data = YAML.load_file(filename, permitted_classes: [Symbol], aliases: true)
  clean_data = {}
  data.each { |k, v| clean_data[k.to_s.to_i] = v }
  clean_data
rescue Errno::ENOENT
  puts "Файл '#{filename}' не знайдено, повертаю порожній хеш."
  {}
end

# add_book(books, "Тигролови", "Іван Багряний", "Пригоди", "want_to_read")
# edit_book(books, 1, { status: "read" })
books = load_from_json("library.json")
puts filter_by_genre(books, "Пригоди")
puts filter_by_status(books, "want_to_rad")
# list_books(books)
# find_by_title(books, "тигр")
# save_to_json(books, "library.json")
# save_to_yaml(books, "library.yaml")