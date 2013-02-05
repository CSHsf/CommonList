module ActiveRecord
	module ConnectionAdapters
		case ActiveRecord::Base.connection.adapter_name
			when 'SQLite'
				SQLiteAdapter.class_eval do
					def native_database_types_with_uuid_support
						types = native_database_types_without_uuid_support
						types[:uuid] = { :name => 'varchar', :limit => 36 }
						types
					end
					alias_method_chain :native_database_types, :uuid_support
				end
			when 'PostgreSQL'
				PostgreSQLAdapter.class_eval do
					def native_database_types_with_uuid_support
						types = native_database_types_without_uuid_support
						types[:uuid] = { :name => 'uuid' }
						types
					end
					alias_method_chain :native_database_types, :uuid_support
				end

				PostgreSQLColumn.class_eval do
					def simplified_type_with_uuid_support(field_type)
						if field_type == 'uuid'
							:uuid
						else
							simplified_type_without_uuid_support(field_type)
						end
					end
					alias_method_chain :simplified_type, :uuid_support
			end
		end
	end
end
