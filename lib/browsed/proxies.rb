module Browsed
  module Proxies
    
    def valid_proxy?(proxy = self.proxy)
      (proxy && !proxy.empty? && !proxy.fetch(:host, nil).to_s.empty? && !proxy.fetch(:port, nil).to_s.empty?)
    end
    
    def proxy_using_auth?(proxy = self.proxy)
      (!proxy.fetch(:username, nil).to_s.empty? && !proxy.fetch(:password, nil).to_s.empty?)
    end
    
    def generate_proxy_auth_url(proxy = self.proxy)
      "http://#{proxy[:username]}:#{proxy[:password]}@#{proxy[:host]}:#{proxy[:port]}"
    end
    
    def generate_selenium_webdriver_proxy(host:, port:)
      log("Will use proxy #{host}:#{port} to initiate the request.")
      
      Selenium::WebDriver::Proxy.new(
        http: "#{host}:#{port}",
        ssl:  "#{host}:#{port}"
      )
    end
    
  end
end
