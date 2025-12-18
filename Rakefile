# frozen_string_literal: true

require 'bundler/setup'
require 'opal'
require 'fileutils'

DIST_DIR = 'dist'
REVIEW_LIB_PATH = File.expand_path('review/lib', __dir__)
PATCHED_DIR = 'stubs/review'
PATCHES_DIR = 'patches'

# Files that need to be patched
PATCHED_FILES = %w[
  builder
  catalog
  compiler
  htmlbuilder
  i18n
  latexbuilder
  markdownbuilder
  plaintextbuilder
  yamlloader
].freeze

desc 'Apply patches to original Re:VIEW files'
task :patch do
  FileUtils.mkdir_p(PATCHED_DIR)

  PATCHED_FILES.each do |name|
    original = File.join(REVIEW_LIB_PATH, 'review', "#{name}.rb")
    patched = File.join(PATCHED_DIR, "#{name}.rb")
    patch_file = File.join(PATCHES_DIR, "#{name}.patch")

    unless File.exist?(original)
      warn "Original file not found: #{original}"
      next
    end

    unless File.exist?(patch_file)
      warn "Patch file not found: #{patch_file}"
      next
    end

    # Copy original
    FileUtils.cp(original, patched)

    # Apply patch (patch expects to be run from stubs/ directory)
    Dir.chdir('stubs') do
      result = system("patch -p0 < ../#{patch_file}")
      if result
        puts "Patched: #{name}.rb"
      else
        warn "Failed to patch: #{name}.rb"
      end
    end
  end
end

desc 'Clean patched files'
task :clean do
  PATCHED_FILES.each do |name|
    patched = File.join(PATCHED_DIR, "#{name}.rb")
    FileUtils.rm_f(patched)
  end
  FileUtils.rm_rf(DIST_DIR)
  puts 'Cleaned patched files and dist/'
end

desc 'Build the JavaScript bundle'
task build: :patch do
  FileUtils.mkdir_p(DIST_DIR)

  # Add paths: our patches first, then original Re:VIEW
  Opal.append_path('stubs')
  Opal.append_path(REVIEW_LIB_PATH)

  builder = Opal::Builder.new
  builder.build('review_opal')

  # Generate ESM wrapper with Opal runtime and memfs
  opal_runtime = Opal::Builder.new.build('opal').to_s
  js_content = builder.to_s

  # Load template and replace placeholders
  # Use block form to avoid backslash interpretation in replacement strings
  template = File.read('src/wrapper.js')
  esm_wrapper = template
    .sub('/* __OPAL_RUNTIME__ */') { opal_runtime }
    .sub('/* __REVIEW_CODE__ */') { js_content }

  File.write("#{DIST_DIR}/review.js", esm_wrapper)
  puts "Built #{DIST_DIR}/review.js"

  # Copy TypeScript definitions
  FileUtils.cp('src/review.d.ts', "#{DIST_DIR}/review.d.ts")
  puts "Built #{DIST_DIR}/review.d.ts"
end

desc 'Regenerate patches from current patched files (use after manual edits)'
task :genpatch do
  FileUtils.mkdir_p(PATCHES_DIR)

  PATCHED_FILES.each do |name|
    original = File.join(REVIEW_LIB_PATH, 'review', "#{name}.rb")
    patched = File.join(PATCHED_DIR, "#{name}.rb")
    patch_file = File.join(PATCHES_DIR, "#{name}.patch")

    unless File.exist?(original) && File.exist?(patched)
      warn "Skipping #{name}: files not found"
      next
    end

    # Generate unified diff with normalized paths
    diff = `diff -u #{original} #{patched}`
    # Normalize paths for patch -p0 from lib/ directory
    diff = diff.gsub(%r{^--- .*/review/#{name}\.rb}, "--- review/#{name}.rb")
    diff = diff.gsub(%r{^\+\+\+ .*/review/#{name}\.rb}, "+++ review/#{name}.rb")
    File.write(patch_file, diff)
    puts "Generated: #{patch_file}"
  end
end

task default: :build
