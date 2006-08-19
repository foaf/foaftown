#!/usr/bin/perl


# Pick an example... any example:

my $INPUT_FN = 'test-files/august-mails.mbox'; my $UNMUNGE = 0;
#my $INPUT_FN = 'test-files/2006-August.txt'; my $UNMUNGE = 1;
#my $INPUT_FN = 'test-files/sample.txt'); my $UNMUNGE = 1;

use Mail::Box::Manager;
use Data::Dumper;
use foafize;
use underscore;

use strict;
use warnings;

# 'foafize' is a temporary module for converting Mail::Box::Message
# objects into RDF.  It's a subclass of RDF::Helper.
#
# You can feed foafize::new() the normal RDF::Helper parameters:
#    our $rdfstorage = new RDF::Redland::Storage("hashes", "test",
#                                  "new='yes',hash-type='memory'");
#    our $rdfmodel = new RDF::Redland::Model($rdfstorage,'');
#    $foafize = new foafize(Model => $rdfmodel);
#
# Note, it's not *actually* a subclass of RDF::Helper at the moment: see
# the comments inside that module.
my $foafize = new foafize();


# Start a mailbox manager.  This is needed to allow threading.  It also
# adds a little bit of portability.
my $mgr = new Mail::Box::Manager;


# Load the input file
my $folder = $mgr->open(folder => $INPUT_FN);


# Un-spam-protect the email addresses.  Only necessary if using raw files
# from http://www.under-score.org.uk/
underscore_unmunge($folder) if($UNMUNGE);


# Get all threads from the archive
my $threads = $mgr->threads($folder);


# For each initial (non-reply) message (ie. each thread start)...
foreach my $m ($threads->all) {

	# Recursively FOAF the message.
	walk_thread($foafize, $m);
}


# Output the RDF as XML to STDOUT.
print $foafize->serialize()."\n";
exit;


sub walk_thread {
# This takes a foafize object and a Mail::Box::Thread::Node and FOAFs the
# node if possible.  It then recurses through all followups and FOAFs them
# too.

	my ($foafize, $m) = @_;

	my $msg = $m->message;

	# If this is a real message (as opposed to an unknown message that
	# exists only because it's the parent to a message that _is_ known),
	# then FOAF it.
	unless($msg->isDummy) {
		$foafize->foaf_message($m);
	}

	# FOAF the kids too.
	foreach my $f ($m->followUps) {
		walk_thread($foafize, $f);
	}
}
