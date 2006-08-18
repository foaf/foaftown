#!/usr/bin/perl

use Mail::Box::Mbox;
use Data::Dumper;
use Digest::SHA1 qw(sha1_hex);

my $folder = Mail::Box::Mbox->new(folder => 'underscore.mbox');

my @messages   = $folder->messages;

my $rdf='<rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">';
 

foreach my $msg (@messages) {

	my $time = $msg->guessTimestamp();
	my @fromarr = $msg->from();
	my $from = $fromarr[0];
	my $subj = $msg->subject();
#	print "$time\t$subj\t".$from->name."\t".$from->address."\n";
       $rdf .= rdfize($time,$subj,$from->name, $from->address) ;
}

sub rdfize($,$,$,$) {
 my ($time, $subj, $who, $email) =@_;
	
my $sha1sum = sha1_hex("mailto:".$email);
 
my $post= "\n\n<foaf:Document><dc:title>$subj</dc:title>\n";
$post .= "   <foaf:maker><foaf:Person><foaf:name>$who</foaf:name>\n";
$post .= "   <foaf:mbox rdf:resource='mailto:$email'/>\n";
$post .= "   <foaf:mbox_sha1sum>$sha1sum</foaf:mbox_sha1sum>\n";
$post .= "  </foaf:Person>\n";
$post .= " </foaf:maker>\n";
$post .= "</foaf:Document>\n\n\n";

 return $post;
}

$rdf .= "</rdf:RDF>\n\n";

print $rdf;

