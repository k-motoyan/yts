module YTS
  module Command
    class Gen
      def initialize(type, name, dir)
        @type = type
        @name = name
        @class_name = name.split("_").map(&:capitalize).join("")
        @dir = dir
      end

      def exec
        case @type
        when "endpoint"
          code = <<~RUBY
          module Endpoint
            module GET
              # @api { status: 200, summary: "#{@class_name} sample api" }
              class #{@class_name}
                include Hashable
              end
            end

            module POST
              # @api { status: 201, summary: "#{@class_name} sample api" }
              class #{@class_name}
                include Hashable
              end
            end

            module PATCH
              # @api { status: 200, summary: "#{@class_name} sample api" }
              class #{@class_name}
                include Hashable
              end
            end

            module DELETE
              # @api { status: 200, summary: "#{@class_name} sample api" }
              class #{@class_name}
                include Hashable
              end
            end

            module Headers
              module #{@class_name}HeaderBase
              end

              module GET
                class #{@class_name}Header
                  include ::Endpoint::Headers::#{@class_name}HeaderBase
                end
              end

              module POST
                class #{@class_name}Header
                  include ::Endpoint::Headers::#{@class_name}HeaderBase
                end
              end

              module PATCH
                class #{@class_name}Header
                  include ::Endpoint::Headers::#{@class_name}HeaderBase
                end
              end

              module DELETE
                class #{@class_name}Header
                  include ::Endpoint::Headers::#{@class_name}HeaderBase
                end
              end
            end

            module Parameters
              # #{@class_name} get request parameter
              # @api { required: true, name: "get" }
              module GET
                class #{@class_name}Parameter
                end
              end

              # #{@class_name} post request parameter
              # @api { required: true, name: "post" }
              module POST
                class #{@class_name}Parameter
                end
              end

              # #{@class_name} patch request parameter
              # @api { required: true, name: "patch" }
              module PATCH
                class #{@class_name}Parameter
                end
              end

              # #{@class_name} delete request parameter
              # @api { required: true, name: "delete" }
              module DELETE
                class #{@class_name}Parameter
                end
              end
            end
          end
          RUBY
          output_path = File.join(@dir, "endpoint", "#{@name.downcase}.rb")
          raise "#{output_path} already exists." if File.exists? output_path
          File.write(output_path, code)
        when "entity"
          code = <<~RUBY
          module Entity
            class #{@class_name}
              include Hashable
            end
          end
          RUBY
          output_path = File.join(@dir, "entity", "#{@name.downcase}.rb")
          raise "#{output_path} already exists." if File.exists? output_path
          File.write(output_path, code)
        end
      end
    end
  end
end
