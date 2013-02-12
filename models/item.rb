class Item < ActiveRecord::Base
	belongs_to :list
	has_many :events, :class_name => 'ItemEvent'

	def as_json(options={})
		attributes.slice('id', 'name', 'deleted', 'needed')
	end
end
