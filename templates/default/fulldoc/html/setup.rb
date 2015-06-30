def run_verifier(objs)
  super(objs.reject {|t| t.type == :bare_struct })
end
