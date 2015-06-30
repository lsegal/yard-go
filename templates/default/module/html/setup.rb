def init
  super
  sections.place(:packages).before(:constant_summary)
end

alias orig_constant_listing constant_listing

def constant_listing
  @go_constant_listing ||= orig_constant_listing.select {|o| o.tag(:constant_type).text == "const" }
end

def variable_listing
  @go_variable_listing ||= orig_constant_listing.select {|o| o.tag(:constant_type).text == "var" }
end

def scopes(list)
  [:class, :instance].each do |scope|
    items = list.select {|m| m.scope == scope }
    yield(items, items.first.scope_name) unless items.empty?
  end
end

def groups(list, type = "")
  super(list, "") do |items, scope|
    yield(items, scope.gsub(/\b[a-z]/) {|m| m.upcase })
  end
end

def packages
  @packages = object.children.select {|c| c.type == :package }.sort_by {|c| c.name.to_s }
  return if @packages.size == 0
  erb :packages
end
