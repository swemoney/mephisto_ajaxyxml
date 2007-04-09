class AjaxyxmlController < ApplicationController

  # Controller needs to know where to find it's views..
  self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
  layout nil
  session :off
  
  def index
    # Set some variables from the URL
    @output, @element, url = [], params[:e], CGI.unescape(params[:u])
    quantity = params[:q].to_i unless params[:q].blank?

    # Fetch and parse the partial file
    filesys  = Liquid::LocalFileSystem.new(site.theme.path)
    nodelist = Liquid::Template.parse(filesys.read_template_file("templates/ajaxy_#{@element}")).root.nodelist
    context  = Liquid::Context.new

    # Create a new XmlRequest for the URL specified
    xml = AjaxyXml::XmlRequest.new(url)
    xml = xml[0, quantity] unless quantity.blank?

    # Generate the HTML that will replace this element.
    xml.each_with_index do |item, index|
      context.stack do
        context['ajaxyxml'] = { 'index' => index + 1 }
        context['xml'] = item
        @output << render_all(nodelist, context)
      end
    end
    rescue
      @output = ""
  end

  # ganked right from the liquid/block.rb.
  protected
  def render_all(list, context)
    list.collect do |token|
      begin        
        if token.respond_to?(:render)
          token.render(context) 
        else
          token.to_s
        end
      rescue Exception => e          
        context.template.handle_error(e)
      end
    end      
  end

end
