// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
const Opal = globalThis.Opal;

// The join_lines_by_lang feature uses Unicode::Eaw to determine
// whether to insert spaces when joining lines in paragraphs.
// For Japanese/Chinese text, spaces are not inserted between CJK characters.

test('join_lines_by_lang with Japanese text removes unnecessary spaces', () => {
  // Japanese text split across lines should not have spaces inserted
  const source = `= テスト

これは日本語の
テストです。
`;

  const config = {
    language: 'ja',
    join_lines_by_lang: true
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // Lines should be joined without space between Japanese characters
  assert.ok(html.includes('日本語のテスト'), 'Japanese lines should be joined without space');
});

test('join_lines_by_lang with mixed content handles spaces correctly', () => {
  // Mixed Japanese and ASCII text
  const source = `= テスト

日本語と
English text
が混在。
`;

  const config = {
    language: 'ja',
    join_lines_by_lang: true
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // Should include both Japanese and English text
  assert.ok(html.includes('日本語'), 'Should include Japanese text');
  assert.ok(html.includes('English'), 'Should include English text');
});

test('without join_lines_by_lang, lines are joined as-is', () => {
  const source = `= Test

Line one
Line two
`;

  // Without join_lines_by_lang setting
  const options = Opal.hash({});
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('Line'), 'Should include text');
});

test('Unicode::Eaw is available after requiring', () => {
  // Verify the module is available
  const Unicode = Opal.Unicode;
  assert.ok(Unicode, 'Unicode module should be available');
  assert.ok(Unicode.Eaw, 'Unicode::Eaw module should be available');

  // Test basic property detection
  const propJa = Unicode.Eaw.$property('あ');
  assert.strictEqual(propJa.toString(), 'W', 'Japanese hiragana should be Wide');

  const propAscii = Unicode.Eaw.$property('A');
  assert.strictEqual(propAscii.toString(), 'Na', 'ASCII should be Narrow');
});
