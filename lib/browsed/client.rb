module Browsed
  class Client
    attr_accessor :configuration
    attr_accessor :driver, :browser, :browser_id, :headless, :environment
    attr_accessor :session, :proxy, :proxy_chain_server
    attr_accessor :device, :user_agent, :resolution, :headless
    attr_accessor :manager, :maximum_processes
    
    include Capybara::DSL
    
    def initialize(configuration:     ::Browsed.configuration,
                   driver:            :selenium_chrome,
                   browser:           :chrome,
                   headless:          false,
                   device:            :desktop,
                   proxy:             nil,
                   user_agent:        nil,
                   resolution:        nil,
                   environment:       :production,
                   options:           {},
                   maximum_processes: nil)
      
      self.configuration        =   configuration
      self.headless             =   headless
      self.environment          =   environment || self.configuration.environment
      
      self.device               =   device
      
      self.proxy                =   proxy
      self.proxy_chain_server   =   nil
      
      self.manager              =   ::Browsed::Manager.new(browser: self.browser)
      self.maximum_processes    =   maximum_processes || self.configuration.maximum_processes
      
      set_browser(browser)
      set_driver
      set_user_agent(user_agent)
      set_resolution(resolution)
      
      options.merge!(browser_id: self.browser_id)
      setup_capybara(options: options)
    end
    
    include ::Browsed::Browser
    include ::Browsed::Proxies
    include ::Browsed::Firefox
    include ::Browsed::Chrome
    include ::Browsed::Phantomjs
    
    def set_driver
      self.driver   =   case self.browser.to_sym
        when :chrome
          self.headless ? :selenium_chrome_headless : :selenium_chrome
        when :firefox
          :selenium
        when :phantomjs
          :poltergeist
      end
    end
    
    def set_browser(browser)
      self.browser      =   (browser || self.configuration.browser)&.to_sym
      self.browser_id   =   generate_browser_id
      
      raise ::Browsed::InvalidBrowserError, "Browser #{self.browser} is invalid! Please specify a valid browser: chrome, firefox or phantomjs" unless ::Browsed::Constants::BROWSERS.include?(self.browser)
    end
    
    def setup_capybara(options: {}, retries: 3)
      self.manager.kill_stale_processes!
      
      if can_start_new_process?
        register_driver!(options)
      
        Capybara.default_driver         =   self.driver
        Capybara.javascript_driver      =   self.driver
      
        Capybara.default_max_wait_time  =   options.fetch(:wait_time, 5) #seconds
      
        self.session                    =   Capybara::Session.new(self.driver)
      else
        raise Browsed::TooManyProcessesError, "Too many #{self.browser} processes running, reached maximum allowed number of #{self.maximum_processes} processes."
      end
    end
    
    def can_start_new_process?
      self.maximum_processes.nil? || self.manager.can_start_more_processes?(max_count: self.maximum_processes)
    end
    
    def display_screenshot!(path)
      Launchy.open path if development?
    end
    
    def reset_session!
      self.session.reset_session! rescue nil
    end
  
    def quit!(retries: 3)
      begin
        reset_session!
        self.session.driver.quit
      rescue Exception
        retries       -=    1
        retry if retries > 0
      end
      
      # If Selenium/Phantom somehow isn't able to shut down the browser, force a shutdown using kill -9
      self.manager.set_command(browser_id: self.browser_id)
      self.manager.kill_processes!
      
      if self.proxy_chain_server
        self.proxy_chain_server.stop
        self.proxy_chain_server   =   nil
      end
      
      self.session                =   nil
    end
    
    private
      def register_driver!(options = {})
        if firefox?
          register_firefox_driver(options: options)
        elsif chrome?
          register_chrome_driver(options: options.merge(resolution: self.resolution))
        elsif phantomjs?
          register_phantomjs_driver(options: options)
        end
      end
    
      def phantomjs?
        self.browser.to_sym.eql?(:phantomjs)
      end
      
      def firefox?
        self.browser.to_sym.eql?(:firefox)
      end
      
      def chrome?
        self.browser.to_sym.eql?(:chrome)
      end
      
      def development?
        in_environment?(:development)
      end
    
      def in_environment?(env)
        self.environment.eql?(env)
      end
      
      def headless?
        self.headless
      end
      
      def log(message)
        puts "[Browsed::Client] - #{Time.now}: #{message}" if self.configuration.verbose?
      end
    
  end
end
