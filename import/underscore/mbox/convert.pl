#!/usr/bin/perl

use strict;

use Mail::Box::Mbox;
use Data::Dumper;
use rdfize;
use underscore;

#my $folder = Mail::Box::Mbox->new(folder => 'test-files/august-mails.mbox');
#my $folder = Mail::Box::Mbox->new(folder => 'test-files/sample.txt');
my $folder = Mail::Box::Mbox->new(folder => 'test-files/2006-August.txt');


# Un-spam-protect the email addresses.  Only necessary if using raw files
# from http://www.under-score.org.uk/
underscore_unmunge($folder);

# Get all messages from the archive
my @messages = $folder->messages;

# Buffering in an array followed by a single array join is faster than
# bigass string concatenation when dealing with loads of data.
my @rdfbuf;

# Add in a generic RDF header
push @rdfbuf, rdfheader();

# For each message...
foreach my $msg (@messages) {
	# RDF it.
	push @rdfbuf, rdfize($msg);
}

# Add the closing gubbins for RDF
push @rdfbuf, rdffooter();

# Output it.
print join "\n", @rdfbuf;
print "\n";



