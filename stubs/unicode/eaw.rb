# frozen_string_literal: true
# backtick_javascript: true

# Unicode::Eaw stub using meaw (https://github.com/susisu/meaw)
# Provides East Asian Width property detection
# globalThis.__meaw__ is set by the ESM wrapper

module Unicode
  module Eaw
    %x{
      var __meaw__ = globalThis.__meaw__ || null;
    }

    def self.meaw_available?
      `__meaw__ !== null`
    end

    # Get East Asian Width property of a character
    # @param char [String] A single character
    # @return [Symbol] One of :Na, :W, :F, :H, :A, :N
    def self.property(char)
      return :N if char.nil? || char.empty?

      if meaw_available?
        eaw = `__meaw__.getEAW(#{char.to_s})`
        case eaw
        when 'Na' then :Na
        when 'W'  then :W
        when 'F'  then :F
        when 'H'  then :H
        when 'A'  then :A
        when 'N'  then :N
        else :N
        end
      else
        # Fallback: simple heuristic based on character code
        code = char.ord
        if code >= 0x3000 && code <= 0x9FFF
          :W  # CJK characters
        elsif code >= 0xFF00 && code <= 0xFF60
          :F  # Fullwidth forms
        elsif code >= 0xFF61 && code <= 0xFFDC
          :H  # Halfwidth forms
        else
          :Na # Default to Narrow
        end
      end
    end

    # Get display width of a string
    # W and F count as 2, others count as 1
    # @param str [String] Input string
    # @return [Integer] Display width
    def self.width(str)
      return 0 if str.nil? || str.empty?

      if meaw_available?
        `__meaw__.computeWidth(#{str.to_s})`
      else
        # Fallback: calculate manually
        str.chars.sum do |char|
          prop = property(char)
          (prop == :W || prop == :F) ? 2 : 1
        end
      end
    end
  end
end
