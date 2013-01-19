Bundler.require(:default, :test)
require File.expand_path('../main.rb', File.dirname(__FILE__))

set :environment, :test

def app
	GroceryService
end

describe 'Grocery Service' do
	include Rack::Test::Methods

	it 'puts the lotion in the basket' do
		get '/'
		last_response.status.should == 200
		last_response.body.should == 'Hi'
	end
end
