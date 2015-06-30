include T('default/class/html')

def init
  super
  sections.place(:implemented_interfaces).before(:constant_summary)
  sections.place(:members_summary, [:item_summary], :inherited_members).before(:method_summary)
  sections.place(:members_details, [T('member')]).before(:method_details_list)
  @members = object.children.select {|t| t.type == :member }.sort_by {|t| t.name.to_s }
end
