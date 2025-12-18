// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

const Opal = globalThis.Opal;

test('NKF is available', () => {
  const NKF = Opal.NKF;
  assert.ok(NKF, 'NKF module should be available');
  assert.ok(NKF['$nkf_available?'](), 'NKF should be available');
});

test('NKF.nkf with --hiragana converts katakana to hiragana', () => {
  const NKF = Opal.NKF;

  // カタカナ → ひらがな
  const katakana = 'ケイタイソカイセキ';
  const result = NKF.$nkf('-w --hiragana', katakana);

  assert.strictEqual(result, 'けいたいそかいせき', 'Should convert katakana to hiragana');
});

test('NKF.nkf with --katakana converts hiragana to katakana', () => {
  const NKF = Opal.NKF;

  // ひらがな → カタカナ
  const hiragana = 'にほんご';
  const result = NKF.$nkf('-w --katakana', hiragana);

  assert.strictEqual(result, 'ニホンゴ', 'Should convert hiragana to katakana');
});

test('NKF.nkf with -X converts hankaku to zenkaku', () => {
  const NKF = Opal.NKF;

  // 半角カナ → 全角カナ
  const hankaku = 'ｱｲｳｴｵ';
  const result = NKF.$nkf('-WwX', hankaku);

  assert.strictEqual(result, 'アイウエオ', 'Should convert hankaku to zenkaku');
});

test('NKF.nkf with -X handles voiced marks (dakuten)', () => {
  const NKF = Opal.NKF;

  // 半角カナ + 濁点 → 全角濁音
  const hankaku = 'ｶﾞｷﾞｸﾞｹﾞｺﾞ';
  const result = NKF.$nkf('-WwX', hankaku);

  assert.strictEqual(result, 'ガギグゲゴ', 'Should convert hankaku with dakuten to zenkaku');
});

test('NKF.nkf with -X handles semi-voiced marks (handakuten)', () => {
  const NKF = Opal.NKF;

  // 半角カナ + 半濁点 → 全角半濁音
  const hankaku = 'ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ';
  const result = NKF.$nkf('-WwX', hankaku);

  assert.strictEqual(result, 'パピプペポ', 'Should convert hankaku with handakuten to zenkaku');
});

test('LaTeX index with Japanese text converts yomi to hiragana', () => {
  const source = `= テスト

日本語の@<idx>{形態素解析}をテストします。
`;

  const result = ReVIEW.API.$compile(source, 'latex', Opal.hash());
  const latex = String(result);

  // MeCab returns katakana reading, NKF converts to hiragana
  // Expected: \index{けいたいそかいせき@形態素解析}
  assert.ok(latex.includes('\\index{'), 'Should contain index command');

  // Check that the yomi is in hiragana (not katakana)
  const indexMatch = latex.match(/\\index\{([^@]+)@/);
  if (indexMatch) {
    const yomi = indexMatch[1];
    // Hiragana range: U+3040-U+309F
    const hasHiragana = /[\u3040-\u309F]/.test(yomi);
    // Katakana range: U+30A0-U+30FF
    const hasKatakana = /[\u30A0-\u30FF]/.test(yomi);

    assert.ok(hasHiragana, `Yomi should contain hiragana: ${yomi}`);
    assert.ok(!hasKatakana, `Yomi should not contain katakana: ${yomi}`);
  }
});
