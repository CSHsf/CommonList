class ChangeUserIdToUuid < ActiveRecord::Migration
	def change
		remove_column :users, :username

		# We can't use change_column because PG can't cast an int to a uuid.
		# Drop the column and create a new one instead.
		remove_column :users, :id
		add_column :users, :id, :uuid
	end
end
