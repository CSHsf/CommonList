class ListService < Sinatra::Application
	configure do
		set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[environment.to_s]
	end

	configure :test do
		ActiveRecord::Base.logger.level = 1
	end

	helpers do
		def format(obj)
			if obj.nil?
				halt 404
			else
				obj.to_json
			end
		end
	end

	before do
		cache_control :no_cache, :must_revalidate
		content_type 'application/json'
	end

	get '/lists/:list_id' do
		format List.find_by_id(params[:list_id])
	end

	get '/lists/:list_id/items' do
		list = List.find_by_id(params[:list_id])
		format list.nil? ? nil : list.items
	end

	get '/lists/:list_id/items/:item' do
		list = List.find_by_id(params[:list_id])
		format list.nil? ? nil : list.items.where(:name => params[:item]).first
	end

	post '/lists' do
		format List.create(:name => params[:title])
	end

	post '/lists/:list_id/items' do
		list = List.find_by_id(params[:list_id])
		if list
			item = list.items.create do |item|
				item.name = params[:name]
				item.needed = params[:needed] || false
			end
			# Log the state change
		end
		format item
	end

	put '/lists/:list_id/items/:item_id' do
		list = List.find_by_id(params[:list_id])
		item = list.items.find_by_id(params[:item_id])

		list.title = params[:title] if params[:title]
		item.deleted = false

		unless item.needed == params[:needed] || params[:needed].nil?
			# Log the state change
			item.needed = params[:needed]
		end

		unless item.save && list.save
			halt 500
		end
	end

	delete '/lists/:list_id/items/:item_id' do
		if (list = List.find_by_id(params[:list_id])) &&
		   (item = list.items.where(:id => params[:item_id]).first)
			item.deleted = true
			unless item.save
				halt 500
			end
		else
			status 404
		end
	end
end
