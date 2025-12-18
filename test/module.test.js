// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
const Opal = globalThis.Opal;

test('Module loading', () => {
  assert.notStrictEqual(typeof ReVIEW, "undefined");
});

test('Available classes', () => {
  const expectedClasses = ['Compiler', 'HTMLBuilder', 'MARKDOWNBuilder', 'LATEXBuilder', 'API', 'Book'];
  for (const className of expectedClasses) {
    assert.ok(ReVIEW[className], `${className} should be available`);
  }
});

test('HTMLBuilder instantiation', () => {
  const builder = ReVIEW.HTMLBuilder.$new();
  assert.ok(builder, 'HTMLBuilder should be instantiated');
});

test('Book module contents', () => {
  assert.ok(ReVIEW.Book, 'Book module should exist');
  assert.ok(ReVIEW.Book.VirtualBook, 'VirtualBook should be available');
  assert.ok(ReVIEW.Book.VirtualChapter, 'VirtualChapter should be available');

  const vb = ReVIEW.Book.VirtualBook.$new(Opal.hash());
  assert.ok(vb, 'VirtualBook should be instantiated');
});

test('I18n', () => {
  assert.ok(ReVIEW.I18n, 'I18n module should be available');

  // Initialize I18n with Japanese locale
  ReVIEW.I18n.$setup('ja', Opal.nil);

  const imageLabel = ReVIEW.I18n.$t('image');
  assert.strictEqual(imageLabel, '図', 'Image label should be "図" in Japanese');
});

test('API methods', () => {
  assert.strictEqual(ReVIEW.API.$version(), '0.1.0', 'Version should be 0.1.0');
  assert.deepStrictEqual(
    ReVIEW.API.$available_formats(),
    ['html', 'markdown', 'latex'],
    'Available formats should match'
  );
});
