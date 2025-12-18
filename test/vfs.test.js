// @ts-check

import ReVIEW, { vfs } from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
const Opal = globalThis.Opal;

test('VFS export', () => {
  assert.ok(vfs, 'vfs should be exported');
  assert.ok(ReVIEW.vfs, 'ReVIEW.vfs should be available');
  assert.strictEqual(vfs, ReVIEW.vfs, 'vfs and ReVIEW.vfs should be the same');
});

test('VFS write and read', () => {
  vfs.reset();

  // Write a file
  vfs.writeFile('/test/hello.txt', 'Hello, World!');

  // Check it exists
  assert.ok(vfs.exists('/test/hello.txt'), 'File should exist after writing');

  // Read it back
  const content = vfs.readFile('/test/hello.txt');
  assert.strictEqual(content, 'Hello, World!', 'Content should match');

  // List directory
  const files = vfs.listFiles('/test');
  assert.ok(files.includes('hello.txt'), 'File should be in directory listing');

  // Delete
  vfs.deleteFile('/test/hello.txt');
  assert.ok(!vfs.exists('/test/hello.txt'), 'File should not exist after deletion');

  vfs.reset();
});

test('VFS fromJSON and toJSON', () => {
  vfs.reset();

  // Load from JSON
  vfs.fromJSON({
    '/book/chapter1.re': '= Chapter 1\n\nContent here.',
    '/book/chapter2.re': '= Chapter 2\n\nMore content.'
  });

  // Verify files exist
  assert.ok(vfs.exists('/book/chapter1.re'), 'chapter1.re should exist');
  assert.ok(vfs.exists('/book/chapter2.re'), 'chapter2.re should exist');

  // Read content
  const ch1 = vfs.readFile('/book/chapter1.re');
  assert.ok(ch1.includes('Chapter 1'), 'Content should contain Chapter 1');

  // Export to JSON
  const exported = vfs.toJSON();
  assert.ok('/book/chapter1.re' in exported, 'Export should contain chapter1.re');
  assert.ok('/book/chapter2.re' in exported, 'Export should contain chapter2.re');

  vfs.reset();
});

test('VFS integration with Ruby File class', () => {
  vfs.reset();

  // Write a file using VFS
  vfs.writeFile('/content/test.re', '= Test\n\nParagraph.');

  // Ruby File.read should be able to read it
  /** @type {any} */
  const rubyFile = Opal.File;
  const exists = rubyFile['$exist?']('/content/test.re');
  assert.ok(exists, 'Ruby File.exist? should return true');

  const content = rubyFile.$read('/content/test.re');
  assert.ok(String(content).includes('Test'), 'Ruby File.read should return content');

  vfs.reset();
});
