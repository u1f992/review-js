# frozen_string_literal: true
# backtick_javascript: true

# FileUtils implementation using memfs
# globalThis.__reviewFs__ is set by the ESM wrapper

module FileUtils
  %x{
    var __fs__ = globalThis.__reviewFs__ || {
      mkdirSync: function() {},
      existsSync: function() { return false; },
      statSync: function() { throw new Error('Not initialized'); },
      readdirSync: function() { return []; },
      unlinkSync: function() {},
      rmdirSync: function() {},
      readFileSync: function() { return ''; },
      writeFileSync: function() {}
    };

    function deleteRecursive(path) {
      try {
        var stat = __fs__.statSync(path);
        if (stat.isDirectory()) {
          var entries = __fs__.readdirSync(path);
          for (var i = 0; i < entries.length; i++) {
            deleteRecursive(path + '/' + entries[i]);
          }
          __fs__.rmdirSync(path);
        } else {
          __fs__.unlinkSync(path);
        }
      } catch (e) {
        // ignore errors
      }
    }
  }

  def self.mkdir_p(path, **options)
    path = path.to_s
    %x{
      try {
        __fs__.mkdirSync(#{path}, { recursive: true });
      } catch (e) {
        // ignore if already exists
      }
    }
  end

  def self.mkdir(path, **options)
    path = path.to_s
    %x{
      try {
        __fs__.mkdirSync(#{path}, { recursive: false });
      } catch (e) {
        if (e.code !== 'EEXIST') {
          #{raise SystemCallError, `e.message`}
        }
      }
    }
  end

  def self.rm_rf(path)
    path = path.to_s
    `deleteRecursive(#{path})`
  end

  def self.rm_r(path, **options)
    rm_rf(path)
  end

  def self.rm_f(path)
    path = path.to_s
    %x{
      try {
        if (__fs__.existsSync(#{path})) {
          __fs__.unlinkSync(#{path});
        }
      } catch (e) {
        // ignore errors
      }
    }
  end

  def self.rm(path, **options)
    if options[:force]
      rm_f(path)
    else
      path = path.to_s
      %x{
        try {
          __fs__.unlinkSync(#{path});
        } catch (e) {
          #{raise Errno::ENOENT, "No such file or directory - #{path}"}
        }
      }
    end
  end

  def self.cp(src, dest, **options)
    src = src.to_s
    dest = dest.to_s
    %x{
      try {
        var content = __fs__.readFileSync(#{src});

        // Check if dest is a directory
        var destPath = #{dest};
        try {
          var destStat = __fs__.statSync(destPath);
          if (destStat.isDirectory()) {
            var basename = #{File.basename(src)};
            destPath = destPath + '/' + basename;
          }
        } catch (e) {
          // dest doesn't exist, use as-is
        }

        __fs__.writeFileSync(destPath, content);
      } catch (e) {
        #{raise Errno::ENOENT, "No such file or directory - #{src}"}
      }
    }
  end

  def self.cp_r(src, dest, **options)
    src = src.to_s
    dest = dest.to_s

    if File.directory?(src)
      mkdir_p(dest)
      Dir.children(src).each do |entry|
        cp_r(File.join(src, entry), File.join(dest, entry), **options)
      end
    else
      cp(src, dest, **options)
    end
  end

  def self.mv(src, dest, **options)
    src = src.to_s
    dest = dest.to_s
    %x{
      try {
        var content = __fs__.readFileSync(#{src});

        // Check if dest is a directory
        var destPath = #{dest};
        try {
          var destStat = __fs__.statSync(destPath);
          if (destStat.isDirectory()) {
            var basename = #{File.basename(src)};
            destPath = destPath + '/' + basename;
          }
        } catch (e) {
          // dest doesn't exist, use as-is
        }

        __fs__.writeFileSync(destPath, content);
        deleteRecursive(#{src});
      } catch (e) {
        #{raise Errno::ENOENT, "No such file or directory - #{src}"}
      }
    }
  end

  def self.ln_s(src, dest, **options)
    # Symbolic links not supported in memfs virtual filesystem
    # Fall back to copy with warning
    warn "FileUtils.ln_s: symbolic links not supported in memfs, using copy instead"
    cp(src, dest, **options) unless options[:force] == false && File.exist?(dest)
  end

  def self.ln(src, dest, **options)
    # Hard links not supported - fall back to copy
    warn "FileUtils.ln: hard links not supported in memfs, using copy instead"
    cp(src, dest, **options)
  end

  def self.touch(path, **options)
    path = path.to_s
    %x{
      if (!__fs__.existsSync(#{path})) {
        // Ensure parent directory exists
        var dir = #{File.dirname(path)};
        if (dir !== '/' && dir !== '.') {
          try {
            __fs__.mkdirSync(dir, { recursive: true });
          } catch (e) {}
        }
        __fs__.writeFileSync(#{path}, '');
      }
    }
  end

end
