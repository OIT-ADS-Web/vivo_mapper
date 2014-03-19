require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/mapper_spec_helper'

require 'vivo_mapper/loaders/difference_loader'
require 'vivo_mapper/rdf_prefixes'

describe VivoMapper::DifferenceLoader do

  it "should initialize with destination Jena models" do
    destination_model = TestJenaObjects.empty_model

    dl = VivoMapper::DifferenceLoader.new(destination_model)
    dl.destination_model.should equal(destination_model)
  end

  describe "responding to import_model with a non-empty incoming model" do
    include RdfPrefixes

    before(:all) do
      @incoming_model = TestJenaObjects.test_person_modified_model
      @destination_model = TestJenaObjects.test_person_model
      @ontology_model = TestJenaObjects.vivo_ontology_model

      @deleted_appointment = @destination_model.get_resource("https://vivo-dev.oit.duke.edu/individual/n2776")
      @dl = VivoMapper::DifferenceLoader.new(@destination_model)
      @dl.import_model(@incoming_model)
    end

    it "should add all statements in the incoming model that are not already in the destination model" do
      # TODO: make a factory to avoid specific assertions about what's in the test files
      changed_person = @dl.destination_model.get_resource("https://vivo-dev.oit.duke.edu/individual/n8014")

      middle_name = @ontology_model.get_ont_property(core("middleName"))
      changed_person.get_property(middle_name).get_string.should == "ADDED"

      last_name = @ontology_model.get_ont_property(foaf("lastName"))
      changed_person.get_property(last_name).get_string.should == "CHANGED"
    end

    it "should remove all statements not in the incoming model from the destination model" do
      @destination_model.contains_any(@deleted_appointment.list_properties).should be false
    end

    it "should result in destination containing all statements from incoming" do
      @destination_model.contains_all(@incoming_model).should be true
    end

  end

end
