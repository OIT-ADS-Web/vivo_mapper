require 'observer'

module VivoMapper
  class Loader
    include Observable
    attr_reader :destination_model, :logger

    def initialize(destination_model, logger)
      @destination_model, @logger = destination_model, logger
    end

    def log_data(command, model)
      output_stream=java.io.ByteArrayOutputStream.new
      model.write(output_stream,"RDF/XML")
      @logger.info <<-EOS
        #{command}:
        #{output_stream.to_string}
      EOS
    end

  end
end
