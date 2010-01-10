#
#

class Lego::Controller::ActionContext

  attr_accessor :response

  def initialize
    setup_defaults
  end

  def run(route, env)
    evaluate_action(route)
    [@response[:code], @response[:headers], @response[:body]]
  end

private

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
