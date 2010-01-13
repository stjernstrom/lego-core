module SimpleRouter
  def self.register(lego)
    lego.add_plugin :router, RouteMatcher
    lego.add_plugin :controller, RouteHandler
  end

  module RouteHandler
    def get(path, &block)
      add_route(:get, {:path => path, :action_block => block})
    end
  end

  module RouteMatcher
    def self.match_route(route, env)
      (route[:path] == env['PATH_INFO']) ? true : false
    end
  end
end

module ViewHelpers
  def self.register(lego)
    lego.add_plugin :view, View
  end

  module View
    def redirect_to(path)
      @response[:code] = 301
      @response[:headers].merge!({'Location', path})
      ""
    end

    def h1(content)
     "<h1>#{content}</h1>"
    end

    def h(s)
      html_escape = { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;' }
      s.to_s.gsub(/[&"><]/) { |special| html_escape[special]  }
    end

    def erb(template, bind = binding)
      path = options(:views) || "#{File.dirname(__file__)/views}"
      template = File.read("#{path}/#{template}.erb") if template.is_a? Symbol
      ERB.new(template).result(bind)
    end
  end
end
