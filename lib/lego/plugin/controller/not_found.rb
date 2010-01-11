module Lego::Plugin::Controller
  module NotFound
    def self.register(lego)
      lego.add_plugin :controller, self
    end

    def not_found(&block)
      add_route(:not_found, { :set_response_code => 404, :action_block => block })
    end
  end
end
