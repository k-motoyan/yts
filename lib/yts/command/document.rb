module YTS
  module Command
    class Document
      def initialize(input, output)
        raise "require command `redoc-cli`, please install following command: `npm i -g redoc-cli`" unless find_executable "redoc-cli"

        @input = input
        @output = output

        output_dir = File.dirname(@output)
        Dir.mkdir(output_dir, 0755) unless Dir.exists? output_dir
      end

      def exec
        system "redoc-cli bundle #{@input} -o #{@output}"
      end
    end
  end
end
