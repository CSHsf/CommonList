class GroceryService < Sinatra::Application
	configure do
		set :database, YAML::load(File.open('config/database.yml'))[environment.to_s]
	end

	get '/' do
		return 'Hi'
	end
end
