require 'plugin'
require 'rexml/document'
require 'rexml_extensions'

module AjaxyXml

  class AjaxyXmlError < StandardError; end

  # Liquid Tag for an Ajax Request. See README for syntax.
  class RequestTag < Liquid::Tag
    Syntax = /((#{Liquid::TagAttributes}\s?,?\s?)*)/

    def initialize(tag, parms, tokens)
      super
      if parms =~ Syntax
        @options = parse_options($1)
        raise AjaxyXmlError.new "Syntax Error. 'url' and 'element' are required." unless @options[:url] && @options[:element]
      else
        raise AjaxyXmlError.new "Syntax Error. Usage: {% ajaxyxml opt: 'value', opt: 'value' %}"
      end
    end

    # Render the Ajax.Request tag.
    def render(context)
      output = "<script type=\"text/javascript\">"
      unless @options[:framework] == 'mootools'
        output += "new Ajax.Request('/ajaxyxml.html"
      else
        output += "\nElement.update = function(element, html){\n"
        output += "   $(element).innerHTML = html.replace(new RegExp('(?:<script.*?>)((\\n|\\r|.)*?)(?:<\\/script>)', 'img'), '');\n"
        output += "   return element;\n"
        output += "}\n"
        output += "new XHR( {onSuccess: function(resp){eval(resp);} } ).send('/ajaxyxml.html"
      end
      output += "?e=#{@options[:element]}"
      output += "&u=#{CGI.escape @options[:url]}"
      output += "&q=#{@options[:quantity]}" unless @options[:quantity].blank?
      output += "')</script>"
    end

    private
    # Parse the option string into a hash.
    def parse_options(all_opts)
      options = {}
      pairs = all_opts.split(',')
      pairs.each do |pair|
        opt, value = pair.split(/:[^\/]/)
        options[opt.strip.to_sym] = value.strip.gsub(/\'/,'')
      end
      options
    end
  end

  # Dirty work for making HTTP connection and getting the XML file.
  class XmlRequest < Array
    def initialize(url)
      @url = URI.parse(url)
      get_xml
    end

    private
    def get_xml
      xml = REXML::Document.new Net::HTTP.get(@url)
      xml.root.elements.each do |element|
        push element.to_hash(HashWithIndifferentAccess.new)
      end
    end
  end

end
