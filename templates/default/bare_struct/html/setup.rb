include T('default/method_details/html')

def init
  super
  sections.last.push(:members, [T('docstring')], :inherited_members)
end

def members
  @members = object.children.select {|t| t.type == :member }
  erb(:members)
end
