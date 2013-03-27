class ListService < Sinatra::Application
	configure do
		set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[environment.to_s]
	end

	configure :test do
		ActiveRecord::Base.logger.level = 1
	end

	helpers do
		def parse_bool_param(str)
			case str.try(:downcase)
				when false.to_s then false
				when true.to_s  then true
				when nil        then nil
				else raise ArgumentError, "'#{str}' is not a bool"
			end
		end
	end

	before do
		cache_control :no_cache, :must_revalidate
		content_type 'application/json'
	end

	error do
		ex = env['sinatra.error']
		# TODO: Jumpfrog this error
		p ex
		halt 500
	end

	error ActiveRecord::RecordNotFound do
		halt 404
	end

	get '/lists/:list_id' do
		List.find_by_id!(params[:list_id]).to_json
	end

	get '/lists/:list_id/items' do
		List.find_by_id!(params[:list_id]).items.to_json
	end

	get '/lists/:list_id/items/:item' do
		List.find_by_id!(params[:list_id]).items.where(:name => params[:item]).first!.to_json
	end

	put '/lists/:list_id/items/:item' do
		needed = parse_bool_param(params[:needed])
		list = List.find_or_create_by_id(params[:list_id])
		item = list.items.find_or_create_by_name(params[:item])

		list.title = params[:title] if params[:title]
		item.deleted = false

		unless item.needed == needed or needed.nil?
			item.needed = needed
			item.events.create(:needed => needed, :deleted => false)
		end

		item.save
		list.save
	end

	delete '/lists/:list_id/items/:item' do
		item = List.find_by_id!(params[:list_id]).items.where(:name => params[:item]).first!
		item.deleted = true
		item.events.create(:needed => item.needed, :deleted => true)
		item.save
	end
end
