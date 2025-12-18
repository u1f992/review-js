# frozen_string_literal: true

# backtick_javascript: true

# Stub for Date
class Date
  attr_reader :year, :month, :day

  def initialize(year = 1970, month = 1, day = 1)
    @year = year
    @month = month
    @day = day
  end

  def self.today
    now = `new Date()`
    new(`#{now}.getFullYear()`, `#{now}.getMonth() + 1`, `#{now}.getDate()`)
  end

  def self.parse(str)
    if str =~ /(\d{4})-(\d{2})-(\d{2})/
      new($1.to_i, $2.to_i, $3.to_i)
    else
      today
    end
  end

  def to_s
    format('%04d-%02d-%02d', @year, @month, @day)
  end

  def strftime(format)
    format.gsub('%Y', @year.to_s.rjust(4, '0'))
          .gsub('%m', @month.to_s.rjust(2, '0'))
          .gsub('%d', @day.to_s.rjust(2, '0'))
  end
end
