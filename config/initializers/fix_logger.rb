# Logger compatibility fix for Rails 7 with Ruby 3.1
require 'logger'

# Pre-require logger before ActiveSupport tries to load it
unless defined?(Logger::Severity)
  Logger.const_set(:Severity, Logger) if defined?(Logger)
end

# Ensure all Logger constants are defined
if defined?(Logger)
  constants_to_define = {
    DEBUG: 0,
    INFO: 1,
    WARN: 2,
    ERROR: 3,
    FATAL: 4,
    UNKNOWN: 5
  }
  
  constants_to_define.each do |const_name, value|
    unless Logger.const_defined?(const_name)
      Logger.const_set(const_name, value)
    end
  end
end

# Early monkey patch to prevent LoggerThreadSafeLevel issues
begin
  # This prevents the error before ActiveSupport loads
  if defined?(ActiveSupport)
    module ActiveSupport
      module LoggerThreadSafeLevel
        # Override the problematic constant access
        def self.included(base)
          # Do nothing - prevent the original inclusion logic
        end
      end
    end
  end
rescue NameError
  # Module doesn't exist yet, that's fine
end