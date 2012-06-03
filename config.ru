require 'yaml'
require 'bundler/setup'
Bundler.require :default


class ExampleCodeGenerator

  def self.result(data)
    return data['result'] ||= URITemplate.new(data['template']).expand(data['variables'] || {})
  end

  class RubyURITemplate < ExampleCodeGenerator

    def self.name
      "Ruby - URITemplate"
    end

    def self.css_class
      "ruby-uritemplate"
    end

    def self.generate(data)
      code = []
      if data["variables"]
        code << 'variables = ' << data["variables"].inspect << "\n"
      end
      code << 'tpl = ' << data['template'].inspect << "\n"
      code << 'URITemplate.new(tpl).expand(variables)' << "\n"
      code << '# result: ' <<  result(data).inspect
      return code.join
    end

    def self.lang
      "ruby"
    end

  end

  class PythonURITemplate < ExampleCodeGenerator

    def self.name
      "python - uritemplate.py"
    end

    def self.css_class
      "python-uritemplate-py"
    end

    def self.generate(data)
      code = []
      if data["variables"]
        code << 'variables = ' << data["variables"].inspect << "\n"
      end
      code << 'uritemplate.expand(' << data['template'].inspect << ', variables)' << "\n"
      code << '# result: ' <<  result(data).inspect
      return code.join
    end

    def self.lang
      "python"
    end

  end

  class JavaHandyURITemplates < ExampleCodeGenerator

    def self.name
      "java - Handy-URI-Templates"
    end

    def self.lang
      "java"
    end

    def self.css_class
      "java-handy-uri-templates"
    end

    def self.generate(data)
      code = []
      if data['variables']
        data['variables'].each do |k,v|
          if v.kind_of? Hash
            code << 'Map<String,Object> ' << k << ' = new HashMap<String,Object>()' << ";\n";
            v.each do | kk,vv |
              code << '  ' << k << '.put( ' << kk.inspect << ' , ' << to_java(vv) << "); \n"
            end
          end
        end
      end
      code << 'UriTemplate.fromExpression(' << data['template'].inspect << ')'
      if data['variables']
         data['variables'].each do |k,v|
            if v.kind_of? Hash
              code << "\n  .set( " << k.inspect << " , " << k << ' )' 
            else
              code << "\n  .set( " << k.inspect << " , " << to_java(v) << ' )'
            end
         end
      end 
      code << '.expand()' << "\n";
      code << '// result: ' <<  result(data).inspect
      return code.join
    end

    def self.to_java(v)
      if v.kind_of? Hash
        
      elsif v.kind_of? Array
        return 'new Object[]{ ' + v.map{|x| to_java(x) }.join(', ') + '}'
      else
        return v.inspect
      end
    end

  end

  GENERATORS = [ RubyURITemplate, PythonURITemplate, JavaHandyURITemplates ]

end

class Kramdown::Parser::MyKramdown < Kramdown::Parser::Kramdown

  def handle_extension(name, opts, body, type)
    sup = super
    return sup if sup
    case name
    when 'example'
      @examples ||= 0
      @examples = @examples + 1
      puts body
      data = YAML.load(body)
      dl = Element.new(:dl)
      puts opts.inspect
      dl.children << Element.new(:dt).tap{|e| e.children << Element.new(:raw_text, [ 'Example #', @examples,  opts['name'] ? ': '+opts['name'] : '' ].join ) }
      ExampleCodeGenerator::GENERATORS.each do |gen|
        dl.children << Element.new(:dd,nil,'class'=> "code-example #{gen.css_class}").tap{|e| e.children << Element.new(:codeblock,gen.generate(data), 'lang' => gen.lang ) }
      end

      @tree.children << dl
      return true
    end
    return false
  end

end

def wrap_site(content)
  [
  '<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" /><link rel="stylesheet" href="css/foo.css" /><link rel="stylesheet" href="css/coderay.css" />',
  '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>',
  '<script src="js/foo.js"></script>',
  '</head><body>',
  '<div class="lang-selector"><select id="lang">',
  *ExampleCodeGenerator::GENERATORS.map{|gen|
    "<option value=\"#{gen.css_class}\">#{gen.name}</option>"
  },
  '</select></div>',
  '<div class="container">',
'<div class="back"></div>',
'<div class="content">',
  content,
 '<br style="clear:both" />', 
  '</div>',
 '</div>', 
  '</body></html>'
  ]
end

use Rack::Static, :urls => ['/css','/js']

run lambda{|env|

  html = Kramdown::Document.new(File.open('tutorial.kmd').read, :input=>'myKramdown', :coderay_css => :class, :coderay_line_numbers => nil).to_html()
  next [200, {'Content-Type' => 'text/html'}, wrap_site(html) ]
}
