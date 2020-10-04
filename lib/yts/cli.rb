require "thor"
require "yard"
require "mkmf"
require "colorize"

module YTS
  class Cli < Thor
    desc "init", "Initialize yts."
    def init
      cmd = Command::Init.new(File.expand_path "./yts-stub")
      cmd.exec
      puts "generated swagger stub directories!".green
    rescue
      puts "#{$!}".red
    end

    desc "gen", "generate stub file."
    option :type, aliases: "-t", desc: "generate file type. [endpoint|entity]"
    option :dir, aliases: "-d", desc: "output directory, default is ./yts-stub"
    option :name, aliases: "-n", desc: "generate file name."
    def gen
      cmd = Command::Gen.new(options[:type], options[:name], options[:dir] || "./yts-stub")
      cmd.exec
      puts "generated #{options[:type]} file!".green
    rescue
      puts "#{$!}".red
    end

    desc "convert", "Convert yard documentation to swagger schema."
    method_option :dir, aliases: "-d", desc: "convert target directory, default is ./yts-stub"
    method_option :info, aliases: "-i", desc: "swagger-info json file path, default is ./yts-stub/info.json"
    def convert
      swagger_info = JSON.parse(File.read(options[:info] || "./yts-stub/info.json"))
      swagger = Swagger.new(swagger_info)
      cmd = Command::Convert.new(swagger, (options[:dir] || "./yts-stub"))
      cmd.exec
    rescue
      puts "#{$!}".red
    end

    desc "serve", "Launch stub server."
    method_option :dir, aliases: "-d", desc: "stub target directory, default is ./yts-stub"
    method_option :info, aliases: "-i", desc: "swagger-info json file path, default is ./yts-stub/info.json"
    method_option :port, aliases: "-p", desc: "server port, default is 2300."
    method_option :swagger, aliases: "-s", desc: "swagger document path"
    def serve
      cmd = Command::Serve.new(
        options[:dir] || "./yts-stub",
        options[:info] || "./yts-stub/info.json",
        options[:port] || 2300,
        options[:swagger]
      )
      cmd.exec
    rescue
      puts "#{$!}".red, $@
    end

    desc "document", "Create swagger document."
    method_option :input, aliases: "-i", desc: "Input swagger schema path"
    method_option :output, aliases: "-o", desc: "Output path, default is ./doc/swagger.html"
    def document
      cmd = Command::Document.new(options[:input], options[:output] || "./doc/swagger.html")
      cmd.exec
    rescue
      puts "#{$!}".red
    end
  end
end
