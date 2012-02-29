require 'open3'

##############################################################################
#
# A wrapper around the clang
#
##############################################################################

module C
  class Preprocessor
    INCLUDE_REGEX = /(?:[^ ]|\\ )+\.h/i

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
    def preprocess(text)
      args = %w{clang -cc1 -ast-print}
      run args, text
    end
    def get_all_includes(text)
      args = %w{clang -E -M}
      split_includes run(args, text)
    end
    def get_system_includes(text)
      get_all_includes(text) - get_project_includes(text)
    end
    def get_project_includes(text)
      args = %w{clang -E -MM}
      split_includes run(args, text)
    end
    def preprocess_file(file_name)
      preprocess(File.read(file_name))
    end

    private  # -------------------------------------------------------

    def run(args, input)
      options = {:stdin_data => clang_macro_defines + input}
      options[:chdir] = pwd if pwd
      output, error, result = Open3.capture3(*args, *include_args, '-', options)
      raise Error, error unless result.success?
      output
    end
    def include_args
      include_path.map do |path|
        "-I#{path}"
      end
    end
    # must inject #define macros into the text instead of using the -D argument
    # since clang doesn't preprocess macros provided by -D in -ast-print
    def clang_macro_defines
      macros.map do |key, val|
        "#define #{key} #{val.nil? ? 1 : val}\n"
      end.join
    end
    def split_includes(text)
      text.scan(INCLUDE_REGEX)
    end
  end
end
