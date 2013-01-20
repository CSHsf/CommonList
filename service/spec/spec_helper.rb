Bundler.require(:default, :test)

set :environment, :test

require File.expand_path('../main.rb', File.dirname(__FILE__))
Dir[File.expand_path('../models/*.rb', File.dirname(__FILE__))].each { |file| p file; require file }

RSpec.configure do |config|
	config.include Rack::Test::Methods
end

def app
	GroceryService
end
