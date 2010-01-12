#
# RouteHandler is the module that holds and handles routes for every controller class.
#

module Lego::Controller::RouteHandler

  # InvalidMatcher Exception

  class InvalidMatcher < Exception; end

  # classs << self
  extend self

    def extended(base)
      # puts "((Extending: #{base.inspect} => Extended: #{self.inspect}))"
      base.matchers.concat(matchers)
      base.routes.merge!(routes)
    end

    def add_route(method, options)
      if method == :not_found
        routes[:not_found] = options
      else
        routes[method] << options 
      end
    end

    # Getter for cached instance variable holding routes.

    def routes
      cached_routes
    end

    def add_matcher(module_name)
      raise InvalidMatcher if not validate_matcher(module_name)
      matchers << module_name
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
        return true if matcher.match_route(route, env) == true
      end
      false
    end

    def match_all_routes(env)
      method = extract_method_from_env(env)
      routes[method].each do |route|
        return route if run_matchers(route, env)
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
  # end
  # extend ClassMethods
end
