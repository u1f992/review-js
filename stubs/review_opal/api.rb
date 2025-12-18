# frozen_string_literal: true
# backtick_javascript: true

# JavaScript API for Re:VIEW
module ReVIEW
  module API
    # Compile Re:VIEW source to specified format
    # @param source [String] Re:VIEW source code
    # @param format [String] Output format: 'html', 'markdown', 'latex'
    # @param options [Hash] Compilation options
    # @return [String] Compiled output
    def self.compile(source, format = 'html', options = {})
      config = build_config(options)

      # Initialize I18n if not already done
      locale = config['language'] || 'ja'
      I18n.setup(locale, nil)

      book = Book::VirtualBook.new(config)
      chapter = Book::VirtualChapter.new(book, source, options)

      builder = case format.to_s.downcase
                when 'html'
                  HTMLBuilder.new
                when 'markdown', 'md'
                  MARKDOWNBuilder.new
                when 'latex', 'tex'
                  LATEXBuilder.new
                else
                  raise ArgumentError, "Unknown format: #{format}"
                end

      compiler = Compiler.new(builder)
      compiler.compile(chapter)
    end

    # Parse Re:VIEW source and return AST-like structure
    # @param source [String] Re:VIEW source code
    # @return [Hash] Parsed structure
    def self.parse(source)
      # TODO: Implement AST parser
      { source: source }
    end

    # Get available builders
    # @return [Array<String>] List of available format names
    def self.available_formats
      %w[html markdown latex]
    end

    # Get version
    # @return [String] Version string
    def self.version
      '0.1.0'
    end

    def self.build_config(options)
      user_config = options[:config] || {}
      # Convert nested JS objects to Ruby hashes
      converted_config = convert_js_to_ruby(user_config)
      default_config.merge(converted_config)
    end

    # Recursively convert JavaScript objects to Ruby hashes
    # This is needed because Opal.hash() doesn't deeply convert nested objects
    def self.convert_js_to_ruby(js_value)
      %x{
        if (#{js_value} === null || #{js_value} === undefined) {
          return nil;
        }

        if (typeof #{js_value} === 'string' ||
            typeof #{js_value} === 'number' ||
            typeof #{js_value} === 'boolean') {
          return #{js_value};
        }

        // Check if it's already a Ruby Hash
        if (#{js_value}.$$class && #{js_value}.$$class.$$name === 'Hash') {
          // Recursively convert values in the Hash
          var result = #{{}};
          var keys = Opal.send(#{js_value}, 'keys');
          for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var val = Opal.send(#{js_value}, '[]', [key]);
            #{`result`[`key`] = convert_js_to_ruby(`val`)};
          }
          return result;
        }

        if (Array.isArray(#{js_value})) {
          return #{`#{js_value}`.map { |v| convert_js_to_ruby(v) }};
        }

        if (typeof #{js_value} === 'object') {
          var result = #{{}};
          for (var key in #{js_value}) {
            if (#{js_value}.hasOwnProperty(key)) {
              #{`result`[`key`] = convert_js_to_ruby(`#{js_value}[key]`)};
            }
          }
          return result;
        }

        return #{js_value};
      }
    end

    def self.default_config
      {
        'language' => 'ja',
        'htmlversion' => 5,
        'secnolevel' => 3,
        'table_row_separator' => 'tabs',
        'caption_position' => {
          'list' => 'top',
          'image' => 'top',
          'table' => 'top',
          'equation' => 'top'
        },
        'draft' => false,
        'externallink' => true,
        'chapterlink' => true,
        'htmlext' => 'html',
        'pdfmaker' => {
          'makeindex' => false,
          'makeindex_dic' => nil,
          'makeindex_mecab' => false,
          'makeindex_mecab_opts' => ''
        },
        'texcommand' => 'uplatex'
      }
    end
  end

  # Virtual Book for in-memory compilation
  module Book
    class VirtualBook
      attr_reader :config, :basedir
      attr_accessor :image_types

      def initialize(config = {})
        @config = VirtualConfig.new(config)
        @basedir = '/'
        @image_types = %w[.png .jpg .jpeg .gif .svg]
        @chapters = []
        @chapter_index = VirtualChapterIndex.new(self)
      end

      def chapter_index
        @chapter_index
      end

      def chapters
        @chapters
      end

      def contents
        @chapters
      end

      def htmlversion
        @config['htmlversion'] || 5
      end

      def imagedir
        'images'
      end

      def bib_file
        'bib.re'
      end

      def generate_indexes
        # No-op for virtual book
      end
    end

    class VirtualConfig
      def initialize(hash = {})
        @hash = default_config.merge(hash)
      end

      def [](key)
        @hash[key]
      end

      def []=(key, value)
        @hash[key] = value
      end

      def key?(key)
        @hash.key?(key)
      end

      def fetch(key, default = nil)
        @hash.fetch(key, default)
      end

      def dig(*keys)
        result = @hash
        keys.each do |key|
          return nil if result.nil?
          result = result.is_a?(Hash) ? result[key] : nil
        end
        result
      end

      def maker
        nil
      end

      def check_version(_version, exception: true)
        false
      end

      private

      def default_config
        {
          'language' => 'ja',
          'htmlversion' => 5,
          'secnolevel' => 3,
          'table_row_separator' => 'tabs',
          'caption_position' => {
            'list' => 'top',
            'image' => 'top',
            'table' => 'top',
            'equation' => 'top'
          },
          'draft' => false,
          'externallink' => true,
          'chapterlink' => true,
          'htmlext' => 'html',
          'pdfmaker' => {
            'makeindex' => false,
            'makeindex_dic' => nil,
            'makeindex_mecab' => false,
            'makeindex_mecab_opts' => ''
          },
          'texcommand' => 'uplatex'
        }
      end
    end

    class VirtualChapter
      attr_reader :book, :content, :number, :name

      def initialize(book, content, options = {})
        @book = book
        @content = content.to_s
        @number = options[:chapter_number] || options['chapter_number'] || 1
        @name = options[:chapter_name] || options['chapter_name'] || 'chapter'
        @indexes = {}
        generate_indexes
      end

      def present?
        true
      end

      def title
        # Extract title from first headline
        if @content =~ /\A=\s*(.+)/
          $1.strip
        else
          'Untitled'
        end
      end

      def basename
        @name
      end

      def id
        @name
      end

      def format_number(flag = true)
        @number.to_s
      end

      def generate_indexes
        # Generate indexes from content
        @indexes = {
          list: VirtualIndex.new,
          image: VirtualIndex.new,
          table: VirtualIndex.new,
          footnote: VirtualIndex.new,
          endnote: VirtualIndex.new,
          equation: VirtualIndex.new,
          bibpaper: VirtualIndex.new,
          headline: VirtualIndex.new,
          column: VirtualIndex.new
        }
      end

      def list(id)
        @indexes[:list][id] ||= VirtualIndexItem.new(id, @indexes[:list].size + 1)
      end

      def image(id)
        @indexes[:image][id] ||= VirtualIndexItem.new(id, @indexes[:image].size + 1)
      end

      def table(id)
        @indexes[:table][id] ||= VirtualIndexItem.new(id, @indexes[:table].size + 1)
      end

      def footnote(id)
        @indexes[:footnote][id] ||= VirtualIndexItem.new(id, @indexes[:footnote].size + 1)
      end

      def endnote(id)
        @indexes[:endnote][id] ||= VirtualIndexItem.new(id, @indexes[:endnote].size + 1)
      end

      def endnotes
        @indexes[:endnote].values
      end

      def equation(id)
        @indexes[:equation][id] ||= VirtualIndexItem.new(id, @indexes[:equation].size + 1)
      end

      def bibpaper(id)
        @indexes[:bibpaper][id] ||= VirtualIndexItem.new(id, @indexes[:bibpaper].size + 1)
      end

      def headline(id)
        @indexes[:headline][id] ||= VirtualHeadlineItem.new(id, @indexes[:headline].size + 1)
      end

      def headline_index
        VirtualHeadlineIndex.new(@indexes[:headline])
      end

      def column(id)
        @indexes[:column][id] ||= VirtualIndexItem.new(id, @indexes[:column].size + 1)
      end

      def image_bound?(id)
        false
      end

      def next_chapter
        nil
      end

      def prev_chapter
        nil
      end

      def is_a?(klass)
        super || klass == ReVIEW::Book::Chapter
      end
    end

    class VirtualIndex
      def initialize
        @items = {}
        @counter = 0
      end

      def [](id)
        @items[id]
      end

      def []=(id, item)
        @items[id] = item
      end

      def size
        @items.size
      end

      def values
        @items.values
      end
    end

    class VirtualIndexItem
      attr_reader :id, :number, :content, :caption

      def initialize(id, number, content = nil, caption = nil)
        @id = id
        @number = number
        @content = content || ''
        @caption = caption
      end

      def path
        "images/#{@id}"
      end
    end

    class VirtualHeadlineItem < VirtualIndexItem
      def caption
        @content || @id
      end
    end

    class VirtualHeadlineIndex
      def initialize(items)
        @items = items
      end

      def number(id)
        item = @items[id]
        item ? item.number.to_s : ''
      end
    end

    class VirtualChapterIndex
      def initialize(book)
        @book = book
      end

      def number(id)
        '1'
      end

      def title(id)
        'Chapter'
      end

      def display_string(id)
        "Chapter #{number(id)}"
      end
    end
  end
end
