class List < ActiveRecord::Base
	self.primary_key = :id

	has_many :items
	has_many :users

	attr_accessible :id, :title

	def as_json(options={})
		attributes.slice('id', 'title', 'items').merge(:items => items)
	end
end
