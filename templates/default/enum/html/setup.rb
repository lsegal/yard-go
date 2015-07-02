include T('default/method_details/html')

def init
  super
  sections.last.push(:enums)
end

