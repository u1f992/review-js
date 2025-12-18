# frozen_string_literal: true

# Stub for Open3
module Open3
  def self.capture2(*_args)
    ['', nil]
  end

  def self.capture2e(*_args)
    ['', nil]
  end

  def self.capture3(*_args)
    ['', '', nil]
  end

  def self.popen3(*_args)
    yield nil, StringIO.new, StringIO.new, nil if block_given?
  end
end
