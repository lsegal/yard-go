include T('default/module/html')
include YARDGo::CodeObjects

def init
  super
  sections.place(:type_summary, [:item_summary], :interface_summary, [:item_summary]).before(:method_summary)
  sections.place(:type_details, [:yield_type]).before(:method_details_list)

  @types = object.children.select {|c| c.type == :bare_struct || c.type == :enum }.sort_by {|c| c.name.to_s }
end

def type_summary
  @items = object.children.select {|c| c.type == :bare_struct || c.type == :struct || c.type == :enum }.sort_by {|c| c.name.to_s }
  @name = "Type"
  erb :list_summary
end

def interface_summary
  @items = object.children.select {|c| c.type == :interface }.sort_by {|c| c.name.to_s }
  @name = "Interface"
  erb :list_summary
end

def yield_type
  T(object.type.to_s).run(options)
end