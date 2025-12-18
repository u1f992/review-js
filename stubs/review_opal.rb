# frozen_string_literal: true

# backtick_javascript: true

# Re:VIEW Opal - Re:VIEW markup language parser compiled to JavaScript
# Based on Re:VIEW (https://github.com/kmuto/review)
# License: LGPL-2.1

# Set $PROGRAM_NAME for File.basename calls
$PROGRAM_NAME = 'review-js' unless defined?($PROGRAM_NAME) && $PROGRAM_NAME

# Standard library stubs (must be loaded before review)
require 'stringio'
require 'strscan'
require 'logger'
require 'date'

# Custom file/directory implementation using memfs
require 'memfs_file'
require 'memfs_dir'
require 'nodejs/yaml'

require 'nkf'
require 'digest'
require 'memfs_fileutils'
require 'tempfile'
require 'csv'
require 'open3'
require 'shellwords'
require 'securerandom'
require 'cgi/escape'

# Japanese morphological analyzer (for index generation)
require 'MeCab'

# ReVIEW module pre-definition with logger
module ReVIEW
  def self.logger
    @logger ||= ::Logger.new
  end

  def self.logger=(logger)
    @logger = logger
  end
end

# Load original Re:VIEW modules
# Path is configured in Rakefile to include ../review/lib
require 'review/extentions'
require 'review/exception'
require 'review/snapshot_location'
require 'review/location'
require 'review/lineinput'
require 'review/loggable'
require 'review/yamlloader'
require 'review/i18n'
require 'review/textutils'
require 'review/htmlutils'
require 'review/book'
require 'review/sec_counter'
require 'review/compiler'

# Patched builder files (class_eval replaced with static definitions)
require 'review/builder'
require 'review/htmlbuilder'
require 'review/markdownbuilder'
require 'review/latexbuilder'

# Opal-specific API wrapper
require 'review_opal/api'
