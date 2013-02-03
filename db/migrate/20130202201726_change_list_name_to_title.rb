class ChangeListNameToTitle < ActiveRecord::Migration
	def change
		rename_column :lists, :name, :title
	end
end
