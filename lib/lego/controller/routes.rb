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
    @routes[verb][path]
  end
end
