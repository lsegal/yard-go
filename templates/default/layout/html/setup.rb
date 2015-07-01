def stylesheets
  super + %w(css/highlight.github.css)
end

def menu_lists
[ { :type => 'package', :title => 'Packages', :search_title => 'Package List' },
  { :type => 'method', :title => 'Methods', :search_title => 'Method List' },
  { :type => 'file', :title => 'Files', :search_title => 'File List' } ]
end

def index
  @objects_by_letter = {}
  objects = Registry.all(:struct).sort_by {|o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each {|o| (@objects_by_letter[o.name.to_s[0,1].upcase] ||= []) << o }
  erb(:index)
end

def layout
  @nav_url = url_for_list(!@file || options.index ? 'package' : 'file')

  if !object || object.is_a?(String)
    @path = nil
  elsif @file
    @path = @file.path
  elsif !object.is_a?(YARD::CodeObjects::NamespaceObject)
    @path = object.parent.path
  else
    @path = object.path
  end

  erb(:layout)
end
