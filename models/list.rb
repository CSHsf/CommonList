class List < ActiveRecord::Base
	self.primary_key = :id

	has_many :items

	def as_json(options={})
		attributes.slice('id', 'title', 'items').merge(:items => items)
	end
end
