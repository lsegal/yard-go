require 'json'

module YARDGo
  module Parser
    class Statement < OpenStruct
      def to_s; source end
    end

    class Go < YARD::Parser::Base
      include YARD
      include YARD::CodeObjects

      @@matches = {
        comment: %r{^\s*//(.*)},
        package: /^package (\w+)/,
        function: /^func (\w+)\((.*?)\)(.*?)\{/,
        struct: /^type (\w+) struct\s+\{/,
        interface: /^type (\w+) interface\s+\{/,
        method: /^func \(\w+\s+\*?(.+?)\) (\w+)\((.*?)\)(.*)\{/,
        close_brace: /^\}/,
        close_paren: /^\)/,
        single_var: /^(var|const)\s+(.+?)\s*=\s*(.+)/,
        multi_var: /^(var|const)\s*\(/
      }

      def tokenize; [] end
      def enumerator; @ast end

      attr_reader :file

      def initialize(source, file)
        YARD::CodeObjects.send(:remove_const, :NSEP)
        YARD::CodeObjects.const_set(:NSEP, '/')
        YARD::CodeObjects.send(:remove_const, :NSEPQ)
        YARD::CodeObjects.const_set(:NSEPQ, '/')
        YARD::CodeObjects.send(:remove_const, :ISEP)
        YARD::CodeObjects.const_set(:ISEP, '.')
        YARD::CodeObjects.send(:remove_const, :ISEPQ)
        YARD::CodeObjects.const_set(:ISEPQ, '.')
        @lines = source.split(/\r?\n/)
        @file = file
        @svc_docs = {}
        @ast = []
        @structs = {}
        @lineno = 0
      end

      def parse
        clear_comments
        consume_until do
          case line
          when @@matches[:comment]
            add_comment($1)

          when @@matches[:package]
            @ast << s(:package, package_name: $1)

          when @@matches[:function]
            t = s(:function, name: $1, args: $2, ret: $3)
            attach_source(t)
            @ast << t

          when @@matches[:struct]
            t = init_struct($1)
            consume_members(t)

          when @@matches[:interface]
            t = s(:interface, name: $1, members: [])
            consume_members(t)
            @ast << t

          when @@matches[:method]
            t = init_struct($1)
            m = s(:method, type: $1, name: $2, args: $3, ret: $4)
            attach_source(m)
            t.meths.push(m)

          when @@matches[:single_var]
            type, lhs, src = $1.to_sym, $2, [$3]
            name, vartype = *lhs.split(/\s+/)
            
            @lineno += 1
            consume_until %r{^(\w|\/\/)} do
              src << line
            end
            @lineno -= 1

            @ast << s(type, name: name, vartype: vartype, value: src.join("\n"))

          when @@matches[:multi_var]
            type = $1.to_sym
            clear_comments

            @lineno += 1
            consume_until @@matches[:close_paren] do
              case line
              when @@matches[:comment]
                add_comment($1)
              when /^(\s*)(.+?)\s*=\s*(.+)/m
                mindent, lhs, src = $1.length, $2, [$3]
                name, vartype = *lhs.split(/\s+/)
                
                @lineno += 1
                consume_until @@matches[:close_paren] do
                  indent = (line[/^(\s+)/, 1] || "").length
                  break if indent < mindent
                  break if indent == mindent && line =~ /^\s+(\w|\/\/)/
                  src << line
                end
                @lineno -= 1

                @ast << s(type, name: name, vartype: vartype, value: src.join("\n"))
              end
            end

          else
            if @comments.size > 0
              @ast << s(:comment)
            else
              clear_comments
            end
          end
        end

        @ast += @structs.values

        self
      end

      private

      def init_struct(name)
        @structs[name] ||= s(:struct, name: name, members: [], meths: [])
      end

      def consume_members(t)
        @lineno += 1
        consume_until @@matches[:close_brace] do
          case line
          when @@matches[:comment]
            add_comment($1)
          when /^\s*\*?([\w\.]+)\s*(?:`(.+?)`)?\s*$/
            path, tags = $1, $2
            name = path.split('.').last
            t.members.push(s(:composition, name: name, path: path, tags: tags))
          when /^\s*(\w+)(\(.*?\))\s*(.*)?\s*(?:`(.+?)`)?\s*$/
            t.members.push(s(:memberfn, name: $1, args: $3, ret: $4, tags: $5))
          when /^\s*(\w+)\s*(\S+)\s*(?:`(.+?)`)?\s*$/
            t.members.push(s(:member, name: $1, member_type: $2, tags: $3))
          else
            clear_comments
          end
        end
      end

      def s(type, opts = {})
        options = {source: line}.merge(opts)
        c = @comments.join("\n")
        c = c.gsub(/(\n[ \t]*\n[ \t]*\n)(.+\n\n)/, '\1## \2')
        clear_comments
        Statement.new(options.merge(type: type.to_sym, comments: c, line: @lineno))
      end

      def line
        @lines[@lineno]
      end

      def clear_comments
        @comments = []
      end

      def add_comment(match)
        @comments.push(match.sub(/^ /, ''))
      end

      def consume_until(re = nil, &block)
        while @lineno < @lines.size
          break if re && line =~ re
          yield
          @lineno += 1
        end
      end

      def attach_source(t)
        src = []
        consume_until @@matches[:close_brace] do
          src << line
        end
        src << line
        t.source = src.join("\n")
      end
    end
  end
end
