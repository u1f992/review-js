# frozen_string_literal: true

# backtick_javascript: true

# Stub for CGI::Util
require 'cgi/escape'

module CGI
  module Util
    def self.escapeHTML(str)
      CGI.escapeHTML(str)
    end

    def self.escape(str)
      CGI.escape(str)
    end
  end
end
