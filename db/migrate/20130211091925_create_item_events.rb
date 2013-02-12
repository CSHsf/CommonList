class CreateItemEvents < ActiveRecord::Migration
	def change
		create_table :item_events do |t|
			t.references :item
			t.boolean :needed, :null => false, :default => false
			t.boolean :deleted, :null => false, :default => false
			t.column :updated_at, :datetime
		end
	end
end
