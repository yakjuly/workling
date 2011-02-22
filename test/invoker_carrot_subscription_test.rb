require File.dirname(__FILE__) + '/test_helper.rb'

context "the invoker 'carrot subscription'" do
  setup do
    Workling.send :class_variable_set, "@@config", { :namespace => "workling_test" }
    routing = Workling::Routing::ClassAndMethodRouting.new
    @client_class = Workling::Clients::CarrotClient
    @client = @client_class.new
    @client.connect
    @invoker = Workling::Remote::Invokers::CarrotSubscriber.new(routing, @client_class)
  end
  
  specify "should invoke Util.echo with the arg 'hello' if the string 'hello' is set onto the queue utils__echo" do
    
    # make sure all new instances point to the same client. that way, state is shared
    Util.any_instance.expects(:echo).once.with({ :message => "hello" })
    
    # Don't take longer than 10 seconds to shut this down. 
    Timeout::timeout(10) do
      @client.request("utils__echo", { :message => "hello" })
      
      @invoker.send(:routes).each do |route|
        args = @client.pop(route)
        @invoker.run(route, args) if args
      end
    end
  end
end