class Lego::Controller::Context
  attr_accessor :action_args, :action_ivars
  attr_reader   :request, :response, :env, :action

  def options(key)
    self.class::CurrentClass.config.options(key)
  end

  def finish(env, &block)
    @env, @action = env, block

    rack_initialize
    rack_finish
  end


  private
    
    def inject_action_ivars
      action_ivars.each do |name, value| 
        instance_variable_set name, value 
      end
    end
    
    def rack_initialize
      @response = Rack::Response.new
      @request  = Rack::Request.new(env)
    end

    def rack_finish
      inject_action_ivars if action_ivars
      response.write instance_exec(*action_args, &action)
      response.finish
    end
end
