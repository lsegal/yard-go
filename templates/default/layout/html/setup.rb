def stylesheets
  super + %w(css/highlight.github.css)
end

def menu_lists
[ { :type => 'package', :title => 'Packages', :search_title => 'Package List' },
  { :type => 'function', :title => 'Functions', :search_title => 'Function List' },
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
