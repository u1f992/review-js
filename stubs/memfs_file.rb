# frozen_string_literal: true
# backtick_javascript: true

# Custom File implementation using memfs
# This replaces nodejs/file.rb to use in-memory filesystem
# globalThis.__reviewFs__ is set by the ESM wrapper

# Note: Don't require 'corelib/file' as it overwrites our methods
# Instead, we extend the existing File class that Opal provides

class File
  # __fs__ is set by the ESM wrapper using memfs
  %x{
    var __fs__ = globalThis.__reviewFs__ || {
      readFileSync: function() { throw new Error('File system not initialized'); },
      writeFileSync: function() { throw new Error('File system not initialized'); },
      existsSync: function() { return false; },
      statSync: function() { throw new Error('File system not initialized'); },
      mkdirSync: function() {},
      readdirSync: function() { return []; },
      unlinkSync: function() {}
    };
  }

  class << self
    def read(path, options = {})
      path = path.to_s
      # Handle mode like 'rt:BOM|utf-8'
      %x{
        try {
          return __fs__.readFileSync(#{path}, 'utf8');
        } catch (e) {
          #{raise Errno::ENOENT, "No such file or directory - #{path}"}
        }
      }
    end

    def write(path, data, options = {})
      path = path.to_s
      data = data.to_s
      # Ensure parent directory exists
      dir = dirname(path)
      unless dir == '/' || dir == '.'
        %x{
          try {
            __fs__.mkdirSync(#{dir}, { recursive: true });
          } catch (e) {
            // ignore if already exists
          }
        }
      end
      `__fs__.writeFileSync(#{path}, #{data})`
      data.size
    end

    def exist?(path)
      path = path.path if path.respond_to?(:path)
      path = path.to_s
      `return __fs__.existsSync(#{path})`
    end

    def file?(path)
      return false unless exist?(path)
      %x{
        try {
          var stat = __fs__.statSync(#{path.to_s});
          return stat.isFile();
        } catch (e) {
          return false;
        }
      }
    end

    def directory?(path)
      return false unless exist?(path)
      %x{
        try {
          var stat = __fs__.statSync(#{path.to_s});
          return stat.isDirectory();
        } catch (e) {
          return false;
        }
      }
    end

    def readable?(path)
      exist?(path)
    end

    def writable?(path)
      true
    end

    def executable?(path)
      false
    end

    def size(path)
      %x{
        try {
          return __fs__.statSync(#{path.to_s}).size;
        } catch (e) {
          #{raise Errno::ENOENT, "No such file or directory - #{path}"}
        }
      }
    end

    def open(path, mode = 'r', _perm = nil, &block)
      if block_given?
        file = VirtualFile.new(path, mode)
        begin
          yield file
        ensure
          file.close
        end
      else
        VirtualFile.new(path, mode)
      end
    end

    def foreach(path, &block)
      content = read(path)
      content.each_line(&block)
    end

    def readlines(path, _sep = $/)
      read(path).lines
    end

    def delete(*paths)
      paths.each do |path|
        %x{
          try {
            __fs__.unlinkSync(#{path.to_s});
          } catch (e) {
            // ignore
          }
        }
      end
      paths.size
    end

    def realpath(path, basedir = nil)
      expand_path(path, basedir)
    end

    def stat(path)
      VirtualStat.new(path)
    end

    def mtime(path)
      Time.now
    end

    def symlink?(path)
      false
    end

    def absolute_path(path, basedir = nil)
      path = path.respond_to?(:to_path) ? path.to_path : path.to_s
      basedir ||= '/'
      if path.start_with?('/')
        path
      else
        join(basedir, path)
      end
    end

    def fnmatch?(pattern, path, flags = 0)
      # Simple glob pattern matching
      regex_pattern = pattern
        .gsub('.', '\\.')
        .gsub('**', "\x00")
        .gsub('*', '[^/]*')
        .gsub("\x00", '.*')
        .gsub('?', '.')
      regex = Regexp.new("^#{regex_pattern}$")
      !!(path =~ regex)
    end
  end

  class << self
    alias_method :exists?, :exist?
    alias_method :unlink, :delete
  end
end

# Virtual file handle for File.open
class VirtualFile
  def initialize(path, mode = 'r')
    @path = path.to_s
    @mode = mode.to_s
    @content = +''
    @pos = 0
    @closed = false

    if @mode.include?('r') && File.exist?(@path)
      @content = File.read(@path)
    end
  end

  def read(length = nil)
    if length
      result = @content[@pos, length]
      @pos += length
      result
    else
      result = @content[@pos..-1] || ''
      @pos = @content.length
      result
    end
  end

  def gets(sep = $/)
    return nil if @pos >= @content.length
    if sep.nil?
      return read
    end
    line_end = @content.index(sep, @pos)
    if line_end
      line = @content[@pos..line_end]
      @pos = line_end + sep.length
    else
      line = @content[@pos..-1]
      @pos = @content.length
    end
    line
  end

  def each_line(sep = $/, &block)
    return enum_for(:each_line, sep) unless block_given?
    while (line = gets(sep))
      yield line
    end
    self
  end

  def write(str)
    str = str.to_s
    @content = @content[0, @pos].to_s + str + (@content[@pos + str.length..-1] || '')
    @pos += str.length
    str.length
  end

  def puts(*args)
    args.each do |arg|
      write(arg.to_s)
      write("\n") unless arg.to_s.end_with?("\n")
    end
    nil
  end

  def print(*args)
    args.each { |arg| write(arg.to_s) }
    nil
  end

  def <<(str)
    write(str)
    self
  end

  def flush
    self
  end

  def close
    return if @closed
    @closed = true
    if @mode.include?('w') || @mode.include?('a')
      File.write(@path, @content)
    end
  end

  def closed?
    @closed
  end

  def path
    @path
  end

  def rewind
    @pos = 0
  end

  def pos
    @pos
  end

  def pos=(p)
    @pos = p
  end

  def eof?
    @pos >= @content.length
  end

  def to_s
    @content
  end
end

# Virtual stat object
class VirtualStat
  def initialize(path)
    @path = path.to_s
    @exists = File.exist?(@path)
  end

  def file?
    @exists && File.file?(@path)
  end

  def directory?
    @exists && File.directory?(@path)
  end

  def mtime
    Time.now
  end

  def readable?
    @exists
  end

  def writable?
    true
  end

  def executable?
    false
  end

  def size
    @exists ? File.size(@path) : 0
  end
end
