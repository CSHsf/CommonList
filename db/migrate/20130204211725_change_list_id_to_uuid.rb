class ChangeListIdToUuid < ActiveRecord::Migration
	def change
		# We can't use change_column because PG can't cast an int to a uuid.
		# Drop the column and create a new one instead.
		remove_column :lists, :id
		add_column :lists, :id, :uuid
	end
end
