class List < ActiveRecord::Base
	has_many :items

	def as_json(options={})
		attributes.slice('id', 'name', 'items').merge(:items => items)
	end
end
