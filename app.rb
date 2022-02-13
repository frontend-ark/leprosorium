#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true
end

before do # выполняется перез каждым запросом, после перезакрузки любой страницы
  # инициализация бд
  init_db
end

# configure вызывается каждый раз при конфигурации приложения
# когда изменился код программы и перезагрузилась страница

configure do 

  # инициализация базы данных

  init_db

  # создает таблицу если она не существует

  @db.execute ' CREATE TABLE IF NOT EXISTS "Posts"
  (
    "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "Created_Date" DATE,
    "Content" TEXT
  ); '

    @db.execute ' CREATE TABLE IF NOT EXISTS "Comments"
  (
    "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "Created_Date" DATE,
    "Content" TEXT,
    "post_id" INTEGER
  ); '
end

get '/' do

  # выбираем список постов из базы данных  в порядке убывания по ID

  @results = @db.execute 'SELECT * FROM Posts ORDER BY Id DESC'

	erb :index
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)

get '/new' do
  erb :new     
end

# обработчик post-запроса /new
# браузер отправляет данные на сервер

post '/new' do
  # получаем переменную из POST запроса
  @content = params[:content] # name="content" в textarea в new.erb
  
  if @content.length <= 0
    # @error прописано в layout
    @error = 'Type post text'
    return erb :new
  end

  # сохранение данных в бд

  @db.execute 'INSERT INTO Posts (Content, Created_Date) values (?, datetime())', [@content]

  # перенаправление на главную страницу

  redirect to '/'
  erb "You typed: #{@content}"    
end

# вывод информации о посте

get '/details/:post_id' do

  # получаем переменную из url'а
  post_id = params[:post_id]

  # получаем список постов
  # (у нас будет только один пост)
   results = @db.execute 'SELECT * FROM Posts WHERE Id = ?', [post_id]

   # выбираем этот один пост в переменную @row
   @row = results[0]

  # возвращаем представление details.erb
  erb :details

end

# обработчик post запроса /details/...
# браузер отправляет данные на сервер, а мы из принимаем

post '/details/:post_id' do

  # получаем переменную из url'а
  post_id = params[:post_id]

  # получаем переменную из POST запроса
  @content = params[:content]

  erb "You tiped comment #{@content} for post #{post_id}"

 end 
