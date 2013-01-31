class Item < ActiveRecord::Base
	belongs_to :list

	def as_json(options={})
		attributes.slice('id', 'name', 'deleted', 'needed')
	end
end
