java_import 'com.hp.hpl.jena.rdf.model.ModelFactory'
java_import 'com.hp.hpl.jena.query.QueryFactory'
java_import 'com.hp.hpl.jena.query.QueryExecutionFactory'
java_import 'com.hp.hpl.jena.query.ResultSetFormatter'

require 'vivo_mapper/mapper'
require 'vivo_mapper/loaders/difference_loader'
require 'vivo_mapper/loaders/simple_loader'

module VivoMapper
  class ImportManager

    attr_reader :config, :logger, :observers, :listeners

    def initialize(config,logger)
      @config = config
      @logger = logger
      @observers = []
      @listeners = config.listeners
    end

    def add_observer(observer)
      @observers << observer
    end

    def _add_observers_to(loader)
      observers.each do |observer|
        loader.add_observer(observer)
      end
    end

    def simple_import(name, resources=[])
      load_resources(name, resources)
      store(name, 'destination') do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::SimpleLoader.new(destination_model, logger)
          _add_observers_to(loader)
          loader.add_model(incoming_model)
        end 
      end
    end

    def difference_import(name, resources=[])
      load_resources(name, resources)
      store(name, 'destination') do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::DifferenceLoader.new(destination_model, logger)
          _add_observers_to(loader)
          loader.import_model(incoming_model)
        end
      end
    end

    def generic_individual_difference_import(uri, name, resources=[],options={})
      load_resources(name, resources)
      begin
        map_obj = options.fetch(:map_object) {eval "#{name}.mapping"}
      rescue
        map_obj=EmptyMap
      end 
      store(name, 'destination') do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::DifferenceLoader.new(destination_model, logger)
          _add_observers_to(loader)
          diff_model = map_obj.graph_for(uri, destination_model, options)
          loader.import_model(incoming_model, diff_model)
        end
      end
    end

    def individual_difference_import(duid, name, resources=[])
      person = VivoMapper::Person.new(:uid => duid)
      person_uri = person.mapping.uri(@config.namespace,person)
      generic_individual_difference_import(person_uri, name, resources)
    end

    def remove_graph(name,graph)
      store(name, 'destination') do |destination_model|
        loader = VivoMapper::SimpleLoader.new(destination_model, logger)
        _add_observers_to(loader)
        loader.remove_model(graph)
      end
    end

    def clear_destination(model_name)
      store(model_name, 'destination') do |model|
        model.remove_all
      end
    end

    def clear_destinations(model_names)
      model_names.each do |model_name|
        clear_destination(model_name)
      end
    end

    def load_resources(name, resources=[])
      truncate('incoming')
      store(name, 'incoming') do |model|
        mapper = VivoMapper::Mapper.new(config.namespace, model, config.ontology_model)
        resources.each { |r| mapper.map_resource(r)}
      end
    end

    def truncate(store_name)
      config.send("#{store_name}_sdb").truncate
    end

    def size(name, s)
      data_store(s).with_named_model(name) {|model| model.size }
    end

    def store(name, s, &block)
      data_store(s).with_named_model(fully_qualified_name(name)) do |model|
        listeners.each do |listener|
          listener.add_model(name, s, model)
        end
        block.call(model)
      end
    end

    def fully_qualified_name(name)
      case name
      when 'Inference'
        "http://vitro.mannlib.cornell.edu/default/vitro-kb-inf"
      when 'Inference2'
        "http://vitro.mannlib.cornell.edu/default/vitro-kb-2"
      when 'InferenceRebuild'
        "http://vitro.mannlib.cornell.edu/default/vitro-kb-inf-rebuild"
      else
        "https://vivo.duke.edu/a/graph/#{name}"
      end
    end

    def union(s, &block)
      data_store(s).with_union_model {|model| block.call(model) }
    end

    def data_store(s)
      config.send("#{s}_sdb")
    end

  end

end

