class Item < ActiveRecord::Base
	belongs_to :list

	attr_accessible :name, :needed, :deleted

	def as_json(options={})
		attributes.slice('id', 'name', 'deleted', 'needed')
	end
end
