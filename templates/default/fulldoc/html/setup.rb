def run_verifier(objs)
  super(objs.reject {|t| t.type == :bare_struct })
end

def generate_method_list
  @items = prune_method_listing(Registry.all(:method).select {|m| m.scope == :instance }, false)
  @items = @items.sort_by {|m| m.name.to_s }
  @list_title = "Method List"
  @list_type = "method"
  generate_list_contents
end

def generate_function_list
  @items = prune_method_listing(Registry.all(:method).select {|m| m.scope == :class }, false)
  @items = @items.sort_by {|m| m.name.to_s }
  @list_title = "Function List"
  @list_type = "function"
  generate_list_contents
end

def generate_package_list
  @items = options.objects if options.objects
  @list_title = "Package List"
  @list_type = "package"
  generate_list_contents
end
