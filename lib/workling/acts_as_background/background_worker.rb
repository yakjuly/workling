class BackgroundWorker < Workling::Base
  def process(options)
    klass = options[:class]
    method_name = options[:method]
    argments = YAML.load(options[:args])

    begin
      logger.info "Background worker: begin to work ..."
      logger.info "#{klass}.#{method_name}(#{argments.inspect})"
      time = Time.now
      klass.constantize.send(method_name, *argments)
      logger.info "Background work is done. Took #{Time.now - time}"
    rescue Exception => e
      logger.info e.message
      logger.info e.backtrace.join("\n")
    end
    logger.flush
  end

end