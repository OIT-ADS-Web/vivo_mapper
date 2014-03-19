java_import 'com.hp.hpl.jena.rdf.model.ModelFactory'
java_import 'com.hp.hpl.jena.query.QueryFactory'
java_import 'com.hp.hpl.jena.query.QueryExecutionFactory'
java_import 'com.hp.hpl.jena.query.ResultSetFormatter'

require 'vivo_mapper/rdb'
require 'vivo_mapper/mapper'
require 'vivo_mapper/loaders/difference_loader'
require 'vivo_mapper/loaders/simple_loader'
require 'observer'

module VivoMapper
  class ImportManager
    include Observable

    attr_reader :config, :logger

    def initialize(config,logger)
      @config = config
      @logger = logger
    end

    def simple_import(name, resources=[], store_type=:sdb)
      load_resources(name, resources)
      store(name, 'destination',store_type) do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::SimpleLoader.new(destination_model, logger)
          loader.add_model(incoming_model)
        end 
      end
    end

    def difference_import(name, resources=[],store_type=:sdb)
      load_resources(name, resources)
      store(name, 'destination',store_type) do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::DifferenceLoader.new(destination_model, logger)
          loader.import_model(incoming_model)
        end
      end
    end

    def generic_individual_difference_import(uri, name, resources=[],store_type=:sdb,options={})
      load_resources(name, resources)
      begin
        map_obj = options.fetch(:map_object) {eval "#{name}.mapping"}
      rescue
        map_obj=EmptyMap
      end 
      store(name, 'destination',store_type) do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::DifferenceLoader.new(destination_model, logger)
          diff_model = map_obj.graph_for(uri, destination_model, options)
          loader.import_model(incoming_model, diff_model)
        end
      end
    end

    def individual_difference_import(duid, name, resources=[],store_type=:sdb)
      person = VivoMapper::Person.new(:uid => duid)
      person_uri = person.mapping.uri(@config.namespace,person)
      generic_individual_difference_import(person_uri, name, resources, store_type)
    end

    def remove_graph(name,graph,store_type=:sdb)
      store(name, 'destination',store_type) do |destination_model|
        loader = VivoMapper::SimpleLoader.new(destination_model, logger)
        loader.remove_model(graph)
      end
    end

    def simple_removal(name, resources=[],store_type=:sdb)
      load_resources(name,resources,'remove')
      store(name, 'destination',store_type) do |destination_model|
        store(name, 'incoming') do |incoming_model|
          loader = VivoMapper::SimpleLoader.new(destination_model, logger)
          loader.remove_model(incoming_model)
        end
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

    def archive_metadata(model_name)
      archive_destination_model(:rdb,model_name)
    end

    def archive_destination_model(format, model_name)
      store(model_name, 'archive') do |archive_model|
        store(model_name, 'destination', format) do |destination_model|
          archive_model.remove_all
          archive_model.add(destination_model)
        end
      end
    end

    def restore_archived_metadata(model_name)
      store(model_name, 'archive') do |archive_model|
        store(model_name, 'destination', :rdb) do |destination_model|
          destination_model.remove_all
          destination_model.add(archive_model)
        end
      end
    end

    def load_resources(name, resources=[],transaction_type='add')
      changed; notify_observers(resources)
      truncate('incoming')
      store(name, 'incoming') do |model|
        mapper = VivoMapper::Mapper.new(config.namespace, model, config.ontology_model)
        resources.each { |r| mapper.map_resource(r)}
      end
    end

    def export(name, store_name, format=:sdb)
      dt=Time.now.strftime("%Y%m%d")
      file_name="#{Rails.root}/log/#{name}_#{dt}.rdf" #TODO: eliminate Rails reference
      output_stream=java.io.FileOutputStream.new(file_name)
      store(name, store_name, format) do |model|
        model.write(output_stream,"RDF/XML")
      end
    end

    def truncate(store_name)
      config.send("#{store_name}_sdb").truncate
    end

    def differences_between(name, first_model_name, second_model_name)
      store(name, first_model_name) do |first|
        store(name, second_model_name) do |second|
          second.difference(first)
        end
      end
    end

    def size(name, s, format=:sdb)
      data_store(s, format).with_named_model(name) {|model| model.size }
    end

    def store(name, s, format=:sdb, &block)
      data_store(s, format).with_named_model(fully_qualified_name(name)) {|model| block.call(model) }
    end

    def fully_qualified_name(name)
      case name
      when 'Inference'
        "http://vitro.mannlib.cornell.edu/default/vitro-kb-inf"
      when 'Inference2'
        "http://vitro.mannlib.cornell.edu/default/vitro-kb-2"
      else
        "https://vivo.duke.edu/a/graph/#{name}"
      end
    end

    def union(s, format=:sdb, &block)
      data_store(s, format).with_union_model {|model| block.call(model) }
    end

    def data_store(s, format=:sdb)
      result = config.send("#{s}_sdb")
      if format == :rdb
        result = VivoMapper::RDB.from_sdb(result)
      end
      result
    end

    def get_from_destination(model_name, query_string, variable_name)
      results = []
      return_results = []
      store(model_name, 'destination') do |model|
        query = QueryFactory.create(query_string)
        item_qexec = QueryExecutionFactory.create(query, model)
        results = item_qexec.execSelect()
        while results.has_next do 
          return_results << results.next.get(variable_name).to_s
        end
      end
      return return_results
    end
 
  end

end

