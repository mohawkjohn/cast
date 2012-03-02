require 'open3'
require 'rbconfig'

##############################################################################
#
# A wrapper around the C preprocessor: RbConfig::CONFIG["CPP"]
#
##############################################################################

module C
  class Preprocessor
    INCLUDE_REGEX = /(?:[^ ]|\\ )+\.h/i
    COMPILER = RbConfig::CONFIG["CC"]

    class Error < StandardError
    end

    class << self
      attr_accessor :command
    end

    attr_accessor :pwd, :include_path, :macros

    def initialize
      @include_path = []
      @macros = {}
    end
    def preprocess(text, line_markers = false)
      args = %w{-E}
      args << "-P" unless line_markers
      run args, text
=begin
      if clean_gnu_artifacts
        output.gsub!(/\b__asm\((?:"[^"]*"|[^)"]*)*\)/, '')
        output.gsub!(/\b__attribute__\(\((?:[^()]|\([^()]+\))+\)\)/, '')
        output.gsub!(/ __inline /, ' ')
      end
=end
    end
    def get_all_includes(text)
      args = %w{-E -M}
      split_includes run(args, text)
    end
    def get_system_includes(text)
      get_all_includes(text) - get_project_includes(text)
    end
    def get_project_includes(text)
      args = %w{-E -MM}
      split_includes run(args, text)
    end
    def preprocess_file(file_name)
      preprocess(File.read(file_name))
    end

    private  # -------------------------------------------------------

    def run(args, input)
      options = {:stdin_data => input}
      options[:chdir] = pwd if pwd
      output, error, result = Open3.capture3(COMPILER, *args, *include_args, *macro_args, '-', options)
      raise Error, error unless result.success?
      output
    end
    def include_args
      include_path.map do |path|
        "-I#{path}"
      end
    end
    def macro_args
      macros.map do |key, val|
        "-D#{key}#{val.nil? ? '' : "=#{val}"}"
      end
    end
    def split_includes(text)
      text.scan(INCLUDE_REGEX)
    end
  end
end
