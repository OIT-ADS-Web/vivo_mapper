# VivoMapper

Duke's JRuby library using the Jena library to ingest arbitrary RDF-mapped data
into a Vivo SDB store. The library expects to receive an incoming graph (or
does it receive a resource and a map??) and a SparQL construct query, which it
runs against an SDB store in order to create a graph of live data. It then
performs a diff, generating a list of adds and removes, which it then executes
against the SDB store. 

Note that this ingest process bypasses the Vivo app entirely. The relationship
is that both communicate with the same data store.

## Installation

Add this line to your application's Gemfile:

    gem 'vivo_mapper'

And then execute:

    $ bundle

Then, to get the jar dependencies, execute:

    $ jbundle

## Usage

TODO: Explain resources and maps that have to be provided; the duck types that
are required.

This gem does not currently contain the code needed to connect to an SDB store.
TODO: We need to document what kind of object has to be provided to the mapper
in order to connect to the DB. If you are trying to run this and we have not
documented this, please be in touch and let us know so we can fix it.

TODO: Document how the mapper does some inferencing (inverses, super-types). At
Duke, running Vivo 1.5, we turned off the Vivo inferencing engine due to
performance concerns.

TODO: Add examples of use

## Jar Dependencies

This app is designed to be run in JRuby and depends on a couple jar files. We
use the tool [jbundler](https://github.com/mkristian/jbundler) to manage those
dependencies.

## Contributing

In our larger ingest app, we have a higher-level test suite that runs through
this code, but getting working specs in this gem is a TODO. Contributions
welcome.

TODO: Convert RDFPrefixes to something that can be configured outside the gem.
(Duke extensions not generally applicable.)

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
