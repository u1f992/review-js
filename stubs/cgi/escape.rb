# frozen_string_literal: true

# backtick_javascript: true

# Stub for CGI
module CGI
  def self.escapeHTML(str)
    str.to_s
       .gsub('&', '&amp;')
       .gsub('<', '&lt;')
       .gsub('>', '&gt;')
       .gsub('"', '&quot;')
       .gsub("'", '&#39;')
  end

  def self.escape(str)
    `encodeURIComponent(#{str.to_s})`
  end

  def self.unescape(str)
    `decodeURIComponent(#{str.to_s})`
  end
end
