require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

set :database, YAML::load(File.open('config/database.yml'))[settings.environment.to_s]
