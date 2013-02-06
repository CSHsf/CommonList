class AddNotifyUrlsToUser < ActiveRecord::Migration
	def change
		add_column :users, :wp_notify_url, :string, :null => false, :default => ''
		add_column :users, :ios_notify_url, :string, :null => false, :default => ''
		add_column :users, :android_notify_url, :string, :null => false, :default => ''
	end
end
