class Lego::Controller::Context
  attr_reader :request, :response
  
  def finish(env, &block)
    @response = Rack::Response.new
    @response.write instance_eval(&block)
    @response.finish
  end
end
