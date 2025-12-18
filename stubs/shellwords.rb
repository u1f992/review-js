# frozen_string_literal: true

# Stub for Shellwords
module Shellwords
  def self.escape(str)
    str.to_s.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/) { '\\' + $1 }
  end

  def self.shellescape(str)
    escape(str)
  end

  def self.join(array)
    array.map { |arg| escape(arg) }.join(' ')
  end

  def self.split(str)
    str.to_s.split(/\s+/)
  end
end
