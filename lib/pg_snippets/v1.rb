module PgSnippets
  module V1
    class << self
      CHANGE_ID  = 'change_id'
      SEQUENCE   = "#{CHANGE_ID}_sequence"
      UPDATED_AT = 'updated_at'
      CREATED_AT = 'created_at'

      def create_sequence(name=SEQUENCE)
        "create sequence #{name};"
      end

      def create_update_metadata_function(change_column_name: CHANGE_ID, sequence_name: SEQUENCE, updated_at_column_name: UPDATED_AT, created_at_column_name: CREATED_AT)
"create function update_metadata() returns trigger as $$
begin
  NEW.#{change_column_name} := nextval('#{sequence_name}');
  NEW.#{updated_at_column_name} := now();
  NEW.#{created_at_column_name} := now();
  return NEW;
end;
$$  language plpgsql;"
      end

      def setup_db
        create_sequence + create_update_metadata_function
      end

      def add_metadata_fields(table_name, change_column_name: CHANGE_ID, updated_at_column_name: UPDATED_AT, created_at_column_name: CREATED_AT)
"alter table #{table_name}
add column #{change_column_name} bigint
,add column #{updated_at_column_name} timestamp
,add column #{created_at_column_name} timestamp;"
      end

      def add_change_column_index(table_name, change_column_name: CHANGE_ID)
"create index on #{table_name}(#{change_column_name});"
      end

      def add_suppress_redundant_updates_trigger(table_name)
"create trigger z_suppress_redundant_updates_on_#{table_name}
before update on #{table_name}
for each row execute procedure suppress_redundant_updates_trigger();"
      end

      def add_update_metadata_trigger(table_name)
"create trigger zz_update_metadata_on_#{table_name}
before insert or update on #{table_name}
for each row execute procedure update_metadata();"
      end

      def setup_table(table_name)
        add_metadata_fields(table_name) + add_change_column_index(table_name) + add_suppress_redundant_updates_trigger(table_name) + add_update_metadata_trigger(table_name)
      end
    end
  end
end
