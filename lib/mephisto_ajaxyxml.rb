require 'rexml/document'
require 'rexml_extensions'
require 'plugin'

module AjaxyXml

  class AjaxyXmlError < StandardError
  end

  # Route for ajax request. See README for instructions.
  class << self
    def connect_with(map)
      map.ajaxyxml '/ajaxyxml.html', :controller => 'ajaxyxml'
    end
  end

  # Liquid Block for an Ajax Request. See README for syntax.
  class RequestTag < Liquid::Tag
    Syntax = /((#{Liquid::TagAttributes}\s?,?\s?)*)/

    # Initialize class instance and parse passed options.
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
        output += "Element.update = function(element, html){$(element).innerHTML = html.replace(new RegExp('(?:<script.*?>)((\\n|\\r|.)*?)(?:<\\/script>)', 'img'), '');return element;}\n"
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
      @url = URI.parse url
      get_xml
    end

    private
    def get_xml
      resp = Net::HTTP.start(@url.host, @url.port) {|h| h.get @url.path}
      xml = REXML::Document.new resp.body
      xml.root.elements.each do |element|
        push element.to_hash(HashWithIndifferentAccess.new)
      end
    end
  end

end
