class User < ActiveRecord::Base
	self.primary_key = :id

	has_many :lists

	attr_accessible :id, :wp_notify_url, :ios_notify_url, :android_notify_url
end
