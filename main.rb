class ListService < Sinatra::Application
	configure do
		set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[environment.to_s]
	end

	configure :test do
		ActiveRecord::Base.logger.level = 1
	end

	helpers do
		def find_or_create_item(itemname, listname)
		end
	end

	get '/' do
		return 'Hi'
	end

	get '/lists/:list' do
		if (list = List.find_by_name(params[:list]))
			list.to_json
		else
			status 404
		end
	end

	get '/lists/:list/items' do
		if (list = List.find_by_name(params[:list]))
			list.items.to_json
		else
			status 404
		end
	end

	get '/lists/:list/items/:item' do
		if (list = List.find_by_name(params[:list])) &&
		   (item = list.items.where(:name => params[:item]).first)
			item.to_json
		else
			status 404
		end
	end

	put '/lists/:list/items/:item' do
		list = List.find_or_create_by_name(params[:list])
		item = list.items.find_or_create_by_name(params[:item])

		item.deleted = false

		unless item.needed == params[:needed] || params[:needed].nil?
			# Log the state change
			item.needed = params[:needed]
		end

		unless item.save
			status 500
		end
	end

	delete '/lists/:list/items/:item' do
		if (list = List.find_by_name(params[:list])) &&
		   (item = list.items.where(:name => params[:item]).first)
			item.deleted = true
			unless item.save
				status 500
			end
		else
			status 404
		end
	end
end
