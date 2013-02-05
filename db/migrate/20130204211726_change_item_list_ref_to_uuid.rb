class ChangeItemListRefToUuid < ActiveRecord::Migration
	def change
		# We can't use change_column because PG can't cast an int to a uuid.
		# Drop the column and create a new one instead.
		remove_column :items, :list_id
		add_column :items, :list_id, :uuid
	end
end
