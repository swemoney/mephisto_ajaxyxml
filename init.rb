require 'mephisto_ajaxyxml'

controller_path = File.join(directory, 'app', 'controllers')
$LOAD_PATH << controller_path
Dependencies.load_paths << controller_path
config.controller_paths << controller_path

Liquid::Template.register_tag('ajaxyxml', AjaxyXml::RequestTag)
