require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[Sinatra::Base.environment.to_s]
