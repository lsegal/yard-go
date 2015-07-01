def run_verifier(objs)
  super(objs.reject {|t| t.type == :bare_struct })
end

def generate_package_list
  @items = options.objects if options.objects
  @list_title = "Package List"
  @list_type = "package"
  generate_list_contents
end
