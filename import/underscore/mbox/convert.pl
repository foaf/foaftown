#!/usr/bin/perl

use Mail::Box::Mbox;
use Data::Dumper;
use rdfize;

my $folder = Mail::Box::Mbox->new(folder => 'test-files/august-mails.mbox');
#my $folder = Mail::Box::Mbox->new(folder => 'test-files/2006-August.txt');

my @messages = $folder->messages;

my @rdfbuf;

push @rdfbuf, rdfheader();

foreach my $msg (@messages) {
	push @rdfbuf, rdfize($msg);
}

push @rdfbuf, rdffooter();

print join "\n", @rdfbuf;
print "\n";



