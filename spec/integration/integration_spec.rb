require 'spec_helper'
require 'pg'


describe 'integration tests' do
  before do
    admin_conn = PG::Connection.new(host: '192.168.33.10', user: 'postgres')
    admin_conn.exec('drop database if exists pg_snippets_test')
    admin_conn.exec('create database pg_snippets_test')
    $conn = PG::Connection.new(host: '192.168.33.10', user: 'postgres', dbname: 'pg_snippets_test')
  end

  after do
    $conn.close
  end

  let(:conn) { $conn }

  def setup_db
    conn.exec(PgSnippets::V1.setup_db)
  end

  def setup_table
    conn.exec(PgSnippets::V1.setup_table('test_table'))
  end

  it 'the db is available' do
    expect { conn.exec('select 1') }.not_to raise_error
  end

  describe 'db setup' do
    it 'does not raise an error' do
      expect { setup_db }.not_to raise_error
    end

    describe 'create sequence' do
      it 'does not raise an error' do
        expect { conn.exec(PgSnippets::V1.create_sequence) }.not_to raise_error
      end
    end

    describe 'create update metadata function' do
      it 'does not raise an error' do
        expect { conn.exec(PgSnippets::V1.create_update_metadata_function) }.not_to raise_error
      end
    end
  end

  describe 'table setup' do
    before do
      setup_db
      conn.exec('create table test_table(id serial primary key)')
    end

    it 'does not raise an error' do
      expect { setup_table }.not_to raise_error
    end
  end

  describe 'manipulating data' do
    before do
      setup_db
      conn.exec('create table test_table(id serial primary key, data text)')
      setup_table
    end

    describe 'inserting data' do
      before do
        conn.exec("insert into test_table(data) values('junk')")
      end

      let(:row) { conn.exec('select * from test_table limit 1').first }

      it 'has metadata' do
        expect(row['change_id']).to eq '1'
        expect(row['updated_at']).not_to be_nil
        expect(row['created_at']).not_to be_nil
      end
    end

    describe 'updating data' do
      before do
        conn.exec("insert into test_table(data) values('junk')")
        conn.exec("update test_table set data='new junk'")
      end

      let(:row) { conn.exec('select * from test_table limit 1').first }

      it 'increments the change_id' do
        expect(row['change_id']).to eq '2'
      end
    end

    describe 'making a redundant update' do
      before do
        conn.exec("insert into test_table(data) values('junk')")
        conn.exec("update test_table set data='junk'")
      end

      let(:row) { conn.exec('select * from test_table limit 1').first }

      it 'does not increment the change_id' do
        expect(row['change_id']).to eq '1'
      end
    end
  end
end
