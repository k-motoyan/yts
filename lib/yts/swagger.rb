require "json"

module YTS
  class Swagger
    @@scalar_type_map = {
      "Boolean" => { type: :boolean },
      "String" => { type: :string },
      "Integer" => { type: :integer, format: :int64 },
      "Float" => { type: :number, format: :double },
      "Date" => { type: :string },
      "Time" => { type: :integet, format: :int32 },
    }

    def initialize(info)
      @schema = {
        swagger: info["swagger_version"] || "2.0",
        info: {
          version: info["version"] || "0.1.0",
          title: info["title"] || "WebAPI Document",
        },
        basePath: info["basePath"] || "/v1",
        schemes: info["schemes"] || %w(http https),
        paths: {},
        definitions: {},
      }

      @schema[:info][:description] = info[:desc] unless info[:desc].nil?
      @schema[:info][:host] = info[:host] unless info[:host].nil?
    end

    def set_path(path, method, api_info, definition)
      path = File.join "/", path
      @schema[:paths][path] ||= {}
      @schema[:paths][path][method] ||= {}
      @schema[:paths][path][method][:summary] = api_info[:summary]
      @schema[:paths][path][method][:description] = api_info[:description]
      @schema[:paths][path][method][:responses] ||= {}
      @schema[:paths][path][method][:responses]["#{api_info[:status]}"] = {
        description: status_to_desc(api_info[:status]),
        schema: { "$ref": "#/definitions/#{definition}" }
      }
    end

    def set_parameters(path, method, api_info, definition)
      path = File.join "/", path
      @schema[:paths][path] ||= {}
      @schema[:paths][path][method] ||= {}
      @schema[:paths][path][method][:parameters] ||= []
      @schema[:paths][path][method][:parameters] << {
        in: method == "get" ? "query" : "body",
        name: api_info[:name],
        description: api_info[:description],
        required: api_info[:required],
        schema: { "$ref": "#/definitions/#{definition}" }
      }
    end

    def set_definition(name, props)
      return unless @schema[:definitions][name].nil?

      @schema[:definitions][name] = {}
      @schema[:definitions][name][:properties] = {}

      props.each do |prop|
        @schema[:definitions][name][:properties][prop[:name]] = {}
        @schema[:definitions][name][:properties][prop[:name]][:description] = prop[:desc]

        type =
          case prop[:type]
          when "Boolean", "String", "Integer", "Float", "Date", "Time" then
            @@scalar_type_map[prop[:type]]
          when /Array<(.+)>/
            { type: :array, items: $1 }
          end

        if type.nil?
          # definition type
          @schema[:definitions][name][:properties][prop[:name]]["$ref"] = "#/definitions/#{prop[:type]}"
        elsif type[:type] == :array
          # array type
          @schema[:definitions][name][:properties][prop[:name]][:type] = :array
          @schema[:definitions][name][:properties][prop[:name]][:items] = {}

          if @@scalar_type_map[type[:items]].nil?
            @schema[:definitions][name][:properties][prop[:name]][:items]["$ref"] = "#/definitions/#{type[:items]}"
          else
            type_ = @@scalar_type_map[type[:items]]
            @schema[:definitions][name][:properties][prop[:name]][:items][:type] = type_[:type]
            @schema[:definitions][name][:properties][prop[:name]][:items][:format] = type_[:format] unless type_[:format].nil?
          end
        else
          # scalr type
          @schema[:definitions][name][:properties][prop[:name]][:type] = type[:type]
          @schema[:definitions][name][:properties][prop[:name]][:format] = type[:format] unless type[:format].nil?
        end
      end
    end

    def to_json
      @schema.to_json
    end

    private

    def status_to_desc(status)
      case "#{status}"
      when /2\d\d/ then "successful"
      when /4\d\d/ then "client error"
      when /5\d\d/ then "server error"
      end
    end
  end
end
