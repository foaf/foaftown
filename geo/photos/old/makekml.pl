#!/usr/bin/perl 

# Dan Brickley <danbri@danbri.org>


use RDF::Redland;

my $model=undef;
my $storage=undef;
my $db='temp';
my $store_type="hashes";
my $options=join(',' , "contexts='yes'", "hash-type='memory'");
my(@errors)=();
my(@warnings)=();


$storage=new RDF::Redland::Storage($store_type, $db, $options);
if($storage) {
  $model=new RDF::Redland::Model($storage, "");
}
if(!$storage && !$model) {
  log_action($host, $db, "Failed to open database");
  print "\n\n<p>Sorry - failed to open RDF Database.  This problem has been recorded.</p>\n";
  end_page($q);
  exit 0;
}


my $uri_string = shift || die "usage: $0 uri-of-locationdata eg: http://rdfweb.org/people/danbri/media/2005/08/2005-08-03-walk.rdf";

my $uri=new RDF::Redland::URI($uri_string);
$model->load($uri);

#`cat medialoc.rq`;

my $query_string = <<EOT;
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX locative: <http://locative.net/2004/packet#>
SELECT DISTINCT ?media, ?lat, ?long, ?who 
 WHERE {
  [ rdf:type locative:Packet ;
   geo:lat ?lat; geo:long ?long ;
   locative:media ?media
  ] . 
  ?media foaf:maker [ foaf:mbox ?who ] .

}
EOT

my $query=new RDF::Redland::Query($query_string);
#my $base_uri=new RDF::Redland::URI("http://example.org/is/this/needed#");

my $query=new RDF::Redland::Query($query_string, undef, undef, 'sparql');

print STDERR "Model has " .$model->size." statements. Sending it a query: $query\n";

my $results=$model->query_execute($query);


print '<?xml version="1.0" encoding="UTF-8"?>';
print "\n";
print '<kml xmlns="http://earth.google.com/kml/2.0">';
print "\n";
print "<Folder><name>SemLife Test</name>\n";
while (!$results->finished) { 
## print the triple values out. 
my $media= node_value($results->binding_value_by_name('media')), "\n";
my $lat = node_value($results->binding_value_by_name('lat')), "\n"; 
my $long = node_value($results->binding_value_by_name('long')), "\n"; 
my $who = node_value($results->binding_value_by_name('who')), "\n"; 
my $thumb = $media; 
print STDERR "image file is: $media \n";

#$thumb =~ s#/img_#/squares/sq-img_#g; # should get from metadata!

$thumb =~ s#/(\w+)\.jpg#/squares/sq-$1.jpg#g; # should get from metadata!

print "<Folder>
   <name>image placemark</name>
   <visibility>1</visibility>
   <Placemark>
     <description><![CDATA[ <img src='$thumb' /> $media placemark, by $who at lat:$lat long:$long ]]></description>
      <name> </name>
        <View>
          <longitude>$long</longitude>
          <latitude>$lat</latitude>
	  <range>0</range>
	  <tilt>30</tilt>
          <heading>0</heading>
        </View>
      <visibility>1</visibility>
      <styleUrl>root://styleMaps#default?iconId=0x307</styleUrl>
      <Style>
       <icon>$thumb</icon>
      </Style>
      <Point>
       <coordinates>$long,$lat,0</coordinates>
      </Point>
    </Placemark>
  </Folder>\n" unless ($thumb =~ m/-geotagged.jpg/); # for now...



## get the next set of results. 
#    <ScreenOverlay>
#      <name>Absolute Positioning: Top left</name>
#      <Icon>
#       <href>$thumb</href>
#      </Icon>
#      <overlayXY x='0' y='1' xunits='fraction' yunits='fraction'/>
#        <screenXY x='0' y='1' xunits='fraction' yunits='fraction'/>
#        <size x='0' y='0' xunits='fraction' yunits='fraction'/>
#    </ScreenOverlay>



$results->next_result; 
}

print "</Folder>\n";
print "</kml>\n\n";

sub node_value { 
  my $node = shift; 
  ## if the node is a resource, then return the URI's string value. 
  if ($node->is_resource()) { 
    return $node->uri->as_string; 
    ## if the node is a literal, return the string value. 
  } elsif ($node->is_literal()) { 
return $node->as_string; 
## else return an empty string 
} else { 
return ""; 
} 
} 
