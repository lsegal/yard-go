require 'strscan'

class YARD::CodeObjects::RootObject
  def full_path
    File.relative_path(ENV["GOPATH"] + "/src", Dir.pwd)
  end
end

class YARD::CLI::Yardoc
  def all_objects
    YARD::Registry.all(:root, :package, :struct, :interface)
  end
end

class YARD::CLI::Stats
  undef stats_for_modules
  undef stats_for_classes

  def stats_for_packages
    output "Packages", *type_statistics(:package)
  end

  def stats_for_structs
    struct_stats = type_statistics(:struct)
    bstruct_stats = type_statistics(:bare_struct)
    stats = struct_stats.zip(bstruct_stats).map {|o| o.reduce(:+) }
    output "Structs", *stats
  end

  def stats_for_interfaces
    output "Interfaces", *type_statistics(:interface)
  end

  def stats_for_members
    output "Members", *type_statistics(:member)
  end
end

module YARD::Templates::Helpers::HtmlSyntaxHighlightHelper
  MATCHES = {
    "hljs-keyword" => %r{\b(?:break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var)\b},
    "hljs-constant" => %r{\b(nil|false|true|error|string|int64|int|int32|float|float32|float64|bool)\b},
    "hljs-string" => %r{"(?:[^\\"]|\\.)*"|`.+?`},
    "hljs-comment" => %r{\/\/.+},
  }

  def html_syntax_highlight_go(source)
    s = StringScanner.new(source, true)

    highlighted = ""
    until s.eos?
      found = false
      MATCHES.each do |klass, re|
        if s.scan(re)
          found = true
          highlighted << "<span class=\"#{klass}\">#{s[0]}</span>"
        end
      end
      highlighted << s.getch unless found
    end

    '<div class="hljs">' + highlighted + '</div>'
  end
end
