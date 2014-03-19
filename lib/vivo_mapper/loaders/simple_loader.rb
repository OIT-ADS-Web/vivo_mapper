require 'vivo_mapper/loader'

module VivoMapper
  class SimpleLoader < Loader

    def add_model(incoming_model)
      @destination_model.add(incoming_model)
      log_data(:add_to_destination, incoming_model)
      incoming_model.list_objects.entries.each {|entry| changed;notify_observers(entry,'add') }
    end

    def remove_model(incoming_model)
      @destination_model.remove(incoming_model)
      log_data(:remove_from_destination, incoming_model)
      incoming_model.list_objects.entries.each {|entry| changed;notify_observers(entry,'remove') }
    end

  end
end
