class ChangeListIdToUuid < ActiveRecord::Migration
	def change
		change_column :lists, :id, :uuid
	end
end
