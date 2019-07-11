module Browsed
  module Phantomjs
    
    private
      def register_phantomjs_driver(options: {}, timeout: 60, debug: false)
        phantom_opts            =   ['--ignore-ssl-errors=true', '--ssl-protocol=any']
        disable_images          =   options.fetch(:disable_images, false)
    
        if disable_images
          phantom_opts         <<   "--load-images=false"
        end
      
        phantom_opts            =   phantom_opts | poltergeist_proxy_options
    
        options                 =   {
          timeout:            timeout,
          js_errors:          false,
          debug:              debug,
          phantomjs_options:  phantom_opts
        }
    
        options[:phantomjs]     =   self.configuration.binary_path if in_environment?(:production)
        options[:window_size]   =   self.resolution if self.resolution&.any?
      
        headers                 =   {}
        headers['User-Agent']   =   self.user_agent unless self.user_agent.to_s.empty?
      
        log("Will register a new poltergeist driver:\nOptions: #{options.inspect}\nHeaders: #{headers.inspect}\n")
    
        Capybara.register_driver self.driver do |app|
          poltergeist           =   Capybara::Poltergeist::Driver.new(app, options)
          poltergeist.headers   =   headers
          poltergeist
        end
      end
    
      def poltergeist_proxy_options
        proxy_options       =   []
      
        if self.proxy && !self.proxy.empty? && self.proxy.has_key?(:host) && self.proxy.has_key?(:port)
          proxy_address     =   "#{self.proxy.fetch(:host)}:#{self.proxy.fetch(:port)}"
        
          proxy_options    <<   "--proxy=#{proxy_address}" if !proxy_address.to_s.empty?
        
          if !self.proxy.fetch(:username, nil).to_s.empty? && !self.proxy.fetch(:password, nil).to_s.empty?
            credentials     =   "#{self.proxy.fetch(:username)}:#{self.proxy.fetch(:password)}"
            proxy_options  <<   "--proxy-auth=#{credentials}"
          end
        
          log("Will use proxy options #{proxy_options} to initiate the request.")
        end
      
        return proxy_options
      end
  
  end
end
