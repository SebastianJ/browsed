module Browsed
  module Proxies
    class ProxyChain
      attr_accessor :script_path, :instance_id, :command, :pid, :generated_proxy_url
    
      def initialize(instance_id = nil)
        self.script_path          =   File.expand_path("../proxy-chain-server/server.js", __FILE__)
        self.instance_id          =   instance_id.to_s.empty? ? SecureRandom.hex : instance_id
        self.command              =   "ps aux | awk '/proxy-chain-instance-id-#{instance_id}/'"
        self.generated_proxy_url  =   nil
      end
    
      def start_server(proxy_url, wait: 3)
        IO.popen("((node #{self.script_path} \"#{proxy_url}\" proxy-chain-instance-id-#{instance_id} &)&)") do |io|
          self.generated_proxy_url   =   io.gets&.strip
        end
        
        # Wait a couple of seconds to let proxy-chain initiate the connection with the target proxy server
        sleep wait
        
        identify_pid
      
        self.generated_proxy_url
      end
    
      def identify_pid
        process                   =   `#{self.command}`.split("\n")&.select { |p| p =~ /proxy-chain-instance-id-#{self.instance_id}$/i }&.first
        parts                     =   process.split(' ')
        pid                       =   parts && parts.any? ? parts[1] : nil
        self.pid                  =   !pid.to_s.empty? ? pid.to_i : nil
      end
    
      def stop_server
        Process.kill("INT", self.pid) unless self.pid.to_s.empty?
      end
    
    end
  end
end
