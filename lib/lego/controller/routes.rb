class Lego::Controller::Routes

  attr_reader :routes

  def initialize
    @routes = { 
      :get    => {},
      :post   => {},
      :put    => {},
      :delete => {}
    }
  end

  def matchers
    @matchers ||= []
  end

  def add(verb, path, &block)
    @routes[verb][path] = block
  end

  def get(verb, path)
    matchers.each do |matcher|
      if action = matcher.match_route(routes, verb, path)
        return action
      end
    end
    false
  end
end
