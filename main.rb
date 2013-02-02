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

	get '/' do
		return 'Hi'
	end

	get '/lists/:list' do
		format List.find_by_name(params[:list])
	end

	get '/lists/:list/items' do
		format List.find_by_name(params[:list]).items
	end

	get '/lists/:list/items/:item' do
		list = List.find_by_name(params[:list])
		format if list.nil? ? nil : list.items.where(:name => params[:item]).first
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
			halt 500
		end
	end

	delete '/lists/:list/items/:item' do
		if (list = List.find_by_name(params[:list])) &&
		   (item = list.items.where(:name => params[:item]).first)
			item.deleted = true
			unless item.save
				halt 500
			end
		else
			status 404
		end
	end
end
