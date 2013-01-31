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
		list = List.find_by_name(params[:list])
		unless list
			status 404
			return
		end
		list.to_json
	end

	get '/lists/:list/items' do
		list = List.find_by_name(params[:list])
		unless list
			status 404
			return
		end
		list.items.where(:deleted => false).to_json
	end

	get '/lists/:list/items/:item' do
		item = Item.find_by_list_id_and_name(params[:list], params[:item])
		unless item
			status 404
			return
		end
		item.to_json
	end

	put '/lists/:list/items/:item' do
		item = Item.find_or_create_by_list_id_and_name(params[:list], params[:item])

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
		item = Item.find_by_list_id_and_name(params[:list], params[:item])
		unless item
			status 404
			return
		end
		item.deleted = true
		unless item.save
			status 500
		end
	end
end
