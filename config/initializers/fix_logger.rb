# Fix for Logger compatibility issues in Rails 6.1
require 'logger'

# Ensure Logger constant is properly defined
unless defined?(Logger)
  require 'logger'
end

# Fix for ActiveSupport::LoggerThreadSafeLevel compatibility
if defined?(Logger) && !Logger.const_defined?(:Severity)
  Logger.const_set(:Severity, Logger)
end

# Additional fixes for Logger thread safety
if defined?(ActiveSupport::LoggerThreadSafeLevel)
  module ActiveSupport
    module LoggerThreadSafeLevel
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