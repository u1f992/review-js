# frozen_string_literal: true
# backtick_javascript: true

# CSV stub using csv-parse (https://www.npmjs.com/package/csv-parse)
# Provides CSV parsing for dictionary/words_file feature
# globalThis.__csv__ is set by the ESM wrapper

class CSV
  %x{
    var __csv__ = globalThis.__csv__ || null;
  }

  def self.csv_available?
    `__csv__ !== null`
  end

  # Iterate over rows in a CSV file
  # Note: File reading uses the virtual filesystem
  def self.foreach(file, **options, &block)
    return enum_for(:foreach, file, **options) unless block_given?

    content = begin
      File.read(file)
    rescue
      return
    end

    parse(content, **options).each(&block)
  end

  # Parse a CSV string into rows
  # Returns array of arrays, or array of hashes if headers: true
  def self.parse(str, **options)
    return [] if str.nil? || str.empty?

    if csv_available?
      js_options = {}
      js_options[:headers] = true if options[:headers]

      result = %x{
        (function() {
          try {
            return __csv__.parse(#{str}, #{js_options.to_n});
          } catch (e) {
            console.error('CSV parse error:', e);
            return [];
          }
        })()
      }

      # Convert JavaScript result to Ruby
      if options[:headers]
        # Result is array of objects, convert to array of hashes
        result.map { |row| row.to_h }
      else
        result.to_a
      end
    else
      # Fallback: simple parsing without quotes handling
      str.to_s.split("\n").map { |line| line.split(',') }
    end
  end

  # Read entire CSV file
  def self.read(file, **options)
    content = begin
      File.read(file)
    rescue
      return []
    end

    parse(content, **options)
  end
end
