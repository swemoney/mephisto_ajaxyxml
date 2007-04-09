require 'mephisto_ajaxyxml'

Liquid::Template.register_tag('ajaxyxml', AjaxyXml::RequestTag)
