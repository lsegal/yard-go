module YARDGo
  module CodeObjects
    class PackageObject < YARD::CodeObjects::NamespaceObject
      def sep; '/' end
      def type; :package end
      def source_type; :go end
      def title; name.to_s end

      def full_path
        File.join(parent.full_path, name.to_s)
      end

      def inheritance_tree(*args) [self] end
    end

    class StructObject < YARD::CodeObjects::NamespaceObject
      def sep; '.' end
      def type; :struct end
      def scope; :instance end
      def title; namespace.title + "." + name.to_s end
      def source_type; :go end

      def inheritance_tree(include_mods = false)
        list = (include_mods ? mixins(:instance) : [])
        [self] + list.map do |m|
          next m if m == self
          next m unless m.respond_to?(:inheritance_tree)
          m.inheritance_tree(include_mods)
        end.flatten.uniq
      end

      def implemented_interfaces
        YARD::Registry.all(:interface).select {|i| implements?(i) }
      end

      def implements?(interface)
        interface.implemented_by?(self)
      end
    end

    class BareStructObject < StructObject
      def sep; '.' end
      def type; :bare_struct end
      def source_type; :go end
    end

    class FuncObject < YARD::CodeObjects::MethodObject
      def sep; '.' end
      def type; :method end
      def title; parent.title + "." + name.to_s + "()" end
      def scope_name; has_tag?(:abstract) ? "Interface Method" : (scope == :class ? "Function" : "Method") end
      def source_type; :go end
    end

    class FieldObject < YARD::CodeObjects::Base
      def sep; '::' end
      def type; :field end
      def title; namespace.title + "." + name.to_s end
      def source_type; :go end

      attr_accessor :field_type, :go_tags
    end

    class InterfaceObject < StructObject
      def sep; '.' end
      def type; :interface end
      def source_type; :go end

      def implemented_by?(struct)
        m = struct.children.select {|t| t.type == :method && t.scope == :instance }.map(&:name)
        children.select {|t| t.type == :method && t.scope == :instance }.all? {|t| m.include?(t.name) }
      end

      def implementing_structs
        YARD::Registry.all(:struct).select {|s| implemented_by?(s) }
      end
    end

    class ConstantObject < YARD::CodeObjects::ConstantObject
      def sep; '.' end
      def type; :constant end
      def source_type; :go end
    end
  end
end