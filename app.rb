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

  erb "You typed: #{@content}"    
end