class User < ActiveRecord::Base
	self.primary_key = :id

	has_and_belongs_to_many :lists

	attr_accessible :id, :wp_notify_url, :ios_notify_url, :android_notify_url

	def notify(*items)
		notify_wp(items)      unless wp_notify_url.empty?
		notify_ios(items)     unless ios_notify_url.empty?
		notify_android(items) unless android_notify_url.empty?
	end

	protected

	def notify_wp(items)
		items.each do |item|
			p "Hey #{id} on WP, #{item.name} is now #{item.needed ? 'needed' : 'unneeded'}!"
		end
	end

	def notify_ios(items)
		items.each do |item|
			p "Hey #{id} on iOS, #{item.name} is now #{item.needed ? 'needed' : 'unneeded'}!"
		end
	end

	def notify_android(items)
		items.each do |item|
			p "Hey #{id} on Android, #{item.name} is now #{item.needed ? 'needed' : 'unneeded'}!"
		end
	end
end
