Bundler.require(:default, :test)

set :environment, :test

require File.expand_path('../main.rb', File.dirname(__FILE__))
Dir[File.expand_path('../models/*.rb', File.dirname(__FILE__))].each { |file| p file; require file }
Dir[File.expand_path('../config/initializers/*.rb', File.dirname(__FILE__))].each { |file| p file; require file }

RSpec.configure do |config|
	config.include Rack::Test::Methods

	config.before(:suite) do
		DatabaseCleaner.strategy = :transaction
		DatabaseCleaner.clean_with(:truncation)
	end

	config.before(:each) do
		DatabaseCleaner.start
	end

	config.after(:each) do
		DatabaseCleaner.clean
	end
end

def app
	ListService
end
