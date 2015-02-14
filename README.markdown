[![Build Status](https://travis-ci.org/mojolingo/es-reindex.svg)](https://travis-ci.org/mojolingo/es-reindex)

# es-reindex - simple ruby gem for copying ElasticSearch index

Simple ruby gem to copy and reindex ElasticSearch index,
copying index settings and mapping(s).

Progress and time estimation is displayed during the scrolling process.

## Requirements

- Ruby 1.9.3 or newer
- Gems:
  - [elasticsearch](https://github.com/elasticsearch/elasticsearch-ruby)

## Usage (command line)

Refer to script's help:

```bash
$ ./es-reindex.rb -h

Script to copy particular ES index including its (re)creation w/options set
and mapping copied.

Usage:

  ./es-reindex.rb [-r] [-f <frame>] [source_url/]<index> [destination_url/]<index>

    - -r - remove the index in the new location first
    - -f - specify frame size to be obtained with one fetch during scrolling
    - -u - update existing documents (default: only create non-existing)
    - optional source/destination urls default to http://127.0.0.1:9200
```

## Usage (in project)

You can also use it as a PORO:

#### To Copy

```ruby
# Options:
# remove: same as -r
# frame: same as -f
# update: same as -u cli option

options = {
  remove: true,
  update: true
}

ESReindex.copy! 'http://my_server/index', 'http://my_server/index_copy', options
```

#### To Reindex

If you want to reindex the destination from the source without copying the mappings/settings from the source, you can do it as such:

```ruby
ESReindex.reindex! 'http://my_server/index', 'http://my_server/index_copy',
  mappings: -> { set_of_mappings },
  settings: -> { set_of_settings}
```

If using the `.reindex!` method, you MUST pass valid mappings/settings in via the options.

#### Callbacks
There also a set of callbacks you can use:

```ruby
ESReindex.copy! 'http://my_server/index', 'http://my_server/index_copy',
  before_create: ->    { do_something },      # Runs before the (re)creation of the destination index
  after_create:  ->    { do_something_else }, # Runs after the (re)creation of the destinatino index
  before_each:   ->doc { use_the doc },       # Runs before each document is copied
  after_each:    ->doc { foo_bar doc },       # Runs after each document is copied
  after_copy:    ->    { finish_thing }       # Runs after everything is copied over
```

#### Callbacks (guards)

You can also use the `:if` or `:unless` callbacks to prevent the copy/reindexing from occuring if conditions are (un)met.  The source client and destination client are passed in:

```ruby
ESReindex.copy! 'http://my_server/index', 'http://my_server/index_copy',
  if:     ->(sclient,dclient) { Time.now.hour > 20 },                 # Only copy the indexes if it's after 8pm
  unless: ->(sclient,dclient) { Time.now.strftime("%A") == "Friday" } # Never copy on Fridays
```

For a more practical example, see the [reindex integration specs](spec/integration/reindex_spec.rb).

## Changelog

+ __next__:  Add activesupport dependency since es-reindex uses methods from it.
+ __0.3.0__: Add `:if` and `:unless` callbacks
+ __0.2.1__: [BUGFIX] Improve callback presence check
+ __0.2.0__: Lots of bugfixes, use elasticsearch client gem, add .reindex! method and callbacks
+ __0.1.0__: First gem release
+ __0.0.9__: Gemification, Oj -> MultiJSON
+ __0.0.8__: Optimization in string concat (@nara)
+ __0.0.7__: Document header arguments `_timestamp` and `_ttl` are copied as well
+ __0.0.6__: Document headers in bulks are now assembled and properly JSON dumped
+ __0.0.5__: Merge fix for trailing slash in urls (@ichinco), formatting cleanup
+ __0.0.4__: Force create only, update is optional (@pgaertig)
+ __0.0.3__: Yajl -> Oj
+ __0.0.2__: repated document count comparison
+ __0.0.1__: first revision

## Credits

- [Justin Aiken](https://github.com/JustinAiken)
- [Victor Luft](https://github.com/victorluft)

Original script:
  - @geronime
  - @pgaertig

Developed by [Mojo Lingo](http://mojolingo.com).

## License
es-reindex the gem is copyright (c)2014 Mojo Lingo, and released under the terms
of the MIT license. See the LICENSE file for the gory details.

es-reindex is copyright (c)2012 Jiri Nemecek, and released under the terms
of the MIT license. See the LICENSE file for the gory details.
