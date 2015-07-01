include T('default/class/html')

def init
  super
  sections.place(:implemented_interfaces).before(:constant_summary)
  sections.place(:fields_summary, [:item_summary], :inherited_fields).before(:method_summary)
  sections.place(:fields_details, [T('field')]).before(:method_details_list)
  @fields = object.children.select {|t| t.type == :field }.sort_by {|t| t.name.to_s }
end
