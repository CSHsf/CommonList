class AddTitleToLists < ActiveRecord::Migration
	def change
		add_column :lists, :title, :string, :null => false, :default => ''
	end
end
