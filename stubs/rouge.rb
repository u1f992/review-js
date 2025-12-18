# frozen_string_literal: true
# backtick_javascript: true

# Rouge-compatible syntax highlighter using refractor (Prism-based)
# WARNING: This is a compatibility shim. Some Rouge features may not work exactly the same.
# globalThis.__refractor__ and globalThis.__hastToHtml__ are set by the ESM wrapper

module Rouge
  VERSION = '0.0.0-refractor'

  %x{
    var __refractor__ = globalThis.__refractor__ || null;
    var __hastToHtml__ = globalThis.__hastToHtml__ || null;
    var __rougeWarned__ = {};
  }

  def self.refractor_available?
    `__refractor__ !== null`
  end

  def self.warn_once(message)
    %x{
      if (!__rougeWarned__[#{message}]) {
        console.warn('Rouge compatibility shim: ' + #{message});
        __rougeWarned__[#{message}] = true;
      }
    }
    nil
  end

  class Lexer
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def self.find(name)
      return nil if name.nil? || name.to_s.empty?

      lang = normalize_language(name.to_s)
      return nil unless lang

      if Rouge.refractor_available?
        registered = `__refractor__.registered(#{lang})`
        if registered
          new(lang)
        else
          Rouge.warn_once("Language '#{name}' not found in refractor, falling back to plaintext")
          nil
        end
      else
        Rouge.warn_once("refractor not available")
        nil
      end
    end

    def self.find_fancy(name, _source = nil)
      find(name)
    end

    def self.normalize_language(name)
      # Map common Rouge language names to Prism/refractor names
      mapping = {
        'shell' => 'bash',
        'sh' => 'bash',
        'zsh' => 'bash',
        'console' => 'bash',
        'js' => 'javascript',
        'ts' => 'typescript',
        'py' => 'python',
        'rb' => 'ruby',
        'yml' => 'yaml',
        'dockerfile' => 'docker',
        'make' => 'makefile',
        'objc' => 'objectivec',
        'objective-c' => 'objectivec',
        'text' => 'plaintext',
        'plain' => 'plaintext',
        '' => 'plaintext'
      }
      mapping[name.downcase] || name.downcase
    end

    def lex(source)
      Tokens.new(source, @name)
    end
  end

  class Tokens
    attr_reader :source, :language

    def initialize(source, language)
      @source = source
      @language = language
    end
  end

  class Lexers
    class PlainText < Lexer
      def initialize
        super('plaintext')
      end
    end
  end

  module Formatters
    class HTML
      def initialize(**options)
        @css_class = options[:css_class] || 'highlight'
      end

      def format(tokens)
        source = tokens.source
        language = tokens.language

        if Rouge.refractor_available? && language && language != 'plaintext'
          html = highlight_with_refractor(source, language)
          if html
            %Q(<pre class="#{@css_class}"><code class="language-#{language}">#{html}</code></pre>)
          else
            %Q(<pre class="#{@css_class}"><code>#{escape_html(source)}</code></pre>)
          end
        else
          %Q(<pre class="#{@css_class}"><code>#{escape_html(source)}</code></pre>)
        end
      end

      def highlight_with_refractor(source, language)
        %x{
          try {
            var tree = __refractor__.highlight(#{source}, #{language});
            return __hastToHtml__(tree);
          } catch (e) {
            #{Rouge.warn_once("Highlight error for #{language}: " + `e.message`)}
            return null;
          }
        }
      end

      def escape_html(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
      end
    end

    class HTMLLineTable < HTML
      def initialize(base_formatter = nil, **options)
        super(**options)
        @base_formatter = base_formatter
        @table_class = options[:table_class] || 'rouge-table'
        @start_line = options[:start_line] || 1
      end

      def format(tokens)
        source = tokens.source
        language = tokens.language
        lines = source.split("\n", -1)

        # Remove trailing empty line if present (split artifact)
        lines.pop if lines.last == ''

        rows = lines.each_with_index.map do |line, idx|
          line_num = @start_line + idx
          highlighted_line = highlight_line(line, language)
          %Q(<tr><td class="rouge-gutter gl"><pre>#{line_num}</pre></td><td class="rouge-code"><pre>#{highlighted_line}</pre></td></tr>)
        end

        %Q(<table class="#{@table_class}"><tbody>#{rows.join}</tbody></table>)
      end

      private

      def highlight_line(line, language)
        if Rouge.refractor_available? && language && language != 'plaintext'
          %x{
            try {
              var tree = __refractor__.highlight(#{line}, #{language});
              return __hastToHtml__(tree);
            } catch (e) {
              return #{escape_html(line)};
            }
          }
        else
          escape_html(line)
        end
      end
    end

    class HTMLTable < HTMLLineTable
    end
  end

  def self.highlight(source, lexer_name, _formatter_name = 'html')
    lexer = Lexer.find(lexer_name)
    if lexer
      formatter = Formatters::HTML.new
      tokens = lexer.lex(source)
      formatter.format(tokens)
    else
      source
    end
  end
end
