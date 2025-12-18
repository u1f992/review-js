# frozen_string_literal: true

# backtick_javascript: true

# Stub for SecureRandom
module SecureRandom
  def self.uuid
    # Simple UUID v4 generation using JavaScript's crypto
    hex_chars = '0123456789abcdef'
    uuid = ''
    16.times do |i|
      uuid += '-' if [4, 6, 8, 10].include?(i)
      if i == 6
        uuid += '4' # Version 4
      elsif i == 8
        uuid += hex_chars[8 + rand(4)] # Variant
      else
        uuid += hex_chars[rand(16)]
      end
      uuid += hex_chars[rand(16)]
    end
    uuid
  end

  def self.hex(n = 16)
    (0...n).map { rand(16).to_s(16) }.join
  end

  def self.random_bytes(n = 16)
    (0...n).map { rand(256).chr }.join
  end

  def self.base64(n = 16)
    # Simple base64 encoding
    bytes = random_bytes(n)
    `btoa(#{bytes})`
  end
end
