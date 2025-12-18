# frozen_string_literal: true
# backtick_javascript: true

# NKF stub using JavaScript implementation
# Provides Japanese character conversion (hiragana/katakana, hankaku/zenkaku)
# globalThis.__nkf__ is set by the ESM wrapper

module NKF
  %x{
    var __nkf__ = globalThis.__nkf__ || null;
  }

  def self.nkf_available?
    `__nkf__ !== null`
  end

  # NKF.nkf - Convert Japanese characters
  # Supported options:
  #   -w          : UTF-8 output (no-op, always UTF-8)
  #   -W          : UTF-8 input (no-op, always UTF-8)
  #   -X          : Half-width kana to full-width kana
  #   --hiragana  : Katakana to Hiragana
  #   --katakana  : Hiragana to Katakana
  def self.nkf(options, str)
    return str if str.nil? || str.empty?

    if nkf_available?
      `__nkf__.nkf(#{options}, #{str})`
    else
      # Fallback: return unchanged
      str
    end
  end
end
