module Browsed
  module Firefox
    
    private
      def register_firefox_driver(options: {})
        open_timeout            =   options.fetch(:open_timeout, 60)
        read_timeout            =   options.fetch(:read_timeout, 60)
        download_path           =   options.fetch(:download_path, self.configuration.download_path)
        private_browsing        =   options.fetch(:private_browsing, false)
        
        profile                 =   Selenium::WebDriver::Firefox::Profile.new
        
        if private_browsing
          profile["browser.privatebrowsing.autostart"]        =   true
        end

        unless download_path.to_s.empty?
          profile["browser.download.useDownloadDir"]          =   true
          profile["browser.download.dir"]                     =   download_directory
          profile["browser.download.folderList"]              =   2
          profile["browser.helperApps.neverAsk.saveToDisk"]   =   "text/plain, application/vnd.ms-excel, text/csv, text/comma-separated-values, application/octet-stream, text/x-comma-separated-values, application/csv, application/x-filler"
          profile["toolkit.telemetry.prompted"]               =   true
          profile["pdfjs.disabled"]                           =   true
        end
        
        profile["browser.tabs.warnOnClose"]                   =   false
        profile["browser.tabs.warnOnCloseOtherTabs"]          =   false
        profile["general.useragent.override"]                 =   self.user_agent unless self.user_agent.to_s.empty?
        
        profile                 =   firefox_proxy_options(profile)
        options                 =   Selenium::WebDriver::Firefox::Options.new(profile: profile)
        options.args           <<   "--browser_id=#{self.browser_id}" unless self.browser_id.to_s.empty?
        options.args           <<   "--headless"         if headless?
        
        Capybara.register_driver self.driver do |app|
          client                =   Selenium::WebDriver::Remote::Http::Default.new(open_timeout: open_timeout, read_timeout: read_timeout)
          Capybara::Selenium::Driver.new(app, browser: :firefox, http_client: client, options: options)
        end
      end
    
      def firefox_proxy_options(profile)
        proxy_options                 =   nil
        
        if valid_proxy?
          if self.proxy.fetch(:mode, nil).eql?(:proxy_chain) && proxy_using_auth?
            log("Starting a new proxy chain server instance.")
            self.proxy_chain_server   =   ::ProxyChainRb::Server.new(self.browser_id)
            
            generated_proxy_url       =   self.proxy_chain_server.start(generate_proxy_auth_url)
            
            log("Started a new proxy chain server instance at #{generated_proxy_url}.")
            
            uri                       =   URI.parse(generated_proxy_url)
            proxy_options             =   generate_selenium_webdriver_proxy(host: uri.host, port: uri.port)
          else
            proxy_options             =   generate_selenium_webdriver_proxy(host: self.proxy.fetch(:host), port: self.proxy.fetch(:port))
          end
        end
        
        profile.proxy                 =   proxy_options unless proxy_options.nil?
      
        return profile
      end
  
  end
end
