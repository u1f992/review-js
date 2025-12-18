# frozen_string_literal: true
# backtick_javascript: true

# Custom Dir implementation using memfs
# This replaces tmpdir.rb and provides full Dir functionality
# globalThis.__reviewFs__ is set by the ESM wrapper

class Dir
  %x{
    var __fs__ = globalThis.__reviewFs__ || {
      readdirSync: function() { return []; },
      mkdirSync: function() {},
      existsSync: function() { return false; },
      statSync: function() { throw new Error('Not initialized'); },
      rmdirSync: function() {}
    };
  }

  def self.pwd
    '/'
  end

  def self.getwd
    pwd
  end

  def self.home
    '/'
  end

  def self.exist?(path)
    path = path.to_s
    %x{
      try {
        var stat = __fs__.statSync(#{path});
        return stat.isDirectory();
      } catch (e) {
        return false;
      }
    }
  end

  def self.mkdir(path, mode = nil)
    path = path.to_s
    %x{
      try {
        __fs__.mkdirSync(#{path}, { recursive: false });
        return 0;
      } catch (e) {
        if (e.code === 'EEXIST') {
          #{raise Errno::EEXIST, "File exists - #{path}"}
        }
        #{raise SystemCallError, e.message}
      }
    }
  end

  def self.rmdir(path)
    path = path.to_s
    %x{
      try {
        __fs__.rmdirSync(#{path});
        return 0;
      } catch (e) {
        #{raise SystemCallError, e.message}
      }
    }
  end

  def self.entries(path)
    path = path.to_s
    %x{
      try {
        var entries = __fs__.readdirSync(#{path});
        return ['.', '..'].concat(entries);
      } catch (e) {
        #{raise Errno::ENOENT, "No such file or directory - #{path}"}
      }
    }
  end

  def self.children(path)
    entries(path).reject { |e| e == '.' || e == '..' }
  end

  def self.empty?(path)
    children(path).empty?
  end

  def self.glob(pattern, flags = 0, base: nil, &block)
    results = []
    pattern = pattern.to_s

    # Handle base directory
    base_dir = base || '/'
    base_dir = '/' if base_dir.empty?

    # Simple glob implementation
    if pattern.include?('**')
      # Recursive glob - collect all files recursively
      all_files = collect_files_recursive(base_dir)
      regex = glob_to_regex(pattern)
      all_files.each do |file|
        if file =~ regex
          results << file
        end
      end
    elsif pattern.include?('*') || pattern.include?('?')
      # Single level glob
      dir = File.dirname(pattern)
      dir = base_dir if dir == '.'
      dir = File.join(base_dir, dir) unless dir.start_with?('/')

      if exist?(dir)
        regex = glob_to_regex(File.basename(pattern))
        children(dir).each do |entry|
          if entry =~ regex
            results << File.join(dir, entry)
          end
        end
      end
    else
      # Literal path
      full_path = pattern.start_with?('/') ? pattern : File.join(base_dir, pattern)
      results << full_path if File.exist?(full_path)
    end

    if block_given?
      results.each(&block)
      nil
    else
      results
    end
  end

  def self.[](pattern)
    glob(pattern)
  end

  # tmpdir compatibility
  def self.tmpdir
    '/tmp'
  end

  def self.mktmpdir(prefix = nil, tmpdir = nil, **options)
    tmpdir ||= self.tmpdir
    prefix ||= 'tmp'
    path = "#{tmpdir}/#{prefix}_#{rand(100000)}"

    # Ensure tmpdir exists
    %x{
      try {
        __fs__.mkdirSync(#{tmpdir}, { recursive: true });
      } catch (e) {
        // ignore
      }
      try {
        __fs__.mkdirSync(#{path});
      } catch (e) {
        // ignore
      }
    }

    if block_given?
      begin
        yield path
      ensure
        # Cleanup
        %x{
          try {
            // Simple recursive delete
            var deleteRecursive = function(p) {
              try {
                var stat = __fs__.statSync(p);
                if (stat.isDirectory()) {
                  var entries = __fs__.readdirSync(p);
                  for (var i = 0; i < entries.length; i++) {
                    deleteRecursive(p + '/' + entries[i]);
                  }
                  __fs__.rmdirSync(p);
                } else {
                  __fs__.unlinkSync(p);
                }
              } catch (e) {
                // ignore
              }
            };
            deleteRecursive(#{path});
          } catch (e) {
            // ignore cleanup errors
          }
        }
      end
    else
      path
    end
  end

  private

  def self.collect_files_recursive(dir, results = [])
    return results unless exist?(dir)

    children(dir).each do |entry|
      full_path = File.join(dir, entry)
      results << full_path
      if File.directory?(full_path)
        collect_files_recursive(full_path, results)
      end
    end
    results
  end

  def self.glob_to_regex(pattern)
    regex_str = pattern
      .gsub('.', '\\.')
      .gsub('**/', '(?:.*/)?')
      .gsub('**', '.*')
      .gsub('*', '[^/]*')
      .gsub('?', '[^/]')
    Regexp.new("^#{regex_str}$")
  end
end
