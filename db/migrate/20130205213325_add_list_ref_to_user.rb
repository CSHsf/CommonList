class AddListRefToUser < ActiveRecord::Migration
	def change
		add_column :users, :list_id, :uuid
	end
end
