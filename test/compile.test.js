// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Get Opal reference
const Opal = globalThis.Opal;

test('HTML compilation', () => {
  const source = '= Hello World\n\nThis is a test paragraph.\n';
  const result = ReVIEW.API.$compile(source, 'html', Opal.hash());

  assert.ok(result, 'Compilation should return a result');
  assert.ok(String(result).includes('<!DOCTYPE html>'), 'Result should contain DOCTYPE');
  assert.ok(String(result).includes('Hello World'), 'Result should contain title');
});

test('Markdown compilation', () => {
  const source = '= Hello Markdown\n\nThis is a **bold** test.\n';
  const result = ReVIEW.API.$compile(source, 'markdown', Opal.hash());

  assert.ok(result, 'Compilation should return a result');
  assert.ok(String(result).includes('# Hello Markdown'), 'Result should contain H1');
});

test('LaTeX compilation', () => {
  const source = '= Hello LaTeX\n\nThis is a test paragraph.\n';
  const result = ReVIEW.API.$compile(source, 'latex', Opal.hash());

  assert.ok(result, 'Compilation should return a result');
  assert.ok(String(result).includes('\\chapter{Hello LaTeX}'), 'Result should contain chapter');
});

test('Complex Re:VIEW syntax', () => {
  const source = `= Chapter Title

This is a paragraph with @<b>{bold} and @<i>{italic} text.

== Section Title

 * List item 1
 * List item 2
 * List item 3

//list[sample][Sample Code]{
function hello() {
  console.log("Hello!");
}
//}
`;
  const result = ReVIEW.API.$compile(source, 'html', Opal.hash());
  const resultStr = String(result);

  assert.ok(resultStr.includes('<h1'), 'Result should contain H1 heading');
  assert.ok(resultStr.includes('<h2'), 'Result should contain H2 heading');
  assert.ok(resultStr.includes('<b>'), 'Result should contain bold text');
  assert.ok(resultStr.includes('<i>'), 'Result should contain italic text');
  assert.ok(resultStr.includes('<ul>'), 'Result should contain unordered list');
  assert.ok(resultStr.includes('<li>'), 'Result should contain list items');
  assert.ok(resultStr.includes('<pre'), 'Result should contain code block');
});

test('Multi-file project from fixture directory', () => {
  const fixtureDir = path.join(__dirname, 'fixture');
  const vfs = ReVIEW.vfs;

  // Reset VFS before loading new project
  vfs.reset();

  // Load all fixture files into VFS
  const files = fs.readdirSync(fixtureDir);
  for (const file of files) {
    const content = fs.readFileSync(path.join(fixtureDir, file), 'utf8');
    vfs.writeFile(`/${file}`, content);
  }

  // Verify files are loaded
  assert.ok(vfs.exists('/catalog.yml'), 'catalog.yml should exist in VFS');
  assert.ok(vfs.exists('/config.yml'), 'config.yml should exist in VFS');
  assert.ok(vfs.exists('/chapter1.re'), 'chapter1.re should exist in VFS');

  // Compile chapter1.re with config
  const source = vfs.readFile('/chapter1.re');
  const config = {
    language: 'ja',
    htmlversion: 5
  };
  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // Verify compilation result
  assert.ok(html.includes('基本的な記法'), 'Should contain chapter title');
  assert.ok(html.includes('Hello, World!'), 'Should contain code content');
  assert.ok(html.includes('<b>太字</b>'), 'Should contain bold text');

  // Compile chapter2.re
  const source2 = vfs.readFile('/chapter2.re');
  const result2 = ReVIEW.API.$compile(source2, 'html', options);
  const html2 = String(result2);

  assert.ok(html2.includes('応用的な記法'), 'Should contain chapter2 title');
  assert.ok(html2.includes('サンプル表'), 'Should contain table caption');
});
