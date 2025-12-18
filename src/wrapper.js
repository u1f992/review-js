// Re:VIEW JS - compiled from Ruby via Opal
// License: LGPL-2.1

import { createFsFromVolume, Volume } from 'memfs';
import { refractor } from 'refractor/all';
import { toHtml } from 'hast-util-to-html';
import * as meaw from 'meaw';
import { parse as csvParse } from 'csv-parse/sync';
import Mecab from '@u1f992/mecab-wasm';

// Initialize virtual filesystem
const vol = new Volume();
const fs = createFsFromVolume(vol);

// Make fs available globally for Opal code
globalThis.__reviewFs__ = fs;
globalThis.__reviewVol__ = vol;

// Make refractor available globally for syntax highlighting
// WARNING: This is a Rouge compatibility shim using refractor (Prism-based)
globalThis.__refractor__ = refractor;
globalThis.__hastToHtml__ = toHtml;

// Make meaw available globally for East Asian Width detection
globalThis.__meaw__ = meaw;

// NKF-compatible Japanese character conversion
// Supports: --hiragana, --katakana, -X (hankaku to zenkaku), -x (zenkaku to hankaku)
globalThis.__nkf__ = {
  // Katakana to Hiragana (U+30A1-U+30F6 -> U+3041-U+3096)
  katakanaToHiragana(str) {
    return str.replace(/[\u30A1-\u30F6]/g, (ch) =>
      String.fromCharCode(ch.charCodeAt(0) - 0x60)
    );
  },

  // Hiragana to Katakana (U+3041-U+3096 -> U+30A1-U+30F6)
  hiraganaToKatakana(str) {
    return str.replace(/[\u3041-\u3096]/g, (ch) =>
      String.fromCharCode(ch.charCodeAt(0) + 0x60)
    );
  },

  // Half-width Katakana to Full-width Katakana
  hankakuToZenkaku(str) {
    const hankakuMap = {
      'ｦ': 'ヲ', 'ｧ': 'ァ', 'ｨ': 'ィ', 'ｩ': 'ゥ', 'ｪ': 'ェ', 'ｫ': 'ォ',
      'ｬ': 'ャ', 'ｭ': 'ュ', 'ｮ': 'ョ', 'ｯ': 'ッ', 'ｰ': 'ー',
      'ｱ': 'ア', 'ｲ': 'イ', 'ｳ': 'ウ', 'ｴ': 'エ', 'ｵ': 'オ',
      'ｶ': 'カ', 'ｷ': 'キ', 'ｸ': 'ク', 'ｹ': 'ケ', 'ｺ': 'コ',
      'ｻ': 'サ', 'ｼ': 'シ', 'ｽ': 'ス', 'ｾ': 'セ', 'ｿ': 'ソ',
      'ﾀ': 'タ', 'ﾁ': 'チ', 'ﾂ': 'ツ', 'ﾃ': 'テ', 'ﾄ': 'ト',
      'ﾅ': 'ナ', 'ﾆ': 'ニ', 'ﾇ': 'ヌ', 'ﾈ': 'ネ', 'ﾉ': 'ノ',
      'ﾊ': 'ハ', 'ﾋ': 'ヒ', 'ﾌ': 'フ', 'ﾍ': 'ヘ', 'ﾎ': 'ホ',
      'ﾏ': 'マ', 'ﾐ': 'ミ', 'ﾑ': 'ム', 'ﾒ': 'メ', 'ﾓ': 'モ',
      'ﾔ': 'ヤ', 'ﾕ': 'ユ', 'ﾖ': 'ヨ',
      'ﾗ': 'ラ', 'ﾘ': 'リ', 'ﾙ': 'ル', 'ﾚ': 'レ', 'ﾛ': 'ロ',
      'ﾜ': 'ワ', 'ﾝ': 'ン', 'ﾞ': '゛', 'ﾟ': '゜',
      '｡': '。', '｢': '「', '｣': '」', '､': '、', '･': '・'
    };
    // Handle voiced/semi-voiced marks (ﾞ, ﾟ) combined with previous char
    let result = '';
    for (let i = 0; i < str.length; i++) {
      const ch = str[i];
      const next = str[i + 1];
      if (hankakuMap[ch]) {
        let zenkaku = hankakuMap[ch];
        // Check for dakuten (voiced mark)
        if (next === 'ﾞ' && 'ｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾊﾋﾌﾍﾎｳ'.includes(ch)) {
          const voicedMap = {
            'カ': 'ガ', 'キ': 'ギ', 'ク': 'グ', 'ケ': 'ゲ', 'コ': 'ゴ',
            'サ': 'ザ', 'シ': 'ジ', 'ス': 'ズ', 'セ': 'ゼ', 'ソ': 'ゾ',
            'タ': 'ダ', 'チ': 'ヂ', 'ツ': 'ヅ', 'テ': 'デ', 'ト': 'ド',
            'ハ': 'バ', 'ヒ': 'ビ', 'フ': 'ブ', 'ヘ': 'ベ', 'ホ': 'ボ',
            'ウ': 'ヴ'
          };
          zenkaku = voicedMap[zenkaku] || zenkaku;
          i++; // Skip the dakuten
        }
        // Check for handakuten (semi-voiced mark)
        else if (next === 'ﾟ' && 'ﾊﾋﾌﾍﾎ'.includes(ch)) {
          const semiVoicedMap = {
            'ハ': 'パ', 'ヒ': 'ピ', 'フ': 'プ', 'ヘ': 'ペ', 'ホ': 'ポ'
          };
          zenkaku = semiVoicedMap[zenkaku] || zenkaku;
          i++; // Skip the handakuten
        }
        result += zenkaku;
      } else {
        result += ch;
      }
    }
    return result;
  },

  // NKF-compatible function
  nkf(options, str) {
    let result = str;
    // Parse options
    const hasHiragana = options.includes('--hiragana');
    const hasKatakana = options.includes('--katakana');
    const hasHankakuToZenkaku = options.includes('-X') || options.includes('X');

    if (hasHankakuToZenkaku) {
      result = this.hankakuToZenkaku(result);
    }
    if (hasHiragana) {
      result = this.katakanaToHiragana(result);
    }
    if (hasKatakana) {
      result = this.hiraganaToKatakana(result);
    }
    return result;
  }
};

// CSV parser using csv-parse
globalThis.__csv__ = {
  parse(content, options = {}) {
    return csvParse(content, {
      columns: options.headers || false,
      skip_empty_lines: true,
      relax_column_count: true,
      ...options
    });
  }
};

// Make mecab-wasm available globally for Japanese morphological analysis
// Initialize MeCab WASM at module load time
globalThis.__mecabWasm__ = Mecab;
await Mecab.waitReady();

// Opal runtime
/* __OPAL_RUNTIME__ */

// Re:VIEW compiled code
/* __REVIEW_CODE__ */

/**
 * Virtual FileSystem API for users
 */
class VirtualFileSystem {
  constructor() {
    this.vol = vol;
    this.fs = fs;
  }

  /**
   * Add a file to the virtual filesystem
   * @param {string} path - File path (e.g., '/content/chapter1.re')
   * @param {string} content - File content
   */
  writeFile(path, content) {
    // Ensure parent directory exists
    const dir = path.substring(0, path.lastIndexOf('/'));
    if (dir && dir !== '/' && !this.fs.existsSync(dir)) {
      this.fs.mkdirSync(dir, { recursive: true });
    }
    this.fs.writeFileSync(path, content);
  }

  /**
   * Read a file from the virtual filesystem
   * @param {string} path - File path
   * @returns {string} File content
   */
  readFile(path) {
    return this.fs.readFileSync(path, 'utf8');
  }

  /**
   * Check if a file exists
   * @param {string} path - File path
   * @returns {boolean}
   */
  exists(path) {
    return this.fs.existsSync(path);
  }

  /**
   * Delete a file
   * @param {string} path - File path
   */
  deleteFile(path) {
    if (this.fs.existsSync(path)) {
      this.fs.unlinkSync(path);
    }
  }

  /**
   * Create a directory
   * @param {string} path - Directory path
   * @param {boolean} recursive - Create parent directories if needed
   */
  mkdir(path, recursive = true) {
    this.fs.mkdirSync(path, { recursive });
  }

  /**
   * List files in a directory
   * @param {string} path - Directory path
   * @returns {string[]} File names
   */
  listFiles(path) {
    if (!this.fs.existsSync(path)) {
      return [];
    }
    return this.fs.readdirSync(path);
  }

  /**
   * Load multiple files from a JSON object
   * @param {Object} files - Object with path keys and content values
   */
  fromJSON(files) {
    this.vol.fromJSON(files);
  }

  /**
   * Export all files to a JSON object
   * @returns {Object} Object with path keys and content values
   */
  toJSON() {
    return this.vol.toJSON();
  }

  /**
   * Clear all files
   */
  reset() {
    this.vol.reset();
  }
}

// ESM exports
const ReVIEW = Opal.ReVIEW;
const vfs = new VirtualFileSystem();

// Attach VFS to ReVIEW module for convenience
ReVIEW.vfs = vfs;

export { ReVIEW, vfs, VirtualFileSystem };
export default ReVIEW;
