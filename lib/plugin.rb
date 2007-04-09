module Mephisto
  module Plugins
    class AjaxyXml < Mephisto::Plugin
      author  "Steve 'dnite' Ehrenberg"
      version "0.2"
      notes   "Create an AJAX request to update an element on your blog with dynamic content."
      
      public_controller 'ajaxyxml'
      add_route         '/ajaxyxml.html', :controller => 'ajaxyxml'
    
      class Schema < ActiveRecord::Migration
        def self.install
          puts "Nothing to install! See the README!"
        end
        
        def self.uninstall
        end
      end
    end
  end
end
