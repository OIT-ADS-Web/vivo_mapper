java_import 'com.hp.hpl.jena.ontology.OntModelSpec'
java_import 'com.hp.hpl.jena.rdf.model.ModelFactory'
java_import 'com.hp.hpl.jena.datatypes.xsd.XSDDatatype'

require 'vivo_mapper/rdf_prefixes'

module VivoMapper
  class Mapper
    include RdfPrefixes

    attr_reader :namespace, :model, :ontology_model

    def initialize(namespace, model, ontology_model)
      @namespace, @model, @ontology_model = namespace, model, ontology_model
    end

    def map_resource(mappable)
      return if mappable.nil?
      resource = @model.create_resource(mappable.uri(namespace))
      unless mappable.stubbed
        assign_types(resource, mappable)
        assign_properties(resource, mappable)
      end
      resource
    end

    def assign_types(resource, mappable)
      most_specific_type_uri = mappable.most_specific_type
      return unless most_specific_type_uri

      type_class =                  _get_ontology_class_by_uri(most_specific_type_uri)
      most_specific_type_property = _get_ontology_property_by_uri(vitro("mostSpecificType"))
      type_property =               _get_ontology_property_by_uri(rdf("type"))

      most_specific_type_resource = _create_model_resource_from_uri(most_specific_type_uri)

      resource.add_property(most_specific_type_property, most_specific_type_resource)
      resource.add_property(type_property, most_specific_type_resource)

      owl_thing_resource = _create_model_resource_from_uri(owl("Thing"))
      resource.add_property(type_property, owl_thing_resource)

      type_class_iter = type_class.list_super_classes
      while type_class_iter.has_next
        super_type_class = type_class_iter.next
        super_type_class_uri = super_type_class.get_uri
        if super_type_class_uri
          super_type_resource = _create_model_resource_from_uri(super_type_class_uri)
          resource.add_property(type_property,super_type_resource)
        end
      end
    end

    def assign_properties(resource, mappable)
      mappable.properties.each do |predicate_uri,object_value|
        Array(object_value).each do |obj|
          map_predicate_to_object(predicate_uri, obj,resource)
        end
      end
    end

    def map_predicate_to_object(predicate_uri,object_value,resource)
      unless object_value.nil?
        predicate = _get_ontology_property_by_uri(predicate_uri)

        if predicate.is_object_property
          if object_value.respond_to? :mapping
            # recursively map sub object, add object property linking to resource
            linked_resource = map_resource(object_value)
            resource.add_property(predicate, linked_resource)
          else
             # assume object value is resource uri
             linked_resource = _create_model_resource_from_uri(object_value)
             resource.add_property(predicate,linked_resource)
          end

          inverse_properties_iter = predicate.list_inverse
          while inverse_properties_iter.has_next
            inverse_predicate = inverse_properties_iter.next
            linked_resource.add_property(inverse_predicate,resource)
          end

          if predicate.is_symmetric_property
            linked_resource.add_property(predicate,resource)
          end
        else
          case object_value
          when DateTime
            resource.add_property(predicate,model.create_typed_literal(object_value.to_s[0..18],XSDDatatype::XSDdateTime))
          when Integer
            resource.add_property(predicate,model.create_typed_literal(object_value.to_s[0..18],XSDDatatype::XSDdecimal))
          when *[true, false]
            resource.add_property(predicate,model.create_typed_literal(object_value.to_s[0..18],XSDDatatype::XSDboolean))
          when Array
            # assumes content of array is strings
            object_value.each {|r| resource.add_property(predicate, r)}
          else
            resource.add_property(predicate,object_value)
          end
        end
      end
    end

    private

    def _get_ontology_property_by_uri(uri)
      ont_property = ontology_model.get_ont_property(uri)
      raise "Property: #{uri} not found in ontology" unless ont_property
      ont_property
    end

    def _get_ontology_class_by_uri(uri)
      ont_class = ontology_model.get_ont_class(uri)
      raise "Class: #{uri} not found in ontology" unless ont_class
      ont_class
    end

    def _create_model_resource_from_uri(uri)
      model.create_resource(uri)
    end

  end

end

