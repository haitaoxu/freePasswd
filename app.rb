require "sinatra"
require "watir-webdriver"
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'

before do
  headers "Content-Type" => "text/html; charset=utf8"
end

before '/pwds*' do
  @pwds = Passwd.all(:order => [ :title.asc ])
end

before '/pwds/:id*' do
  @pwd = Passwd.get(params[:id].to_i)
end

get '/' do
  @pwds = Passwd.all(:order => [ :title.asc ])
  erb :index
end

get '/pwds' do
  erb :index
end

get '/pwds/new' do
  erb :new
end

get '/pwds/:id/edit' do
  erb :edit
end

post '/pwds' do
  Passwd.create(params[:pwd])
  erb :index
end

put '/pwds/:id' do
  @pwd.update(params[:pwd])
  erb :index
end

delete '/pwds/:id' do
  Passwd.get(@pwd.id).destroy
  erb :index
end

post '/pwds/:id/dup' do
  Passwd.create({
    title: @pwd.title,
    url: @pwd.url,
    name: @pwd.name,
    passwd: @pwd.passwd,
    form_id: @pwd.form_id
  })

  erb :edit
end

get '/reward_to/:id' do
  `rm -rf /Users/xuhaitao/Library/Safari/Extensions.bak/Extensions`
  pwd = Passwd.get(params[:id].to_i)
  browser = Watir::Browser.new params[:type].to_sym
  browser.goto pwd.url
  browser.text_field(:name, pwd.form_id).set(pwd.name)
  browser.text_field(:type, 'password').set(pwd.passwd)
  browser.button(:type, "submit").click
end


configure do
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/default.db")

  class Passwd
    include DataMapper::Resource

    property :id, Serial
    property :title, String
    property :url, String
    property :name, String
    property :passwd, String
    property :form_id, String
    property :created_at, DateTime
    property :updated_at, DateTime
  end

  DataMapper.finalize

  # automatically migrate database if needed
  # DataMapper.auto_migrate!
end


