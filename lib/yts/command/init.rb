module YTS
  module Command
    class Init
      def initialize(dir)
        @dir = File.expand_path dir
      end

      def exec
        raise "#{@dir} already exists." if Dir.exists? @dir
        [ @dir, "#{@dir}/entity", "#{@dir}/endpoint" ].each { |d| Dir.mkdir d, 0755 }

        swagger_info = {
          swagger_version: "2.0",
          desc: "",
          version: "0.1.0",
          title: "",
          host: "localhost:2300",
          basePath: "/v1",
          schemes: %w(http https),
        }
        File.write File.join(@dir, "info.json"), JSON.pretty_generate(swagger_info)

        code = <<~RUBY
        module Hashable
          def to_h
            hash = {}
            (self.methods - Object.new.methods).each do |m|
              next if m == :to_h

              key = m.to_s
              value = send(key)

              if value&.is_a?(Array)
                hash[key] = value.map { |v| v&.respond_to?(:to_h) ? v.to_h : v }
              elsif value&.respond_to?(:to_h)
                hash[key] = value.to_h
              else
                hash[key] = value
              end
            end
            hash
          end
        end
        RUBY
        File.write File.join(@dir, "hashable.rb"), code
      end
    end
  end
end
