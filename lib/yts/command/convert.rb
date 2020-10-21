module YTS
  module Command
    class Convert
      def initialize(swagger, target_dir)
        @swagger = swagger

        Dir.glob(File.join(Dir.pwd, target_dir, "**/*.rb")).each do |f|
          next if File.basename(f) == "hashable.rb"
          YARD::parse(f)
        end
      end

      def exec
        YARD::Registry.all(:class).each do |c|
          next if c.meths.empty?

          namespace = c.namespace.to_s
          case namespace
          when  /^Endpoint::(GET|POST|PUT|PATCH|DELETE)$/
            method = $1.downcase
            path = File.basename(c.file, ".rb").split("_").map(&:downcase).join("/")
            definition = "#{c.name.to_s}-#{$1}"
            api_info = eval(c.tag(:api).text)
            api_info[:description] = c.docstring.to_s
            @swagger.set_path(path, method, api_info, definition)

            props = props_from_methods c.meths
            @swagger.set_definition(definition, props) unless props.empty?
          when  /^Endpoint::Parameters::(GET|POST|PUT|PATCH|DELETE)$/
            method = $1.downcase
            path = File.basename(c.file, ".rb").split("_").map(&:downcase).join("/")
            definition = "#{c.name.to_s}-#{$1}"
            api_info = eval(c.tag(:api).text)
            api_info[:description] = c.docstring.to_s
            @swagger.set_parameters(path, method, api_info, definition)

            props = props_from_methods c.meths
            @swagger.set_definition(definition, props) unless props.empty?
          when "Entity"
            definition = c.name.to_s
            props = props_from_methods c.meths
            @swagger.set_definition(definition, props) unless props.empty?
          end
        end

        puts @swagger.to_json
      end

      private

      def props_from_methods(methods)
        methods.select{ |m| !m.tag(:return).nil? }.map do |m|
          tag = m.tag(:return)
          {
            name: m.name,
            type: tag.types[0],
            desc: tag.text
          }
        end
      end
    end
  end
end
