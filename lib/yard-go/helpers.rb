module LinkHelpers
  include YARDGo::CodeObjects

  def link_object(obj, title = nil, anchor = nil, relative = true)
    case obj
    when BareStructObject
      origobj = object
      @object = object.namespace if BareStructObject === object
      link = super(obj.namespace, title || obj.name, anchor_for(obj), true)
      @object = origobj
      link
    else
      super(obj, title, anchor, relative)
    end
  end

  def anchor_for(obj)
    case obj
    when BareStructObject
      "type-#{obj.name}"
    else
      super(obj)
    end
  end

  def signature(obj, link = true, show_extras = true, full_attr_name = true)
    case obj
    when FieldObject
      ret = obj.has_tag?(:return) ? obj.tag(:return).types.join(", ") : ""
      if link
        return linkify obj, "<strong>#{obj.name}</strong> #{ret}"
      else
        return "<strong>#{obj.name}</strong> #{link_types(ret)}"
      end
    when BareStructObject, StructObject, InterfaceObject
      if link
        return linkify obj, "<strong>#{obj.name}</strong>"
      else
        return "<strong>#{obj.name}</strong> struct"
      end
    when FuncObject
      src = obj.source.split(/\n/).first.sub(/\{\s*$/, '').sub(/(<a\s[^>]+>|\b)#{obj.name.to_s}(<\/a>)?\(/, "<strong>#{obj.name}</strong>(")
      src = link_types(src) unless link
      src

      if link
        return linkify obj, src
      else
        return src
      end
    end

    super(obj, link, show_extras, full_attr_name)
  end

  def signature_types(meth, link = true)
    meth = convert_method_to_overload(meth)
    if meth.respond_to?(:object) && !meth.has_tag?(:return)
      meth = meth.object
    end

    val = ""
    if meth.tag(:return) && meth.tag(:return).types
      val = meth.tag(:return).types.join(", ")
    end

    link ? link_types(val) : val
  end

  def link_types(text)
    text.gsub(/\b(?:[a-z]\w*\.)?[A-Z]\w*:?/) do |m|
      if m[-1] == ":"
        m
      else
        link_object YARD::Registry.resolve(object, m), m
      end
    end
  end

  def html_syntax_highlight(source, type = nil)
    super(source, type || :go)
  end

  def format_object_title(obj)
    case obj
    when YARD::CodeObjects::RootObject
      "Package: #{obj.full_path.split('/').last}"
    else
      super(obj)
    end
  end
end

YARD::Templates::Helpers::HtmlHelper.send(:prepend, LinkHelpers)
