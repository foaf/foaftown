#!/usr/bin/perl

use Mail::Box::Mbox;
use Data::Dumper;

#my $folder = Mail::Box::Mbox->new(folder => 'test-files/august-mails.mbox');
my $folder = Mail::Box::Mbox->new(folder => 'test-files/2006-August.txt');

my @messages   = $folder->messages;


foreach my $msg (@messages) {
	my $time = $msg->guessTimestamp();
	my @fromarr = $msg->from();
	my $from = $fromarr[0];
	my $subj = $msg->subject();
	print "$time\t$subj\t".$from->name."\t".$from->address."\n";
}
