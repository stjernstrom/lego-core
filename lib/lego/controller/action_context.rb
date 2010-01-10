#
#

class Lego::Controller::ActionContext

  attr_accessor :response

  def initialize
    setup_defaults
  end

  def run(route, env)
    setup_instance_vars_from_route(route, env)
    evaluate_action(route)
    [@response[:code], @response[:headers], @response[:body]]
  end

private

  #
  # setup_instance_vars_from_route extracts variables found in route[:instance_vars] thats setup by the route matchers
  # and converts them to instance variables which makes them availible to the ActionContext.
  #
  def setup_instance_vars_from_route(route, env)
    route[:instance_vars].each_key do |var|
      instance_variable_set("@#{var}", route[:instance_vars][var])
    end if route[:instance_vars]
  end

  def evaluate_action(route)
    @response[:body] = instance_eval(&route[:action_block]) if route[:action_block]
  end

  def setup_defaults
    @response = {}
    @response[:headers] = {'Content-Type' => 'text/html'}
    @response[:code]    = 200
    @response[:body]    = ''
  end

end
