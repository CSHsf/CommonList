class List < ActiveRecord::Base
	has_many :items
	before_create :create_uuid

	self.primary_key = :id

	def as_json(options={})
		attributes.slice('id', 'title', 'items').merge(:items => items)
	end

	private

	def create_uuid
		self.id = UUIDTools::UUID.timestamp_create.to_s
	end
end
