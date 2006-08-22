#!/usr/bin/perl


# Pick an example... any example:

#my $INPUT_FN = 'test-files/raw/august-mails.mbox'; my $UNMUNGE = 0;
my $INPUT_FN = 'test-files/raw/2001-2005.txt'; my $UNMUNGE = 1;
#my $INPUT_FN = 'test-files/raw/sample.txt'; my $UNMUNGE = 1;

use Mail::Box::Manager;
use Data::Dumper;
use underscore;
use indexer;

use strict;
use warnings;

my $indexer = new indexer(DB=>'underscore',
						  Host=>'localhost',
						  User=>'underscore',
						  Pass=>'und3rsc0r3');

# RUN THIS TO GET THE SCHEMA:
#print $indexer->database_setup_script; exit;


# Start a mailbox manager.  This is needed to allow threading.  It also
# adds a little bit of portability.
my $mgr = new Mail::Box::Manager;


# Load the input file
my $folder = $mgr->open(folder => $INPUT_FN);


# Un-spam-protect the email addresses.  Only necessary if using raw files
# from http://www.under-score.org.uk/
underscore_unmunge($folder) if($UNMUNGE);


$indexer->set_sql_indexes_onoff(0);

foreach my $msg (@$folder) {
	print $msg->messageId."\n";

	my @fromarr = $msg->from();
	my $from = shift @fromarr;
	my $author = 'mailto:'.$from->address;

	my $time = $msg->guessTimestamp();

	my $author_id = $indexer->author_id(lc($from->address), $from->name);

	my $body = $msg->decoded;

	my $content = $indexer->extract_content($body);

	my $doc_id = $indexer->index_content($msg->messageId(), $content, $author_id, $time);
}

$indexer->set_sql_indexes_onoff(1);
