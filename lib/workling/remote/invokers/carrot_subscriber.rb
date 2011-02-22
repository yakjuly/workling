require 'carrot'
require 'workling/remote/invokers/base'

#
#  Subscribes the workers to the correct queues. 
# 
module Workling
  module Remote
    module Invokers
      class CarrotSubscriber < Workling::Remote::Invokers::Base
        
        def initialize(routing, client_class)
          super
        end
        
        #
        #  Starts routes loop until stop() calls. 
        #
        def listen
          connect do
            loop_routes do |route|
              args = @client.pop(route)
              run(route, args) if args
            end
          end
        end
        
        def stop
          @client.close
          @shutdown = true
        end
      end
    end
  end
end