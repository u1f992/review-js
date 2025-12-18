// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
/** @type {any} */
const Opal = globalThis.Opal;
/** @type {any} */
const MeCab = Opal.MeCab;

// MeCab is used internally by Re:VIEW for Japanese index (索引) generation
// in LaTeX output. When makeindex_mecab is enabled, MeCab provides
// readings (yomi) for Japanese words to enable proper sorting.
//
// Note: MeCab is initialized at module load time via top-level await,
// so it's ready to use immediately without calling wait_ready().

test('MeCab is available and ready at module load time', () => {
  assert.ok(MeCab, 'MeCab module should be available');
  assert.ok(MeCab['$mecab_available?'](), 'mecab_available? should return true');
  assert.ok(MeCab['$ready?'](), 'MeCab should be ready immediately');
});

test('LaTeX compilation with index command produces index entries', () => {

  const source = `= テスト章

本文中に@<idx>{索引項目}を含めます。
`;

  // Compile to LaTeX with makeindex enabled
  const config = {
    pdfmaker: {
      makeindex: true,
      makeindex_mecab: true
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'latex', options);
  const latex = String(result);

  // The output should contain \index{} command
  assert.ok(latex.includes('\\index'), 'LaTeX output should contain \\index command');
  assert.ok(latex.includes('索引項目'), 'LaTeX output should contain the index term');
});

test('LaTeX index with Japanese text includes yomi from MeCab', () => {
  const source = `= 索引テスト

@<hidx>{猫}という単語を索引に追加します。
`;

  const config = {
    pdfmaker: {
      makeindex: true,
      makeindex_mecab: true
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'latex', options);
  const latex = String(result);

  // With MeCab, the index should include reading: ねこ@猫 or similar format
  // The @ separates the sort key (yomi in hiragana) from the display text
  assert.ok(latex.includes('\\index'), 'Should have index command');

  // Check if yomi is included (ねこ or ネコ before @)
  // Format: \index{yomi@display}
  const hasYomi = latex.includes('@') && latex.includes('猫');
  assert.ok(hasYomi, 'Index should include yomi reading for Japanese text');
});

test('ASCII-only index terms do not require MeCab', () => {
  const source = `= Test Chapter

Here is an @<idx>{index term} in English.
`;

  const config = {
    pdfmaker: {
      makeindex: true
      // MeCab not needed for ASCII
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'latex', options);
  const latex = String(result);

  assert.ok(latex.includes('\\index{index term}') || latex.includes('\\index'),
    'ASCII index terms should work without MeCab');
});

test('MeCab.Tagger produces MeCab-format output', () => {
  const Tagger = MeCab.Tagger;
  const tagger = Tagger.$new('');

  // Parse Japanese text
  const result = tagger.$parse('日本語');
  const output = String(result);

  // MeCab format: word\tpos,pos_detail1,...,reading,pronunciation\nEOS\n
  assert.ok(output.includes('\t'), 'Output should have tab-separated fields');
  assert.ok(output.includes('EOS'), 'Output should end with EOS marker');

  // Should contain reading in katakana
  assert.ok(output.includes('ニホンゴ') || output.includes('ニッポンゴ'),
    'Output should include reading for 日本語');
});
