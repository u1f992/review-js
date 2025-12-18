// @ts-check

import ReVIEW, { vfs } from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

const Opal = globalThis.Opal;

test('words_file with @<w>{} expands to dictionary value', () => {
  // Setup: Create a CSV dictionary file in the virtual filesystem
  const dictContent = `"LGPL","Lesser General Public License"
"i18n","internationalization"
"Re:VIEW","Publishing System"`;

  vfs.writeFile('/words.csv', dictContent);

  const source = `= Test

@<w>{LGPL} is a license.
`;

  // The API expects options.config to contain the config hash
  const options = Opal.hash({ config: Opal.hash({ words_file: '/words.csv' }) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('Lesser General Public License'),
    `Should expand @<w>{LGPL} to dictionary value. Got: ${html}`);
});

test('words_file with @<wb>{} expands to bold dictionary value', () => {
  // Setup: Create a CSV dictionary file in the virtual filesystem
  const dictContent = `"i18n","internationalization"`;

  vfs.writeFile('/words_bold.csv', dictContent);

  const source = `= Test

This is @<wb>{i18n}.
`;

  const options = Opal.hash({ config: Opal.hash({ words_file: '/words_bold.csv' }) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // @<wb>{} should produce bold text
  assert.ok(html.includes('<b>internationalization</b>') ||
            html.includes('<strong>internationalization</strong>'),
    `Should expand @<wb>{i18n} to bold dictionary value. Got: ${html}`);
});

test('words_file with Japanese text', () => {
  // Setup: Create a CSV dictionary file with Japanese
  const dictContent = `"形態素","言語の最小単位"
"Ruby","プログラミング言語"`;

  vfs.writeFile('/japanese_words.csv', dictContent);

  const source = `= テスト

@<w>{形態素}を解析します。
`;

  const options = Opal.hash({ config: Opal.hash({ words_file: '/japanese_words.csv' }) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('言語の最小単位'),
    `Should expand Japanese key to Japanese value. Got: ${html}`);
});

test('words_file with quoted CSV fields containing commas', () => {
  // Setup: CSV with commas inside quoted fields
  const dictContent = `"key1","value with, comma"
"key2","another, value, here"`;

  vfs.writeFile('/quoted_words.csv', dictContent);

  const source = `= Test

@<w>{key1} and @<w>{key2}.
`;

  const options = Opal.hash({ config: Opal.hash({ words_file: '/quoted_words.csv' }) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('value with, comma'),
    `Should handle commas in quoted CSV fields. Got: ${html}`);
  assert.ok(html.includes('another, value, here'),
    `Should handle multiple commas in quoted CSV fields. Got: ${html}`);
});

test('words_file with multiple files', () => {
  // Setup: Create two CSV dictionary files
  vfs.writeFile('/dict1.csv', `"word1","definition1"`);
  vfs.writeFile('/dict2.csv', `"word2","definition2"`);

  const source = `= Test

@<w>{word1} and @<w>{word2}.
`;

  // words_file can be an array
  const options = Opal.hash({ config: Opal.hash({ words_file: ['/dict1.csv', '/dict2.csv'] }) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('definition1'),
    `Should expand word1 from first dictionary. Got: ${html}`);
  assert.ok(html.includes('definition2'),
    `Should expand word2 from second dictionary. Got: ${html}`);
});
