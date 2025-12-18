# frozen_string_literal: true

# backtick_javascript: true

# Stub for Digest
module Digest
  class SHA256
    def self.hexdigest(str)
      # Simple hash for browser (not cryptographically secure)
      # In production, could use SubtleCrypto API
      hash = 0
      str.to_s.each_char do |c|
        hash = ((hash << 5) - hash + c.ord) & 0xFFFFFFFF
      end
      hash.to_s(16).rjust(64, '0')
    end
  end

  class MD5
    def self.hexdigest(str)
      hash = 0
      str.to_s.each_char do |c|
        hash = ((hash << 5) - hash + c.ord) & 0xFFFFFFFF
      end
      hash.to_s(16).rjust(32, '0')
    end
  end
end
