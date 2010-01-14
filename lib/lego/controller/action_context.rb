#
#

class Lego::Controller::ActionContext

  attr_accessor :response, :env, :route, :match_data
  
  def initialize
    setup_defaults
  end

  def options(key)
    "#{self.class::ApplicationClass.current_config.options(key)}"
  end

  def run(match_data)
    @route, @env, @match_data = match_data
    setup_instance_vars
    evaluate_action
    [@response[:code], @response[:headers], @response[:body]]
  end

private

  #
  # setup_instance_vars_from_route extracts variables found in route[:instance_vars] thats setup by the route matchers
  # and converts them to instance variables which makes them availible to the ActionContext.
  #

  def setup_instance_vars
    @match_data[:instance_vars].each_key do |var|
      instance_variable_set("@#{var}", @match_data[:instance_vars][var])
    end if @match_data[:instance_vars]
    @response[:code] = @match_data[:set_response_code] if @match_data[:set_response_code]
  end

  #
  # evaluate_action executes route[:action_block] and appends the output to @response[:body]
  #

  def evaluate_action
    @response[:body] << instance_eval(&@route[:action_block]) if @route[:action_block]
  end

  #
  # setup_defaults creates a default @response object with enough data to satisfies Rack.
  #

  def setup_defaults
    @response = {}
    @response[:headers] = {'Content-Type' => 'text/html'}
    @response[:code]    = 200
    @response[:body]    = ''
  end
end
