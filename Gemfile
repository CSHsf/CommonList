source 'https://rubygems.org'

gem 'sinatra'
gem 'rack'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'rake', '=10.0.2'
gem 'uuidtools'

group :test do
	gem 'sqlite3'
	gem 'rack-test'
	gem 'rspec'
	gem 'database_cleaner'
end

group :development do
	gem 'sqlite3'
	gem 'shotgun'
	gem 'capistrano'
	gem 'railsless-deploy'
	gem 'capistrano-unicorn'
	gem 'rvm-capistrano'
end

group :production do
	gem 'pg'
	gem 'unicorn'
end
