# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vivo_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "vivo_mapper"
  spec.version       = VivoMapper::VERSION
  spec.authors       = ["Jim Wood", "Sheri Tibbs", "Richard Outten", "Patrick McElwee"]
  spec.email         = ["scholars-tech@duke.edu"]
  spec.requirements  << "jar 'com.hp.hpl.jena:sdb', '1.3.4'"
  spec.requirements  << "jar 'com.h2database:h2', '1.3.175'"
  spec.requirements  << "jar 'mysql:mysql-connector-java', '5.1.14'"
  spec.description   = %q{A mapper to load data into Vivo.}
  spec.summary       = %q{JRuby library using Jena to ingest RDF-mapped data into a Vivo SDB store.}
  spec.homepage      = "http://scholars.duke.edu"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jbundler", "~> 0.5.5"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
