module Browsed
  class Configuration
    attr_accessor :driver, :browser, :environment
    attr_accessor :binary_path, :root_path, :download_path, :temp_path
    attr_accessor :maximum_processes, :processes_max_ttl
    attr_accessor :verbose
  
    def initialize
      self.driver               =   :selenium_chrome
      self.browser              =   :chrome
      
      self.environment          =   :production
      
      self.binary_path          =   "/usr/local/bin/phantomjs"
      
      self.root_path            =   File.expand_path(File.join(__FILE__, "../../.."))
      self.download_path        =   nil
      self.temp_path            =   "/tmp"
      
      self.maximum_processes    =   nil
      self.processes_max_ttl    =   60 * 30 # 30 minutes
      
      self.verbose              =   false
    end
    
    def verbose?
      self.verbose
    end
  
  end
end
