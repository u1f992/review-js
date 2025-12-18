# frozen_string_literal: true
# backtick_javascript: true

# MeCab stub using mecab-wasm (https://github.com/itayperl/mecab-wasm)
# Provides Japanese morphological analysis
# globalThis.__mecabWasm__ is set by the ESM wrapper

module MeCab
  %x{
    var __mecabWasm__ = globalThis.__mecabWasm__ || null;
    // MeCab is initialized at module load time via top-level await
    var __mecabReady__ = __mecabWasm__ !== null;
  }

  def self.mecab_available?
    `__mecabWasm__ !== null`
  end

  def self.ready?
    `__mecabReady__ === true`
  end

  # Wait for MeCab WASM to be ready
  # Note: MeCab is already initialized at module load time,
  # so this returns an immediately resolved promise
  def self.wait_ready
    %x{
      if (!__mecabWasm__) {
        return Promise.reject(new Error('mecab-wasm is not available'));
      }
      // Already initialized at module load time
      __mecabReady__ = true;
      return Promise.resolve(true);
    }
  end

  class Tagger
    def initialize(opts = '')
      @opts = opts
      unless MeCab.mecab_available?
        raise LoadError, 'mecab-wasm is not available'
      end
    end

    # Parse text and return MeCab-formatted output string
    # Format: 表層形\t品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用型,活用形,原形,読み,発音
    def parse(text)
      return "EOS\n" if text.nil? || text.empty?

      unless MeCab.ready?
        raise RuntimeError, 'MeCab is not ready. Call MeCab.wait_ready() first.'
      end

      result = %x{
        try {
          var tokens = __mecabWasm__.query(#{text});
          var lines = [];
          for (var i = 0; i < tokens.length; i++) {
            var t = tokens[i];
            // Format: word\tpos,pos_detail1,pos_detail2,pos_detail3,conjugation1,conjugation2,dictionary_form,reading,pronunciation
            var fields = [
              t.pos || '*',
              t.pos_detail1 || '*',
              t.pos_detail2 || '*',
              t.pos_detail3 || '*',
              t.conjugation1 || '*',
              t.conjugation2 || '*',
              t.dictionary_form || '*',
              t.reading || '*',
              t.pronunciation || '*'
            ].join(',');
            lines.push(t.word + '\t' + fields);
          }
          lines.push('EOS');
          return lines.join('\n') + '\n';
        } catch (e) {
          console.error('MeCab parse error:', e);
          return 'EOS\n';
        }
      }
      result
    end

    # Parse to node format (returns structured data)
    def parseToNode(text)
      parse(text)
    end
  end
end
