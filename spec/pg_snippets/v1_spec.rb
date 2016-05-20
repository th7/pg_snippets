require 'pg_snippets/v1'

describe PgSnippets::V1 do
  generates_the_expected_sql = Proc.new { expect(actual).to eq expected }

  describe '.create_sequence' do
    let(:actual) { PgSnippets::V1.create_sequence }
    let(:expected) { 'create sequence change_id_sequence;' }
    it(&generates_the_expected_sql)
  end

  describe '.create_update_metadata_function' do
    let(:actual) { PgSnippets::V1.create_update_metadata_function }
    let(:expected) {
"create function update_metadata() returns trigger as $$
begin
  NEW.change_id := nextval('change_id_sequence');
  NEW.updated_at := now();
  NEW.created_at := now();
  return NEW;
end;
$$  language plpgsql;" }
    it(&generates_the_expected_sql)
  end

  describe '.setup_db' do
    let(:actual) { PgSnippets::V1.setup_db }
    let(:expected) { PgSnippets::V1.create_sequence + PgSnippets::V1.create_update_metadata_function }
    it(&generates_the_expected_sql)
  end

  describe '.add_metadata_fields' do
    let(:actual) { PgSnippets::V1.add_metadata_fields('table_name') }
    let(:expected) {
'alter table table_name
add column change_id bigint
,add column updated_at timestamp
,add column created_at timestamp;'
    }
    it(&generates_the_expected_sql)
  end

  describe '.add_change_column_index' do
    let(:actual) { PgSnippets::V1.add_change_column_index('table_name') }
    let(:expected) {
'create index on table_name(change_id);'
    }
    it(&generates_the_expected_sql)
  end

  describe '.add_suppress_redundant_updates_trigger' do
    let(:actual) { PgSnippets::V1.add_suppress_redundant_updates_trigger('table_name') }
    let(:expected) {
'create trigger z_suppress_redundant_updates_on_table_name
before update on table_name
for each row execute procedure suppress_redundant_updates_trigger();'
    }
    it(&generates_the_expected_sql)
  end

  describe '.add_update_metadata_trigger' do
    let(:actual) { PgSnippets::V1.add_update_metadata_trigger('table_name') }
    let(:expected) {
'create trigger zz_update_metadata_on_table_name
before insert or update on table_name
for each row execute procedure update_metadata();'
    }
    it(&generates_the_expected_sql)
  end

  describe '.setup_table' do
    let(:actual) { PgSnippets::V1.setup_table('table_name') }
    let(:expected) { PgSnippets::V1.add_metadata_fields('table_name') + PgSnippets::V1.add_change_column_index('table_name') + PgSnippets::V1.add_suppress_redundant_updates_trigger('table_name') + PgSnippets::V1.add_update_metadata_trigger('table_name') }
    it(&generates_the_expected_sql)
  end
end
