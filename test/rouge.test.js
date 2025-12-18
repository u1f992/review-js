// @ts-check

import ReVIEW from '../dist/review.js';

import assert from "node:assert";
import test from "node:test";

// Get Opal reference
const Opal = globalThis.Opal;

test('Syntax highlighting with Rouge produces highlighted HTML', () => {
  // Note: language hint [javascript] is required for syntax highlighting
  const source = `= Code Sample

//list[sample][JavaScript Example][javascript]{
const x = 42;
console.log(x);
//}
`;

  // Enable Rouge highlighting via config
  const config = {
    highlight: {
      html: 'rouge'
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // Basic checks - code should be in the output
  assert.ok(html.includes('const'), 'Output should contain code');
  assert.ok(html.includes('console'), 'Output should contain code');

  // Check that pre/code tags are present
  assert.ok(html.includes('<pre'), 'Output should contain pre tag');

  // Verify syntax highlighting is applied
  // refractor produces <span class="token ..."> elements
  assert.ok(html.includes('<span class="token'), 'Output should contain syntax highlighted tokens');
  assert.ok(html.includes('class="highlight"'), 'Output should have highlight class');
  assert.ok(html.includes('language-javascript'), 'Output should have language-javascript class');
});

test('Code blocks compile without highlight config', () => {
  const source = `= Code Sample

//list[sample][Ruby Example]{
puts "Hello"
//}
`;

  const result = ReVIEW.API.$compile(source, 'html', Opal.hash());
  const html = String(result);

  assert.ok(html.includes('puts'), 'Output should contain code');
  assert.ok(html.includes('<pre'), 'Output should contain pre tag');
});

test('Syntax highlighting with language hint produces highlighted HTML', () => {
  const source = `= Code Sample

//list[sample][Python Code][python]{
def hello():
    print("Hello, World!")
//}
`;

  const config = {
    highlight: {
      html: 'rouge'
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('def'), 'Output should contain Python code');
  assert.ok(html.includes('print'), 'Output should contain Python code');

  // Verify syntax highlighting is applied for Python
  assert.ok(html.includes('<span class="token'), 'Output should contain syntax highlighted tokens');
  assert.ok(html.includes('language-python'), 'Output should have language-python class');
});

test('refractor is available globally', () => {
  /** @type {any} */
  const g = globalThis;

  assert.ok(g.__refractor__, 'refractor should be available globally');
  assert.ok(g.__hastToHtml__, 'hastToHtml should be available globally');

  // Test that refractor can highlight
  const tree = g.__refractor__.highlight('const x = 1;', 'javascript');
  assert.ok(tree, 'refractor.highlight should return a tree');

  const html = g.__hastToHtml__(tree);
  assert.ok(html.includes('<span'), 'HTML should contain span elements');
});

test('refractor supports common languages', () => {
  /** @type {any} */
  const g = globalThis;
  const languages = ['javascript', 'python', 'ruby', 'java', 'c', 'cpp', 'go', 'rust', 'typescript'];

  for (const lang of languages) {
    assert.ok(
      g.__refractor__.registered(lang),
      `Language ${lang} should be registered`
    );
  }
});

// Pygments tests
test('Syntax highlighting with Pygments produces highlighted HTML', () => {
  const source = `= Code Sample

//list[sample][JavaScript Example][javascript]{
const x = 42;
console.log(x);
//}
`;

  // Enable Pygments highlighting via config
  const config = {
    highlight: {
      html: 'pygments'
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  // Basic checks - code should be in the output
  assert.ok(html.includes('const'), 'Output should contain code');
  assert.ok(html.includes('console'), 'Output should contain code');

  // Check that pre tags are present (from Re:VIEW, not Pygments with nowrap)
  assert.ok(html.includes('<pre'), 'Output should contain pre tag');

  // Verify syntax highlighting is applied
  // Pygments shim uses refractor which produces <span class="token ..."> elements
  assert.ok(html.includes('<span class="token'), 'Output should contain syntax highlighted tokens');
});

test('Pygments highlighting with Python code', () => {
  const source = `= Code Sample

//list[sample][Python Code][python]{
def hello():
    print("Hello, World!")
//}
`;

  const config = {
    highlight: {
      html: 'pygments'
    }
  };

  const options = Opal.hash({ config: Opal.hash(config) });
  const result = ReVIEW.API.$compile(source, 'html', options);
  const html = String(result);

  assert.ok(html.includes('def'), 'Output should contain Python code');
  assert.ok(html.includes('print'), 'Output should contain Python code');
  assert.ok(html.includes('<span class="token'), 'Output should contain syntax highlighted tokens');
});
