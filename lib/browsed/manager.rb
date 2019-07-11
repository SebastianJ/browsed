module Browsed
  class Manager
    attr_accessor :command, :kill_signal, :logging
    
    def initialize(command: nil, browser_id: nil, browser: :phantomjs, kill_signal: 9, logging: false)
      set_command(command: command, browser_id: browser_id, browser: browser)
      
      self.kill_signal    =   kill_signal
      self.logging        =   logging
    end
    
    def set_command(command: nil, browser_id: nil, browser: :phantomjs)
      if !command.to_s.empty?
        self.command        =   command
      elsif !browser_id.to_s.empty?
        self.command        =   "ps aux | awk '/--browser_id=#{browser_id}/'"
      else
        case browser
          when :phantomjs
            self.command    =   "ps -ef | grep /[p]hantomjs"
          when :firefox
            self.command    =   "ps -ef | grep /[f]irefox-bin"
          when :chrome
            self.command    =   "ps -ef | grep /[c]hromedriver"
          else
            self.command    =   "ps -ef | grep /[p]hantomjs"
        end
      end
    end
    
    def can_start_more_processes?(max_count: nil)
      return max_count.nil? || get_current_processes.size < max_count
    end
    
    def get_current_processes
      processes           =   []
      procs               =   `#{self.command}`.split("\n")
      
      procs.each do |process_data|
        process           =   parse_process(process_data)
        processes        <<   process
      end if procs && procs.any?
      
      return processes
    end
    
    def kill_stale_processes!
      kill_processes!(started_after: ::Browsed.configuration.processes_max_ttl)
    end
    
    def kill_processes!(started_after: nil)
      processes           =   get_current_processes
      
      processes.each do |process|
        killable          =   started_after.nil? || (process[:date] && process[:date] < (Time.now - started_after))
        kill_process!(process) if killable
      end if processes && processes.any?
    end
    
    def kill_process!(process)
      info "[Browsed::Manager] - #{Time.now.to_s}: Killing process with PID #{process[:pid]} matching command #{self.command}."
      
      begin
        ::Process.kill(self.kill_signal, process[:pid])
      
      rescue StandardError => e
        info "[Browsed::Manager] - #{Time.now.to_s}:  Failed to kill process with pid '#{process[:pid]}'. Error Class: #{e.class.name}. Error Message: #{e.message}"
      end
    end
    
    private
      def parse_process(process_data)
        process             =   {}
      
        parts               =   process_data.split(' ')
        pid                 =   parts[1].to_i
        started             =   parts[4].to_s
        date                =   parse_date(started)
      
        process[:pid]       =   pid
        process[:started]   =   started
        process[:date]      =   date
      
        info "[Browsed::Manager] - #{Time.now.to_s}: Pid: #{pid}. Started: #{started}. Date: #{date}.\n"
      
        return process
      end
    
      def parse_date(date, retries = 3)
        begin
          if (!(date =~ /^[a-z]{3,4}\d*/i).nil?) #Sep16
            parsed_date = DateTime.strptime(date, "%b%d")
        
          elsif (!(date =~ /^\d*:\d*/i).nil?) #11:34
            parsed_date = Time.strptime(date, "%H:%M").to_datetime
          end
      
        rescue StandardError => e
          info "[Browsed::Manager] - #{Time.now.to_s}: Exception occurred while trying to parse date/time string '#{date}'. Error Class: #{e.class.name}. Error: #{e.message}."
          retries -= 1
          retry if retries > 0
        end
      end
    
      def info(message)
        puts message if self.logging
      end
    
  end
end
