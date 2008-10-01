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
#   http://inkdroid.org/lcco/
# dc:creator [ :openid <http://danbri.org/>; :mbox <mailto:danbri@danbri.org> ].

require 'treemap'

root = Treemap::Node.new

root.new_child(:size => 6, :label => "SKOS Test" )
root.new_child(:size => 6, :label => "LCSH data" )
root.new_child(:size => 4, :color => "red")
root.new_child(:size => 3)

output = Treemap::HtmlOutput.new do |o|
  o.width = 850
  o.height = 700
  o.center_labels_at_depth = 1
end
puts output.to_html(root)
