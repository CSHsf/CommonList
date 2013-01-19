Bundler.require(:default, :test)

set :environment, :test

require File.expand_path('../main.rb', File.dirname(__FILE__))

RSpec.configure do |config|
	config.include Rack::Test::Methods
end

def app
	GroceryService
end
