require 'yard'

require_relative './yard-go/code_objects'
require_relative './yard-go/extensions'
require_relative './yard-go/handlers'
require_relative './yard-go/helpers'
require_relative './yard-go/parser'
require_relative './yard-go/version'

YARD::Templates::Engine.register_template_path(File.dirname(__FILE__) + '/../templates')
YARD::Parser::SourceParser.register_parser_type(:go, YARDGo::Parser::Go, 'go')
YARD::Handlers::Processor.register_handler_namespace(:go, YARDGo::Handlers)
YARD::Tags::Library.visible_tags -= [:return]
YARD::Tags::Library.define_tag "Read-only", :readonly