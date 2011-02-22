require 'workling/clients/base'
require 'carrot'

#
#  An Carrot client
#
module Workling
  module Clients
    class CarrotClient < Workling::Clients::Base
      
      # starts the client. 
      def connect
        begin
          @carrot = Carrot.new(Workling.config || {})
        rescue
          raise WorklingError.new("couldn't start Carrot Client for #{Workling.config.inspect}.)")
        end
        
        unless @namespace = Workling.config[:namespace]
          raise WorklingError.new("Carrot queue need namespace, Please set :namespace in config/workling.yml !")
        end
      end
      
      # no need for explicit closing. when the event loop
      # terminates, the connection is closed anyway. 
      def close
        @carrot.stop
      end
      
      def merged_key(key)
        [@namespace, ":", key].join
      end
      
      # pop a value from queue
      def pop(key)
        data = @carrot.queue(merged_key(key)).pop(:ack => true)
        if data
          @carrot.queue(merged_key(key)).ack 
          value = Marshal.load(data)
        else
          value = nil
        end
        return value
      end
      
      # request and retrieve work
      def retrieve(key); @carrot.queue(merged_key(key)); end
      def request(key, value)
        data = Marshal.dump(value)
        @carrot.queue(merged_key(key)).publish(data)
      end
    end
  end
end
