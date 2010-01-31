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
      routes[verb].each do |route, action|
        return {:matcher => matcher, :action => action} if matcher.match_route(route, path)
      end
    end
    false
  end

  def match(verb, path)
    if match = get(verb, path)
      yield match
    else
      [404, {'Content-Type' => 'text/html'}, '404 - Not found']
    end
  end

  def load_global_matchers(parent)
    (matchers << parent.routes.matchers).flatten!
  end
end
