include T('default/module/html')

def init
  super
  sections.place(:implemented_by).before(:constant_summary)
end
