# PgSnippets

Generate some SQL to set up your PG database and tables

## Usage

```
conn = PG::Connection.new(host: 'yourdbhost', user: 'yourdbuser', dbname: 'yourdbname')
conn.exec(PgSnippets::V1.setup_db) # adds change id sequence and metadata function
conn.exec('create table my_table(my_field1 serial primary key, my_field2 text')
conn.exec(PgSnippets::V1.setup_table('my_table')) # adds created_at, updated_at, and change_id -- also uses hooks to keep them correctly updated

### if using ActiveRecord, let the db handle metadata timestamps
class MyTable
  self.record_timestamps = false
end
```

As long as you remember which change_id you saw last, you can always figure out which data in my_table has changed.

The PgSnippets::V* namespace is to make sure the SQL never changes. Any chnges to existing SQL will go into a new version namespace, so your migrations stay reproducable even if you upgrade this gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pg_snippets. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

