#!perl

use strict;

use Mail::Box;
use Digest::SHA1 qw(sha1_hex);

sub rdfheader() {
	return '<rdf:RDF '.
	'xmlns:dc="http://purl.org/dc/elements/1.1/" '.
	'xmlns:foaf="http://xmlns.com/foaf/0.1/" '.
	'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'.
	'>';
}

sub rdffooter() {
	return '</rdf:RDF>';
}

sub rdfize($) {
	my ($msg) = @_; # Should be a Mail::Box::Message object

	my $time = $msg->guessTimestamp();
	my @fromarr = $msg->from();
	my $from = $fromarr[0];
	my $who = $from->name;
	my $email = $from->address;
	my $subj = $msg->subject();

	my $sha1sum = sha1_hex("mailto:".$email);

    # Pushing to an array buffer and then joining is faster and more
    # efficient than string concatenation.  Not that it really matters
    # that much at this point, but if the nugget outputted by this
    # function gets bigger, it's probably worth it.
 	my @post;

	push @post, '<foaf:Document><dc:title>'.$subj.'</dc:title>';
	push @post, '   <foaf:maker><foaf:Person><foaf:name>'.$who.'</foaf:name>';
	push @post, '   <foaf:mbox rdf:resource="mailto:'.$email.'"/>';
	push @post, '   <foaf:mbox_sha1sum>'.$sha1sum.'</foaf:mbox_sha1sum>';
	push @post, '  </foaf:Person>';
	push @post, ' </foaf:maker>';
	push @post, '</foaf:Document>';

	return join "\n", @post;
}

1;
