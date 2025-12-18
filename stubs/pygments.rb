# frozen_string_literal: true
# backtick_javascript: true

# Pygments-compatible syntax highlighter using refractor (Prism-based)
# WARNING: This is a compatibility shim. Some Pygments features may not work exactly the same.
# globalThis.__refractor__ and globalThis.__hastToHtml__ are set by the ESM wrapper

module Pygments
  %x{
    var __refractor__ = globalThis.__refractor__ || null;
    var __hastToHtml__ = globalThis.__hastToHtml__ || null;
    var __pygmentsWarned__ = {};
  }

  def self.refractor_available?
    `__refractor__ !== null`
  end

  def self.warn_once(message)
    %x{
      if (!__pygmentsWarned__[#{message}]) {
        console.warn('Pygments compatibility shim: ' + #{message});
        __pygmentsWarned__[#{message}] = true;
      }
    }
    nil
  end

  # Main highlight method compatible with pygments.rb
  # @param code [String] Source code to highlight
  # @param opts [Hash] Options hash
  #   - :lexer [String] Language name
  #   - :formatter [String] Output format (only 'html' supported)
  #   - :options [Hash] Formatting options
  #     - :nowrap [Boolean] If true, don't wrap in <pre> tags
  #     - :noclasses [Boolean] If true, use inline styles (not supported, ignored)
  #     - :linenos [String] If 'inline', add line numbers
  # @return [String] Highlighted HTML
  def self.highlight(code, opts = {})
    lexer = opts[:lexer]
    options = opts[:options] || {}
    nowrap = options[:nowrap]
    linenos = options[:linenos]

    lang = normalize_language(lexer)

    if refractor_available? && lang && lang != 'text'
      html = highlight_with_refractor(code, lang)
      if html
        if linenos == 'inline'
          html = add_line_numbers(html)
        end
        if nowrap
          html
        else
          %Q(<pre class="highlight"><code class="language-#{lang}">#{html}</code></pre>)
        end
      else
        escape_and_wrap(code, nowrap)
      end
    else
      escape_and_wrap(code, nowrap)
    end
  end

  def self.highlight_with_refractor(code, lang)
    %x{
      try {
        if (!__refractor__.registered(#{lang})) {
          #{warn_once("Language '#{lang}' not found in refractor")};
          return null;
        }
        var tree = __refractor__.highlight(#{code}, #{lang});
        return __hastToHtml__(tree);
      } catch (e) {
        #{warn_once("Highlight error: " + `e.message`)};
        return null;
      }
    }
  end

  def self.add_line_numbers(html)
    lines = html.split("\n")
    lines.each_with_index.map do |line, idx|
      %Q(<span class="lineno">#{idx + 1}</span> #{line})
    end.join("\n")
  end

  def self.escape_html(text)
    text.to_s
        .gsub('&', '&amp;')
        .gsub('<', '&lt;')
        .gsub('>', '&gt;')
        .gsub('"', '&quot;')
  end

  def self.escape_and_wrap(code, nowrap)
    escaped = escape_html(code)
    if nowrap
      escaped
    else
      %Q(<pre class="highlight"><code>#{escaped}</code></pre>)
    end
  end

  def self.normalize_language(name)
    return 'text' if name.nil? || name.to_s.empty?

    mapping = {
      'shell' => 'bash',
      'sh' => 'bash',
      'zsh' => 'bash',
      'console' => 'bash',
      'js' => 'javascript',
      'ts' => 'typescript',
      'py' => 'python',
      'py3' => 'python',
      'python3' => 'python',
      'rb' => 'ruby',
      'yml' => 'yaml',
      'dockerfile' => 'docker',
      'make' => 'makefile',
      'objc' => 'objectivec',
      'objective-c' => 'objectivec',
      'text' => 'text',
      'plain' => 'text',
      '' => 'text'
    }
    mapping[name.to_s.downcase] || name.to_s.downcase
  end

  # Lexer class for compatibility
  class Lexer
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def self.find(name)
      normalized = Pygments.normalize_language(name)
      if Pygments.refractor_available?
        registered = `__refractor__.registered(#{normalized})`
        registered ? new(normalized) : nil
      else
        nil
      end
    end
  end
end
