source :rubygems

gem 'sinatra'
gem 'rack'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'rake'
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
end

group :production do
	gem 'pg'
	gem 'unicorn'
end

group :development, :production do
	gem 'delayed_job'
	gem 'delayed_job_active_record'
end
