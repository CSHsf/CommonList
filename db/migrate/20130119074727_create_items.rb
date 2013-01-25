class CreateItems < ActiveRecord::Migration
	def change
		create_table :items do |t|
			t.string :name
			t.boolean :needed, :null => false, :default => false
			t.boolean :deleted, :null => false, :default => false
			t.references :list
			t.timestamps
		end
	end
end
