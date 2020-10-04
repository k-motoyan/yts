module YTS
  module Command
    class Serve
      def initialize(target_dir, info_path, port, ui_path)
        @port = port
        @info = JSON.parse(File.read(info_path))
        @ui = File.read(ui_path) unless ui_path.nil?

        require File.join(target_dir, "hashable.rb")
        Dir.glob(File.join(target_dir, "**/*.rb")).each do |f|
          next if File.basename(f) == "hashable.rb"
          require f
          YARD::parse(f)
        end
      end

      def exec
        require "hanami/router"
        r = Hanami::Router.new
        r.get "/", to: ->(env) { [200, {}, [@ui]] } unless @ui.nil?

        YARD::Registry.all(:class).each do |c|
          next unless c.namespace.to_s =~ /^Endpoint::(GET|POST|PUT|PATCH|DELETE)$/

          class_name = "#{c.namespace}::#{c.name}"
          method = $1.downcase
          path = File.basename(c.file, ".rb").gsub("_", "/")
          api_info = eval(c.tag(:api).text)
          status = api_info[:status]

          r.send(method, File.join(@info["basePath"], path), to: ->(env) {
            res = JSON.pretty_generate(eval(class_name).new.to_h)
            [status, {}, [res]]
          })
        end
  
        Rack::Server.start app: r, Port: @port
      end
    end
  end
end
