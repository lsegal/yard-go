include T('default/method_details/html')

def init
  super
  sections.last.push(:fields, [:enums], :inherited_fields)
end

def fields
  @fields = object.children.select {|t| t.type == :field }
  erb(:fields)
end

def enums
  if object.tag(:gotags).text =~ /enum:"(.+)"/
    name = $1
    @enums = object.parent.parent.children.select {|t|
      t.type == :constant && t.has_tag?(:enum) && t.tag(:enum).text == name }
    erb :enums
  end
end
