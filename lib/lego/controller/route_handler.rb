#
# RouteHandler is the module that holds and handles routes for every controller class.
#

module Lego::Controller::RouteHandler

  # InvalidMatcher Exception

  class InvalidMatcher < Exception; end

  extend self

  #
  # When extended we need to copy out matchers and routes to the class extending.
  #

  def extended(base)
    base.matchers.concat(matchers)
  end

  def add_route(method, options)
    if method == :not_found
      routes[:not_found] = options
    else
      routes[method] << options 
    end
  end

  def add_matcher(module_name)
    raise InvalidMatcher if not validate_matcher(module_name)
    matchers << module_name
  end

  # Getter for cached instance variable holding routes.

  def routes
    cached_routes
  end

  # Getter for instance variable holding matchers.

  def matchers
    cached_matchers
  end

  def validate_matcher(module_name)
    eval(module_name.to_s).respond_to?(:match_route)
  end

  def run_matchers(route, env)
    matchers.each do |matcher|
      match = matcher.match_route(route, env)
      return match if match.kind_of?(Array)
    end
    false
  end

  def match_all_routes(env)
    method = extract_method_from_env(env)
    routes[method].each do |route|
      if match_data = run_matchers(route, env)
        return [route] | match_data
      end
    end
    nil 
  end

  private

  def extract_method_from_env(env)
    env["REQUEST_METHOD"].downcase.to_sym if env["REQUEST_METHOD"]
  end

  def cached_routes
    @route_cache ||= {
      :get       => [],
      :post      => [],
      :put       => [],
      :head      => [],
      :delete    => [],
      :not_found => nil
    }
  end

  def cached_matchers
    @matcher_cache ||= []
  end
end
