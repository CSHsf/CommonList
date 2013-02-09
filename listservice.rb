class ListService < Sinatra::Application
	configure do
		set :database, YAML.load(ERB.new(File.read('config/database.yml')).result)[environment.to_s]
		set :notify, YAML.load(ERB.new(File.read('config/notify.yml')).result)[environment.to_s]

		if settings.notify['delayed']
			class ::User
				handle_asynchronously :notify
			end
		end
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

	put '/lists/:list_id/items/:item' do
		needed = case params[:needed].try(:downcase)
			when false.to_s then false
			when true.to_s  then true
			when nil        then nil
			else halt 500
		end

		list = List.find_or_create_by_id(params[:list_id])
		item = list.items.find_or_create_by_name(params[:item])

		list.title = params[:title] if params[:title]
		item.deleted = false

		unless needed.nil? || item.needed == needed
			# Log the state change
			item.needed = needed

			list.users.each { |user| user.notify(item) }
		end

		unless item.save && list.save
			halt 500
		end
	end

	delete '/lists/:list_id/items/:item' do
		if (list = List.find_by_id(params[:list_id])) &&
		   (item = list.items.where(:name => params[:item]).first)
			item.deleted = true
			unless item.save
				halt 500
			end
		else
			status 404
		end
	end

	put '/users/:user_id' do
		return unless params[:wp_notify_url] || params[:ios_notify_url] || params[:android_notify_url]

		user = User.find_or_create_by_id(params[:user_id])
		user.wp_notify_url      = params[:wp_notify_url]      if params[:wp_notify_url]
		user.ios_notify_url     = params[:ios_notify_url]     if params[:ios_notify_url]
		user.android_notify_url = params[:android_notify_url] if params[:android_notify_url]

		unless user.save
			halt 500
		end
	end

	put '/users/:user_id/subscribe' do
		list = List.find_by_id(params[:list_id])
		user = User.find_by_id(params[:user_id])
		halt 404 unless list && user
		list.users << user
		return if list.save
		halt 500
	end

	put '/users/:user_id/unsubscribe' do
		list = List.find_by_id(params[:list_id])
		user = User.find_by_id(params[:user_id])
		halt 404 unless list && user
		list.users.delete(user)
		return if list.save
		halt 500
	end
end
