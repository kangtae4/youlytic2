# Fix for Logger compatibility issues in Rails 6.1
begin
  require 'logger'
  
  # Ensure Logger constant is properly defined
  unless defined?(Logger)
    require 'logger'
  end

  # Fix for ActiveSupport::LoggerThreadSafeLevel compatibility
  if defined?(Logger) && !Logger.const_defined?(:Severity)
    Logger.const_set(:Severity, Logger)
  end

  # Define missing Logger constants if needed
  unless Logger.const_defined?(:DEBUG)
    Logger.const_set(:DEBUG, 0)
    Logger.const_set(:INFO, 1)
    Logger.const_set(:WARN, 2)
    Logger.const_set(:ERROR, 3)
    Logger.const_set(:FATAL, 4)
    Logger.const_set(:UNKNOWN, 5)
  end

  # Monkey patch for LoggerThreadSafeLevel if it exists
  if defined?(ActiveSupport::LoggerThreadSafeLevel)
    module ActiveSupport
      module LoggerThreadSafeLevel
        def add(severity, message = nil, progname = nil, &block)
          return true if @logdev.nil? || severity < level
          progname ||= @progname
          if message.nil?
            if block_given?
              message = yield
            else
              message = progname
              progname = @progname
            end
          end
          @logdev.write format_message(format_severity(severity), Time.now, progname, message)
          true
        end
        
        private
        
        def local_level
          Thread.current.thread_variable_get("#{object_id}_local_level")
        end
        
        def local_level=(level)
          Thread.current.thread_variable_set("#{object_id}_local_level", level)
        end
      end
    end
  end

rescue LoadError => e
  # Logger loading failed, continue anyway
  puts "Warning: Logger compatibility fix failed to load: #{e.message}"
end