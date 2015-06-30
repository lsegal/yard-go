def stylesheets
  super + %w(css/highlight.github.css)
end

def index
  @objects_by_letter = {}
  objects = Registry.all(:struct).sort_by {|o| o.name.to_s }
  objects = run_verifier(objects)
  objects.each {|o| (@objects_by_letter[o.name.to_s[0,1].upcase] ||= []) << o }
  erb(:index)
end
