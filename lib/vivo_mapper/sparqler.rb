java_import 'com.hp.hpl.jena.rdf.model.ModelFactory'
java_import 'com.hp.hpl.jena.query.QueryFactory'
java_import 'com.hp.hpl.jena.query.QueryExecutionFactory'

module VivoMapper
  class SparqlSelector

    def results
      @bindings
    end

    def initialize(sparql, model)
      @sparql = sparql
      @variables = []
      @bindings = []
      @model = model
    end

    def execute
      query = QueryFactory.create(@sparql)
      qexec = QueryExecutionFactory.create(query, @model)
      results = qexec.execSelect()
      @variables = results.get_result_vars.to_a
      while results.has_next
        result = results.next
        row = {}
        @variables.each do |v|
          row[v.to_sym] = get_value(result, v)
        end
        @bindings << row
      end
      qexec.close()

      self
    end

    def get_value(result, v)
      value = result.get("?#{v}")
      value.nil? ? value : value.to_s
    end

    # TODO: this is broken
    def as_csv(delimeter=",", quote_char='"')
      result = []
      result << @variables.collect{|v| "#{quote_char}#{v}#{quote_char}"}
      @bindings.each do |binding|
        binding_result = []
        @variables.each do |variable|
          binding_result << "#{quote_char}#{binding.get("?#{variable}").to_s}#{quote_char}"
        end
        result << binding_result
      end
      result.collect{|row| row.join(delimeter)}.join("\n")
    end
  end

  class SparqlConstructor

    def initialize(sparqls=[])
    end

  end
end
