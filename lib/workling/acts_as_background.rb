require File.dirname(__FILE__) + "/acts_as_background/background_worker"

module Workling
  module ActsAsBackground #:nodoc:
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def acts_as_background(method_name, options = {})
        (class << self; self;end).class_eval do
          alias_method "original_#{method_name}", method_name
          define_method(method_name){|*args|
            args.first.reload if args.first.is_a?(ActiveRecord::Base)
            options = {:class=>self.to_s, :method=>"original_#{method_name}", :args => YAML.dump(args)}
            return BackgroundWorker.async_process(options)
          }
        end
      end
    end
  end
end