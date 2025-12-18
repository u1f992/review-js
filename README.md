# Re:VIEW-js

Re:VIEW markup language parser and converter compiled to JavaScript via Opal

> Re:VIEW is an easy-to-use digital publishing system for paper books and ebooks.

⚠ This project is primarily created and maintained by AI agents, as the author does not have sufficient expertise in Ruby. Contributions are welcome if you are interested.

## Feature Support

This section describes which Re:VIEW features are supported in review-js.

### Output Formats (Builders)

| Format | Status | Notes |
|--------|--------|-------|
| HTML | ✅ Supported | HTMLBuilder |
| Markdown | ✅ Supported | MARKDOWNBuilder |
| LaTeX | ✅ Supported | LATEXBuilder |
| EPUB | ❌ Not supported | EPUBmaker not loaded |
| PDF | ❌ Not supported | PDFmaker not loaded (can convert LaTeX output externally) |
| InDesign XML | ❌ Not supported | IDGXMLBuilder not loaded |
| Plain Text | ❌ Not supported | TextBuilder not loaded |
| RST | ❌ Not supported | RSTBuilder not loaded |
| TOP | ❌ Not supported | TOPBuilder not loaded |

### CLI Tools

❌ Not supported, API only.

### Block Commands

| Command | Status | Notes |
|---------|--------|-------|
| `//list`, `//listnum` | ✅ Supported | Code listings |
| `//emlist`, `//emlistnum` | ✅ Supported | Unnumbered code listings |
| `//source`, `//cmd` | ✅ Supported | |
| `//table`, `//imgtable`, `//emtable` | ✅ Supported | Tables |
| `//image`, `//indepimage`, `//numberlessimage` | ✅ Supported | Image references (actual files needed separately) |
| `//footnote` | ✅ Supported | Footnotes |
| `//lead`, `//read` | ✅ Supported | Lead text |
| `//quote`, `//blockquote` | ✅ Supported | Quotations |
| `//note`, `//memo`, `//tip`, `//info` | ✅ Supported | Mini-columns |
| `//warning`, `//important`, `//caution`, `//notice` | ✅ Supported | Mini-columns |
| `//box`, `//flushright`, `//centering` | ✅ Supported | |
| `//bibpaper` | ✅ Supported | Bibliography |
| `//texequation` | ⚠️ Partial | LaTeX output works, image conversion not supported |
| `//graph` | ⚠️ Partial | Markup works, image generation not supported |
| `//embed`, `//comment` | ✅ Supported | |

### Inline Commands

| Command | Status | Notes |
|---------|--------|-------|
| `@<b>{}`, `@<i>{}`, `@<tt>{}` | ✅ Supported | Text decoration |
| `@<code>{}`, `@<ttb>{}`, `@<tti>{}` | ✅ Supported | Code |
| `@<em>{}`, `@<strong>{}`, `@<u>{}` | ✅ Supported | Emphasis |
| `@<kw>{}`, `@<bou>{}`, `@<ami>{}` | ✅ Supported | |
| `@<ruby>{}`, `@<tcy>{}` | ✅ Supported | Ruby text, tate-chu-yoko |
| `@<fn>{}`, `@<endnote>{}` | ✅ Supported | Footnote references |
| `@<chap>{}`, `@<chapref>{}`, `@<title>{}` | ✅ Supported | Chapter references |
| `@<list>{}`, `@<img>{}`, `@<table>{}` | ✅ Supported | Element references |
| `@<hd>{}`, `@<secref>{}`, `@<sec>{}` | ✅ Supported | Heading references |
| `@<href>{}` | ✅ Supported | Links |
| `@<idx>{}`, `@<hidx>{}` | ✅ Supported | Index entries (with MeCab reading generation) |
| `@<m>{}` | ⚠️ Partial | LaTeX math output works, image conversion not supported |
| `@<raw>{}`, `@<embed>{}` | ✅ Supported | Raw output |
| `@<br>{}`, `@<uchar>{}` | ✅ Supported | |

### Special Features

| Feature | Status | Notes |
|---------|--------|-------|
| Syntax highlighting | ✅ Supported | refractor (Prism), 297 languages |
| Japanese morphological analysis | ✅ Supported | mecab-wasm |
| East Asian Width detection | ✅ Supported | meaw |
| i18n (multilingual) | ✅ Supported | Japanese/English |
| Virtual filesystem | ✅ Supported | memfs |
| ImgMath (math to image) | ❌ Not supported | Requires external tools |
| ImgGraph (graph to image) | ❌ Not supported | Requires external tools |
| External command execution | ❌ Not supported | Open3 is stubbed |
| Preprocessor | ❌ Not supported | `#@mapfile` etc. |

### Summary

**What review-js CAN do:**
- Compile Re:VIEW source to HTML / Markdown / LaTeX
- Use almost all block and inline commands
- Syntax highlighting for code blocks
- Auto-generate readings (yomi) for Japanese index entries
- Run in both browser and Node.js environments

**What review-js CANNOT do:**
- Generate EPUB/PDF/other formats directly
- Convert math equations or graphs to images
- Use preprocessor features
- Run as CLI tools
- Execute features requiring external commands

## File Categories

### Stubs (maintained in this repo)

Files in `stubs/` that provide Opal-compatible stubs for Ruby standard library:

- `stubs/memfs_file.rb` - File class implementation using memfs
- `stubs/memfs_dir.rb` - Dir class implementation using memfs
- `stubs/memfs_fileutils.rb` - FileUtils module implementation using memfs
- `stubs/nodejs/yaml.rb` - YAML module integrated with memfs File class
- `stubs/rouge.rb`, `stubs/pygments.rb` - Syntax highlighting via refractor (Prism-based)
- `stubs/MeCab.rb` - Japanese morphological analysis via mecab-wasm
- `stubs/unicode/eaw.rb` - East Asian Width detection via meaw
- `stubs/nkf.rb` - Japanese character conversion (hiragana/katakana, hankaku/zenkaku)
- `stubs/csv.rb` - CSV parsing via csv-parse
- `stubs/logger.rb`, etc. - Opal-compatible implementations
- `stubs/review_opal.rb` - Main entry point
- `stubs/review_opal/api.rb` - JavaScript API wrapper

### Patches (maintained in this repo)

Files in `patches/` that modify original Re:VIEW files for Opal compatibility:

- Applied automatically during build via `rake patch`
- Generated files go to `stubs/review/` (gitignored)

| Patch | Changes |
|-------|---------|
| `builder.patch` | Static minicolumn methods, disable ImgMath/ImgGraph, fix regex for Opal |
| `catalog.patch` | Use nodejs/yaml instead of yaml |
| `compiler.patch` | Array-based string building in `text` method |
| `htmlbuilder.patch` | Static minicolumn methods, inline HTML template |
| `i18n.patch` | Hardcoded i18n data, immutable string operations, use nodejs/yaml |
| `latexbuilder.patch` | Static minicolumn methods |
| `markdownbuilder.patch` | Static minicolumn methods |
| `plaintextbuilder.patch` | Static minicolumn methods |
| `yamlloader.patch` | Use nodejs/yaml instead of yaml |

## Development Workflow

### Modifying Patches

1. Apply current patches:
   ```bash
   bundle install && bundle exec rake patch
   ```

2. Edit the generated files in `stubs/review/`

3. Regenerate patches:
   ```bash
   bundle exec rake genpatch
   ```

4. Test the build:
   ```bash
   npm run clean
   npm run build
   npm test
   ```

### Rake Tasks

| Task | Description |
|------|-------------|
| `rake build` | Apply patches and build (default) |
| `rake patch` | Apply patches to original files |
| `rake clean` | Remove generated files |
| `rake genpatch` | Regenerate patches from current stubs/review/ |

### Updating for New Re:VIEW Version

1. Update `review/` submodule to new version
2. Run clean build - patches may fail if upstream changed
3. Fix any patch conflicts manually
4. Regenerate patches with `rake genpatch`

## Opal Compatibility Notes

### Unsupported Features (Patched)

1. **Mutable String Methods**
   - `String#gsub!`, `String#sub!`, `String#<<` not supported
   - Use `str = str.gsub(...)` instead

2. **Dynamic Method Definition**
   - `class_eval` with string argument not supported
   - Use static method definitions

3. **File System Access**
   - Node.js `fs` module not available in browser
   - Uses [memfs](https://github.com/streamich/memfs) for in-memory virtual filesystem
   - `File.read`, `File.write`, `File.exist?` work via memfs

## Virtual FileSystem (memfs)

This project uses **memfs** to provide an in-memory virtual filesystem. This allows file operations to work in both Node.js and browser environments without actual filesystem access.

### JavaScript API

```javascript
import ReVIEW, { vfs } from '@u1f992/review-js';

// Write files to virtual filesystem
vfs.writeFile('/book/chapter1.re', '= Chapter 1\n\nContent here.');
vfs.writeFile('/book/chapter2.re', '= Chapter 2\n\nMore content.');

// Read files
const content = vfs.readFile('/book/chapter1.re');

// Check existence
if (vfs.exists('/book/chapter1.re')) {
  console.log('File exists');
}

// List directory contents
const files = vfs.listFiles('/book');
// => ['chapter1.re', 'chapter2.re']

// Bulk import from JSON
vfs.fromJSON({
  '/book/catalog.yml': 'CHAPS:\n  - intro.re',
  '/book/intro.re': '= Introduction\n\nWelcome!'
});

// Export all files to JSON
const allFiles = vfs.toJSON();

// Clear all files
vfs.reset();
```

### VFS Methods

| Method | Description |
|--------|-------------|
| `writeFile(path, content)` | Write a file (creates parent directories) |
| `readFile(path)` | Read file contents as string |
| `exists(path)` | Check if file exists |
| `deleteFile(path)` | Delete a file |
| `mkdir(path, recursive?)` | Create directory |
| `listFiles(path)` | List files in directory |
| `fromJSON(files)` | Bulk import files from `{path: content}` object |
| `toJSON()` | Export all files to `{path: content}` object |
| `reset()` | Clear all files |

### Ruby Integration

The virtual filesystem is shared between JavaScript and Ruby (Opal) code:

```javascript
// Write via JavaScript VFS
vfs.writeFile('/test.txt', 'Hello from JS');

// Read via Ruby File class (Opal)
const content = Opal.File.$read('/test.txt');
// => 'Hello from JS'

// Write via Ruby
Opal.File.$write('/ruby.txt', 'Hello from Ruby');

// Read via JavaScript VFS
const rubyContent = vfs.readFile('/ruby.txt');
// => 'Hello from Ruby'
```

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                    User Code                         │
├──────────────────────┬──────────────────────────────┤
│   JavaScript API     │      Ruby (Opal) API         │
│   vfs.writeFile()    │      File.read()             │
│   vfs.readFile()     │      File.write()            │
├──────────────────────┴──────────────────────────────┤
│              globalThis.__reviewFs__                 │
├─────────────────────────────────────────────────────┤
│                 memfs (Volume)                       │
│            In-memory filesystem                      │
└─────────────────────────────────────────────────────┘
```

## Syntax Highlighting

This project supports syntax highlighting for code blocks using [refractor](https://github.com/wooorm/refractor) (a Prism-based highlighter). Both Rouge and Pygments configurations are supported through compatibility shims.

### Usage

Enable syntax highlighting via the `highlight` config option:

```javascript
import ReVIEW from '@u1f992/review-js';
const Opal = globalThis.Opal;

const source = `= Code Sample

//list[sample][JavaScript Example][javascript]{
const x = 42;
console.log(x);
//}
`;

// Enable Rouge or Pygments highlighting
const config = {
  highlight: {
    html: 'rouge'  // or 'pygments'
  }
};

const options = Opal.hash({ config: Opal.hash(config) });
const result = ReVIEW.API.$compile(source, 'html', options);
```

### Language Hints

A language hint (third parameter in `//list`) is required for syntax highlighting:

```
//list[id][caption][language]{
code here
//}
```

Supported language aliases include:
- `js` → `javascript`
- `ts` → `typescript`
- `py`, `python3` → `python`
- `rb` → `ruby`
- `sh`, `shell`, `zsh` → `bash`
- `yml` → `yaml`

### Supported Languages

refractor/all provides 297 languages. Common languages include:
- JavaScript, TypeScript, Python, Ruby, Java, C, C++, Go, Rust
- HTML, CSS, JSON, YAML, Markdown
- Bash, SQL, PHP, Swift, Kotlin

### Limitations

The Rouge/Pygments shims have the following limitations compared to their native Ruby implementations:

| Feature | Status |
|---------|--------|
| Basic syntax highlighting | Supported |
| Language detection | Requires explicit language hint |
| Custom themes | Not supported (use CSS for Prism tokens) |
| Line numbers (Rouge HTMLTable) | Supported |
| Inline styles (Pygments noclasses) | Not supported (always uses CSS classes) |
| All 297 Prism languages | Supported |

### CSS Styling

The highlighted code uses Prism-style CSS classes. Add a Prism theme CSS to style the output:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/prismjs/themes/prism.css">
```

Or target the token classes directly:

```css
.token.keyword { color: #07a; }
.token.string { color: #690; }
.token.function { color: #dd4a68; }
/* ... */
```

## Japanese Morphological Analysis (MeCab)

This project includes [mecab-wasm](https://github.com/itayperl/mecab-wasm) for Japanese morphological analysis. This is used for generating index entries with readings (yomi) in LaTeX output.

### Usage in Re:VIEW

Use `@<idx>` or `@<hidx>` inline commands to create index entries:

```review
日本語の@<idx>{索引}を作成します。
複数の読みを含む@<hidx>{形態素解析}エントリも対応。
```

When compiled to LaTeX, MeCab automatically generates readings:

```latex
日本語の\index{さくいん@索引}索引を作成します。
複数の読みを含む\index{けいたいそかいせき@形態素解析}エントリも対応。
```

### Ruby API

```ruby
require 'MeCab'

tagger = MeCab::Tagger.new
result = tagger.parse("形態素解析")
# => "形態\t名詞,一般,*,*,*,*,形態,ケイタイ,ケイタイ\n素\t..."
```

### Limitations

- MeCab WASM is loaded at module initialization time
- Dictionary is bundled with mecab-wasm (IPA dictionary)
- Custom dictionaries are not supported

## East Asian Width Detection

This project uses [meaw](https://github.com/susisu/meaw) for Unicode East Asian Width property detection. This is used for proper line joining in Japanese text with the `join_lines_by_lang` configuration.

### Ruby API

```ruby
require 'unicode/eaw'

Unicode::Eaw.property('あ')  # => :W (Wide)
Unicode::Eaw.property('A')   # => :Na (Narrow)
Unicode::Eaw.width('日本語') # => 6 (3 characters × 2 width)
```

### Configuration

Enable language-aware line joining in your Re:VIEW config:

```yaml
join_lines_by_lang: true
```

This prevents unwanted spaces when joining lines in CJK text while preserving spaces for Latin text.
