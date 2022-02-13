#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true
end

before do #выполняется перез каждым запросом
  init_db
end

configure do #вызывается всегда, когда обновляется страница или внесены новые данные
  init_db
  @db.execute ' CREATE TABLE IF NOT EXISTS "Posts"
  (
    "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "Created_Date" DATE,
    "Content" TEXT
  ); '
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
  erb :new     
end

post '/new' do
  @content = params[:content] #name="content" в textarea в new.erb
  erb "You typed: #{@content}"    
end