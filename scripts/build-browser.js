import esbuild from 'esbuild';
import { NodeModulesPolyfillPlugin } from '@esbuild-plugins/node-modules-polyfill';
import { NodeGlobalsPolyfillPlugin } from '@esbuild-plugins/node-globals-polyfill';
import { copyFileSync } from 'node:fs';

await esbuild.build({
  entryPoints: ['dist/review.js'],
  bundle: true,
  format: 'esm',
  platform: 'browser',
  outfile: 'dist/review.browser.js',
  plugins: [
    NodeModulesPolyfillPlugin(),
    NodeGlobalsPolyfillPlugin({ process: true, buffer: true }),
  ],
  logOverride: {
    // Opal generates UMD-style code that checks for CommonJS environment:
    //   typeof module!=="undefined"){module.exports=f()}
    // This pattern is harmless in browser ESM context - the `module` variable
    // is undefined, so the CommonJS export path is simply skipped.
    'commonjs-variable-in-esm': 'silent',
  },
});

// Copy mecab-wasm files to dist/
copyFileSync('node_modules/@u1f992/mecab-wasm/lib/libmecab.wasm', 'dist/libmecab.wasm');
copyFileSync('node_modules/@u1f992/mecab-wasm/lib/libmecab.data', 'dist/libmecab.data');

console.log('Built dist/review.browser.js');
console.log('Copied mecab-wasm files to dist/');
