include T('default/method_details/html')

def init
  super
  sections.last.push(:fields, [T('docstring')], :inherited_fields)
end

def fields
  @fields = object.children.select {|t| t.type == :field }
  erb(:fields)
end
