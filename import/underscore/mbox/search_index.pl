#!/usr/bin/perl

use indexer;
use strict;
use warnings;
use Data::Dumper;

my $indexer = new indexer(DB=>'underscore',
						  Host=>'localhost',
						  User=>'underscore',
						  Pass=>'und3rsc0r3');


my $q = $indexer->and_search("tom", "css");
my $resultref = $q->fetchall_hashref('message_id');
print Dumper($resultref);

exit;

# print $indexer->database_setup_script; exit;
