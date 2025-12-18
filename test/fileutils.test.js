// @ts-check

import { vfs } from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
const Opal = globalThis.Opal;

test('FileUtils integration with memfs', () => {
  vfs.reset();

  /** @type {any} */
  const FileUtils = Opal.FileUtils;

  // mkdir_p
  FileUtils.$mkdir_p('/test/nested/dir');
  assert.ok(vfs.exists('/test/nested/dir'), 'mkdir_p should create nested directories');

  // touch
  FileUtils.$touch('/test/nested/file.txt');
  assert.ok(vfs.exists('/test/nested/file.txt'), 'touch should create file');

  // Write content for cp/mv tests
  vfs.writeFile('/test/source.txt', 'Hello');

  // cp
  FileUtils.$cp('/test/source.txt', '/test/dest.txt');
  assert.ok(vfs.exists('/test/dest.txt'), 'cp should copy file');
  assert.strictEqual(vfs.readFile('/test/dest.txt'), 'Hello', 'cp should preserve content');

  // mv
  FileUtils.$mv('/test/dest.txt', '/test/moved.txt');
  assert.ok(!vfs.exists('/test/dest.txt'), 'mv should remove source');
  assert.ok(vfs.exists('/test/moved.txt'), 'mv should create destination');

  // rm_f
  FileUtils.$rm_f('/test/moved.txt');
  assert.ok(!vfs.exists('/test/moved.txt'), 'rm_f should delete file');

  // rm_rf
  FileUtils.$rm_rf('/test');
  assert.ok(!vfs.exists('/test'), 'rm_rf should delete directory recursively');

  vfs.reset();
});
