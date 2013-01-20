class GroceryService < Sinatra::Application
	configure do
		set :database, YAML::load(File.open('config/database.yml'))[environment.to_s]
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
		list.to_json(:methods => [:items])
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
		list = List.find_by_name(params[:list])
		unless list
			status 404
			return
		end
		item = list.items.where(:name => params[:item]).first
		unless item
			status 404
			return
		end
		item.to_json
	end

	put '/lists/:list/items/:item' do
		list = List.find_by_name(params[:list])
		unless list
			list = List.create(:name => params[:list])
		end

		item = list.items.where(:name => params[:item]).first
		unless item
			item = list.items.create(:name => params[:item])
		end

		unless item.needed == params[:needed] || params[:needed].nil?
			# Log the state change
			item.needed = params[:needed]
			item.save
		end
	end

	delete '/lists/:list/items/:item' do
		list = List.find_by_name(params[:list])
		unless list
			status 404
			return
		end
		item = list.items.where(:name => params[:item]).first
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
