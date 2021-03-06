module RdfPrefixes
  extend self

  PREFIX_DEFN = {
    "rdf"     => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs"    => "http://www.w3.org/2000/01/rdf-schema#",
    "xsd"     => "http://www.w3.org/2001/XMLSchema#",
    "owl"     => "http://www.w3.org/2002/07/owl#",
    "swrl"    => "http://www.w3.org/2003/11/swrl#",
    "swrlb"   => "http://www.w3.org/2003/11/swrlb#",
    "vitro"   => "http://vitro.mannlib.cornell.edu/ns/vitro/0.7#",
    "auth"    => "http://vitro.mannlib.cornell.edu/ns/vitro/authorization#",
    "bibo"    => "http://purl.org/ontology/bibo/",
    "dcelem"  => "http://purl.org/dc/elements/1.1/",
    "dcterms" => "http://purl.org/dc/terms/",
    "duke"    => "http://vivo.duke.edu/vivo/ontology/duke-extension#",
    "dukeact" => "http://vivo.duke.edu/vivo/ontology/duke-activity-extension#",
    "dukeart" => "http://vivo.duke.edu/vivo/ontology/duke-art-extension#",
    "duke_geo" => "http://vivo.duke.edu/vivo/ontology/duke-geo-extension#",
    "event"   => "http://purl.org/NET/c4dm/event.owl#",
    "foaf"    => "http://xmlns.com/foaf/0.1/",
    "geo"     => "http://aims.fao.org/aos/geopolitical.owl#",
    "pvs"     => "http://vivoweb.org/ontology/provenance-support#",
    "obo"     => "http://purl.obolibrary.org/obo/",
    "vcard"   => "http://www.w3.org/2006/vcard/ns#",
    "scires"  => "http://vivoweb.org/ontology/scientific-research#",
    "skos"    => "http://www.w3.org/2004/02/skos/core#",
    "vpublic" => "http://vitro.mannlib.cornell.edu/ns/vitro/public#",
    "core"    => "http://vivoweb.org/ontology/core#",
    "c4o"     => "http://purl.org/spar/c4o/",
    "vivo"    => "http://vivoweb.org/ontology/core#"
  }

  def obo_experience
    "ARG_2000021"
  end

  def obo_has_contact_info
    "ARG_2000028"
  end

  def obo_contact_info_of
    "ARG_2000029"
  end

  def obo_part_of
    "BFO_0000050"
  end

  def obo_has_part
    "BFO_0000051"
  end

  def obo_participates_in
    "RO_0000056"
  end

  def obo_has_participant
    "RO_0000057"
  end

  def obo_has_output
    "RO_0002234"
  end

  def obo_has_input
    "RO_0002233"
  end

  def obo_information_content_entity
    "IAO_0000030"
  end

  def obo_fills_role
    "RO_0000053"
  end

  def obo_role_fulfilled_by
    "RO_0000052"
  end

  def obo_funding_role
    "ERO_0000224"
  end

  def obo_role_realized_in
    "BFO_0000054"
  end

  def obo_realizes_role
    "BFO_0000055"
  end

  def method_missing(method_sym,*args, &block)
    if prefix = PREFIX_DEFN[method_sym.to_s]
      "#{prefix}#{args.first}"
    else
      super
    end
  end

end
