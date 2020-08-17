require 'rubygems'
require 'yaml'
require 'vivo_mapper/sdb'

java_import 'com.hp.hpl.jena.rdf.model.ModelFactory'
java_import 'com.hp.hpl.jena.util.FileManager'

module VivoMapper
  class Config

    attr_reader :namespace, :ontology_model, :destination_model_name,
                :incoming_sdb, :archive_sdb, :destination_sdb, :listeners

    def self.load_from_file(file_name, mode='development')
      configs = YAML.load(File.read(file_name))
      config = configs[mode]
      self.new(config)
    end

    def initialize(config={})
      @namespace      = config['namespace']
      @destination_model_name = config['destination_model_name']
      ['incoming','archive','destination'].each do |phase|
        db_name    = config[phase]['sdb']
        username   = config[phase]['username']
        password   = config[phase]['password']
        driver     = config[phase]['driver']
        db_type    = config[phase]['db_type']
        db_layout  = config[phase]['db_layout']

        @incoming_sdb = VivoMapper::SDB.new("#{db_name}#{object_id}#{Random.rand(5000)}", username, password, driver, db_type, db_layout) if phase == 'incoming'
        @archive_sdb = VivoMapper::SDB.new(db_name, username, password, driver, db_type, db_layout) if phase == 'archive'
        @destination_sdb = VivoMapper::SDB.new(db_name, username, password, driver, db_type, db_layout) if phase == 'destination'
      end
      add_listeners(config['destination'])
      @ontology_model = config[:ontology_model] || ModelFactory.create_ontology_model
    end

    def read_ontology_file(filename)
      FileManager.get.readModel(@ontology_model,filename)
    end

    def add_listeners(config)
      @listeners = []
      if config.has_key?("listeners")
        config["listeners"].each do |listener|
          # less forgiving constantize method from active_support
          names = listener.split('::')
          names.shift if names.empty? || names.first.empty?
          
          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
          
          @listeners << constant
        end
      end

    end

  end
end

