# VivoMapper

Duke's JRuby library using the Jena library to ingest arbitrary RDF-mapped data
into a Vivo SDB store. 

Note:  this was designed so that each call represents an update of one 
component of a person's profile. (For example: a refresh of all Prof Smith's
publications)

The library expects 3 configurable items per call:

1. mappable resource: A data-structure-type object which serves as a container for 
the data of a single entity (ie. a single publication). A collection of these 
resources are passed to vivo_mapper which combines them all into a single graph
representing a person's most recent, updated version of that section of their profile.

2. map: Tells vivo_mapper how the values in a mappable resource are to be represented 
in Vivo. This map consists primarily of a collection of key-value pairs where a 
key is the resource instance variable name and the value is the predicate to which 
that instance variable value should be mapped.

3. SparQL construct query: vivo_mapper will run this against the current SDB store to 
create a graph of data already in Vivo. The resulting graph will be compared against 
the graph created from the combined resources passed in.  vivo_mapper diffs the two 
graphs. The differences found (adds and removes) are then applied to the SDB 
store to perform the actual update.

Note: this ingest process bypasses the Vivo app entirely. The relationship is that both
communicate with the same data store.

## Installation

Add this line to your application's Gemfile:

    gem 'vivo_mapper'

And then execute:

    $ bundle

Then, to get the jar dependencies, execute:

    $ jbundle

## Usage

Version 1.0 of this gem is updated to support VIVO 1.7. VIVO 1.6 may also work,
but is not tested.

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

You can add observers to loads by instantiating an `import_manager`, and then
calling `import_manager.add_observer(some_observer)`. Each time triples are removed or added, `#update` will be called on each observer for each triple, like so:

    observer.update(entry, 'add')

or

    observer.update(entry, 'remove')

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

