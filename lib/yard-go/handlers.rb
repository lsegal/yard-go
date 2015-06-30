module YARDGo
  module Handlers
    class Base < YARD::Handlers::Base
      include YARDGo::CodeObjects

      def self.handles?(node)
        handlers.any? do |h|
          (node.name.nil? || node.name[0] == node.name[0].upcase) &&
          node.type == h
        end
      end

      def parse_block(inner_node, opts = {})
        push_state(opts) { parser.process([inner_node].flatten) }
      end

      def call_params; [] end
      def caller_method; nil end

      def pkg
        return @pkg if @pkg
        pkg = :root
        path = File.dirname(File.relative_path(Dir.pwd, parser.file))
        parts = path.split('/')
        while parts.size > 0
          pkg = PackageObject.new(pkg, parts.shift)
          pkg.add_file(path) unless pkg.file
        end

        @pkg = pkg
      end

      def test_file?
        parser.file =~ /_test\.go$/
      end
    end

    class StructHandler < Base
      handles :struct

      process do
        return if test_file?

        ns = if statement.meths.size > 0 # it's a "class"
          register StructObject.new(pkg, statement.name)
        else # bare struct
          register BareStructObject.new(pkg, statement.name)
        end

        parse_block(statement.meths, namespace: ns)
        parse_block(statement.members, namespace: ns)
      end
    end

    class InterfaceHandler < Base
      handles :interface

      process do
        return if test_file?

        obj = register InterfaceObject.new(pkg, statement.name)
        parse_block(statement.members, namespace: obj)
      end
    end

    class FunctionHandler < Base
      handles :function
      handles :method

      process do
        return parse_example if test_file?

        scope = statement.type == :function ? :class : :instance
        ns = statement.type == :function ? pkg : namespace
        ctor_fn = false

        if scope == :class && statement.ret =~ /^\s*\*([A-Z]\w*)\s*$/
          ctor_fn = true
          ns = StructObject.new(pkg, $1)
        end

        obj = register FuncObject.new(ns, statement.name, scope)
        obj.signature = "func #{statement.name}#{statement.args}"
        obj.parameters = statement.args.split(/,/).map{|a| [a, nil] }

        if statement.ret && statement.ret.strip != ""
          obj.add_tag YARD::Tags::Tag.new(:return, '', [statement.ret])
        end

        if ctor_fn
          obj.group = "Constructor Functions"
        end
      end

      private

      def parse_example
        return unless statement.name =~ /^Example(.+)/
        parts = $1.split("_")

        ns = pkg
        if parts.size > 1
          ns = P(pkg, parts.first)
          ensure_loaded! ns
        end

        meth = P(ns, "." + parts.last)
        ensure_loaded! meth

        src = statement.source.split("\n")[1...-1].map {|l| l.sub(/^\t/, "") }.join("\n").sub(/\n^\/\/ Output:.+\Z/m, "")
        meth.add_tag YARD::Tags::Tag.new(:example, src, nil, "")
      end
    end

    class MemberFnHandler < Base
      handles :memberfn

      process do
        return if test_file?

        obj = register FuncObject.new(namespace, statement.name, :instance)
        obj.signature = "func #{statement.name}(#{statement.args})"
        obj.parameters = statement.args.split(/,/).map{|a| [a, nil] }
        if statement.ret && statement.ret.strip != ""
          obj.add_tag YARD::Tags::Tag.new(:return, '', [statement.ret])
        end
        obj.add_tag YARD::Tags::Tag.new(:abstract, '')
      end

    end

    class MemberHandler < Base
      handles :member

      process do
        return if test_file?

        obj = register MemberObject.new(namespace, statement.name, :instance)
        obj.add_tag YARD::Tags::Tag.new(:return, '', [statement.member_type])
        obj.add_tag YARD::Tags::Tag.new(:gotags, statement.tags)
      end
    end

    class PackageHandler < Base
      handles :package

      process do
        return if test_file?
        register_docstring pkg if statement.comments.size > 0
      end
    end

    class ConstantHandler < Base
      handles :const
      handles :var

      process do
        return if test_file?

        obj = register ConstantObject.new(pkg, statement.name)

        lhs = statement.name
        lhs += " " + statement.vartype if statement.vartype
        obj.source = "#{statement.type} #{lhs} = #{statement.value}"
        obj.value = statement.value
        obj.add_tag YARD::Tags::Tag.new(:constant_type, statement.type.to_s)
        obj.add_tag YARD::Tags::Tag.new(:return, '', [statement.vartype])
        obj.add_tag YARD::Tags::Tag.new(:readonly, '') if statement.type == :const
      end
    end

    class CompositionHandler < Base
      handles :composition

      process do
        return if test_file?

        namespace.mixins(:instance) << P(namespace, statement.path)
      end
    end
  end
end
