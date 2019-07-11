module Browsed
  module Chrome
    
    private
      def register_chrome_driver(options: {})
        open_timeout            =   options.fetch(:open_timeout, 60)
        read_timeout            =   options.fetch(:read_timeout, 60)
        resolution              =   options.fetch(:resolution, [1366,768])
        
        profile                 =   Selenium::WebDriver::Chrome::Profile.new
        profile["user-agent"]   =   self.user_agent unless self.user_agent.to_s.empty?
        
        proxy_options           =   manage_chrome_proxy
        proxy_capabilities      =   proxy_options[:capabilities]
        capabilities            =   !proxy_capabilities.nil? ? Selenium::WebDriver::Remote::Capabilities.chrome(proxy: proxy_capabilities) : {}
        proxy_plugin_path       =   proxy_options[:plugin_path]
        
        args                    =   %w(disable-popup-blocking)
        args                    =   args | %W(window-size=#{resolution.first},#{resolution.last}) if resolution && resolution.any? && resolution.size.eql?(2)
        args                    =   args | %w(headless disable-gpu) if headless?
        args                    =   args | %W(load-extension=#{proxy_plugin_path}) unless proxy_plugin_path.to_s.empty?
        
        options                 =   Selenium::WebDriver::Chrome::Options.new(profile: profile, args: args)
        
        Capybara.register_driver self.driver do |app|
          client                =   Selenium::WebDriver::Remote::Http::Default.new(open_timeout: open_timeout, read_timeout: read_timeout)
          Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client, options: options, desired_capabilities: capabilities)
        end
      end
    
      def manage_chrome_proxy
        proxy_options                 =   nil
        plugin_path                   =   nil
        
        if valid_proxy?
          if self.proxy.fetch(:mode, nil).eql?(:proxy_chain) && proxy_using_auth?
            self.proxy_chain_server   =   Browsed::Proxies::ProxyChain.new(self.browser_id)
            log("Starting a new proxy chain server instance.")
            
            generated_proxy_url       =   self.proxy_chain_server.start_server(generate_proxy_auth_url)
            
            log("Started a new proxy chain server instance at #{generated_proxy_url}.")
            
            uri                       =   URI.parse(generated_proxy_url)
            proxy_options             =   generate_selenium_webdriver_proxy(host: uri.host, port: uri.port)
            
          else
            proxy_options             =   generate_selenium_webdriver_proxy(host: self.proxy.fetch(:host), port: self.proxy.fetch(:port))
          
            log("Will use proxy #{self.proxy.fetch(:host)}:#{self.proxy.fetch(:port)} to initiate the request.")
          
            if !headless? && proxy_using_auth?
              log("Generating a new proxy plugin to manage proxy authentication.")
              plugin_path             =   Browser::Proxies::Chrome::ProxyAuthentication::Packager.package_extension(proxy, self.configuration.temp_path)
            end
          end
        end
      
        return {capabilities: proxy_options, plugin_path: plugin_path}
      end
  
  end
end
