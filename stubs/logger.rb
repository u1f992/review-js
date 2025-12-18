# frozen_string_literal: true

# backtick_javascript: true

# Stub for Logger standard library
class Logger
  FATAL = 4
  ERROR = 3
  WARN = 2
  INFO = 1
  DEBUG = 0

  attr_accessor :level, :formatter, :progname

  def initialize(_io = nil, progname: nil, **_kwargs)
    @level = INFO
    @progname = progname
    @formatter = nil
  end

  def fatal(msg = nil, &block)
    log(FATAL, msg, &block)
  end

  def error(msg = nil, &block)
    log(ERROR, msg, &block)
  end

  def warn(msg = nil, &block)
    log(WARN, msg, &block)
  end

  def info(msg = nil, &block)
    log(INFO, msg, &block)
  end

  def debug(msg = nil, &block)
    log(DEBUG, msg, &block)
  end

  def log(severity, msg = nil, &block)
    msg = block.call if block
    return if msg.nil?

    severity_str = %w[DEBUG INFO WARN ERROR FATAL][severity] || 'INFO'
    `console.log(#{severity_str + ': ' + msg.to_s})`
  end

  def <<(msg)
    `console.log(#{msg.to_s})`
  end
end
