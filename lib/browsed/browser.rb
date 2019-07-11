module Browsed
  module Browser
    
    def generate_browser_id
      SecureRandom.hex
    end
    
    # Resize the window separately and not based on initialization
    def resize!(res = nil)
      res ||= self.resolution
      
      if res && res.size.eql?(2) && resizable_browser? # Resolutions for Chrome & Poltergeist are set in the driver
        self.session.current_window.resize_to(res.first, res.last) # [width, height]
      end
    end
    
    def resizable_browser?
      non_resizable   =   [:poltergeist, :selenium_chrome, :selenium_chrome_headless]
      !non_resizable.include?(self.driver.to_sym)
    end
    
    # User Agents
    def set_user_agent(user_agent)
      if !user_agent.to_s.empty? && !user_agent.to_sym.eql?(:randomize)
        self.user_agent       =   user_agent
      elsif (!user_agent.to_s.empty? && user_agent.to_sym.eql?(:randomize)) || phantomjs?
        case self.device
          when :iphone
            self.user_agent   =   Agents.random_user_agent(:phones, :iphone)
          when :android_phone
            self.user_agent   =   Agents.random_user_agent(:phones, :android)
          when :ipad
            self.user_agent   =   Agents.random_user_agent(:tablets, :ipad)
          when :android_tablet
            self.user_agent   =   Agents.random_user_agent(:tablets, :android)
          else
            self.user_agent   =   Agents.random_user_agent(self.device)
        end
      end
    end
    
    def runs_ios?
      Agents.runs_ios?(self.user_agent)
    end
  
    def is_iphone?
      Agents.is_iphone?(self.user_agent)
    end
  
    def is_ipad?
      Agents.is_ipad?(self.user_agent)
    end
    
    # Resolution      
    def set_resolution(res)
      if res && res.is_a?(Array)
        self.resolution   =   res
      elsif res && res.is_a?(Symbol) && res.eql?(:randomize)
        self.resolution   =   randomize_resolution
      end
    end
    
    def randomize_resolution
      runs_ios? ? randomize_ios_resolution : Browsed::Constants::RESOLUTIONS.fetch(self.device, :desktop).sample
    end
  
    def randomize_ios_resolution
      resolution_device =   case self.device
        when :iphone, :android_phone
          :phone
        when :ipad, :android_tablet
          :tablet
        else
          self.device
      end
      
      random_key    =   Browsed::Constants::RESOLUTIONS.fetch(resolution_device, :desktop).keys.sample
      resolution    =   Browsed::Constants::RESOLUTIONS.fetch(resolution_device, :desktop)[random_key]
    end
    
  end
end
