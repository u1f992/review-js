# frozen_string_literal: true

# Stub for Tempfile
class Tempfile
  def initialize(_basename, _dir = nil)
    @content = +''
  end

  def puts(str)
    @content << str.to_s << "\n"
  end

  def print(str)
    @content << str.to_s
  end

  def write(str)
    @content << str.to_s
    str.to_s.length
  end

  def close
  end

  def path
    'tempfile'
  end

  def unlink
  end
end
