class CreateListsUsersJoinTable < ActiveRecord::Migration
	def change
		create_table :lists_users, :id => false do |t|
			t.column :list_id, :uuid
			t.column :user_id, :uuid
		end
	end
end
