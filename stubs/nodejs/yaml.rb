# frozen_string_literal: true
# backtick_javascript: true

# Custom YAML module using js-yaml and our virtual File class
# globalThis.jsyaml is expected to be available (loaded in ESM wrapper)

require 'native'

module YAML
  %x{
    var __yaml__ = globalThis.jsyaml || {
      load: function(s) { throw new Error('js-yaml not loaded'); },
      dump: function(o) { throw new Error('js-yaml not loaded'); }
    };
  }

  def self.load(yaml_string, options = {})
    return nil if yaml_string.nil? || yaml_string.empty?
    yaml_string = yaml_string.to_s
    result = `__yaml__.load(#{yaml_string})`
    convert_to_ruby(result)
  end

  def self.safe_load(yaml_string, permitted_classes: [], permitted_symbols: [], aliases: false, filename: nil, symbolize_names: false)
    load(yaml_string)
  end

  def self.load_file(path)
    content = File.read(path)
    load(content)
  end

  def self.safe_load_file(path, permitted_classes: [], aliases: false, symbolize_names: false)
    load_file(path)
  end

  def self.load_path(path)
    load_file(path)
  end

  def self.dump(object, io = nil, options = {})
    result = `__yaml__.dump(#{Native.convert(object)})`
    if io
      io.write(result)
      io
    else
      result
    end
  end

  private

  def self.convert_to_ruby(js_value)
    %x{
      if (#{js_value} === null || #{js_value} === undefined) {
        return nil;
      }

      if (typeof #{js_value} === 'string' ||
          typeof #{js_value} === 'number' ||
          typeof #{js_value} === 'boolean') {
        return #{js_value};
      }

      if (Array.isArray(#{js_value})) {
        return #{`#{js_value}`.map { |v| convert_to_ruby(v) }};
      }

      if (typeof #{js_value} === 'object') {
        var result = #{{}};
        for (var key in #{js_value}) {
          if (#{js_value}.hasOwnProperty(key)) {
            #{`result`[`key`] = convert_to_ruby(`#{js_value}[key]`)};
          }
        }
        return result;
      }

      return #{js_value};
    }
  end
end
