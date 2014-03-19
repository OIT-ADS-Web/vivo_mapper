require 'vivo_mapper/loader'

module VivoMapper
  class DifferenceLoader < Loader
    attr_reader  :add_change_model, :remove_model
 
    def differences(incoming_model, diff_model=@destination_model)
      incoming_model.difference(diff_model)
    end

    def import_model(incoming_model, diff_model=@destination_model)
      @add_change_model = incoming_model.difference(diff_model)
      @remove_model     = diff_model.difference(incoming_model)

      @destination_model.add(add_change_model)
      log_data(:add_to_destination, add_change_model)
      add_change_model.list_objects.entries.each {|entry| changed;notify_observers(entry,'add') }

      @destination_model.remove(remove_model)
      log_data(:remove_from_destination,remove_model)
      remove_model.list_objects.entries.each {|entry| changed;notify_observers(entry,'remove') }
 
    end
  end
end
