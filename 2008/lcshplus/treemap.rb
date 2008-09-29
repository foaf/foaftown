#!/usr/bin/ruby

# Semantic Web Vapourware for the Masses 2008: SKOS Treemap
#
# Idea is to generate treemap HTML output from SKOS data
#
# eg. parse the LCSH Ntriples dump, or other big library datasets.
#
# current status: enough to show usage of the API
#
# Nearby: lcsh.info, rubytreemap.rubyforge.org
#   http://rubytreemap.rubyforge.org/docs/files/EXAMPLES.html
#   http://www.cs.umd.edu/hcil/treemap-history/
#
# dc:creator [ :openid <http://danbri.org/>; :mbox <mailto:danbri@danbri.org> ].

require 'rubygems'
require 'treemap'

root = Treemap::Node.new

root.new_child(:size => 6)
root.new_child(:size => 6)
root.new_child(:size => 4)
root.new_child(:size => 3)
root.new_child(:size => 2)
root.new_child(:size => 2)
root.new_child(:size => 1)

output = Treemap::HtmlOutput.new do |o|
  o.width = 800
  o.height = 600
  o.center_labels_at_depth = 1
end
puts output.to_html(root)
