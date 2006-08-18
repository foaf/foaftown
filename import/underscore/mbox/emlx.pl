#!/usr/bin/perl -w
# Copyright © 2005 Jamie Zawinski <jwz@jwz.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# This code parses the .emlx files used by Mail.app in MacOS 10.4.x.
# Mail.app stores folders as directories with one file per message.
# Each file contains three sections:
#
#   - the first line is the length in bytes of the message itself
#   - the raw message follows
#   - then comes an XML "plist" which contains various parsed attributes
#     of the message, and any flags that were subsequently set.
#
# The most interesting parameter in the plist is "flags", which is a 32 bit
# quantity indicating read/unread, replied, and other message status.
# Those bits are not officially documented, but we do what we can.
#
# Usage:
#
#  - print a one line summary of all messages in a folder:
#
#      emlx.pl *
#
#  - print a one line summary of unread messages in a folder:
#
#      emlx.pl --unread *
#
#  - print the full text of the unread messages, with most uninteresting
#    header fields stripped:
#
#      emlx.pl --unread --all *
#
#  - print a summary of unread messages in your default Inboxes:
#
#      emlx.pl --unread $HOME/Library/Mail/*/INBOX.mbox/Messages/*.emlx
#
#  - convert a folder to a standard BSD "mbox" file:
#
#      emlx.pl --mbox *.emlx > folder.mbox
#
# Created:  4-Jul-2005.
# Discussion: http://jwz.livejournal.com/505711.html

require 5;
use diagnostics;
use strict;
use POSIX;

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 1.2 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;


# returns a hash reference with various symbolic keys set
#
sub parse_flags($) {
  my ($bits) = @_;

  my %result = ();
  $result{'read'}          = ($bits & (1    << 0))  >> 0;
  $result{'deleted'}       = ($bits & (1    << 1))  >> 1;
  $result{'answered'}      = ($bits & (1    << 2))  >> 2;
  $result{'encrypted'}     = ($bits & (1    << 3))  >> 3;
  $result{'flagged'}       = ($bits & (1    << 4))  >> 4;
  $result{'recent'}        = ($bits & (1    << 5))  >> 5;
  $result{'draft'}         = ($bits & (1    << 6))  >> 6;
# $result{'initial'}       = ($bits & (1    << 7))  >> 7;
  $result{'forwarded'}     = ($bits & (1    << 8))  >> 8;
  $result{'redirected'}    = ($bits & (1    << 9))  >> 9;
  $result{'attach_count'}  = ($bits & (0x3F << 10)) >> 10; # 6 bits
  $result{'priority'}      = ($bits & (0x7F << 16)) >> 16; # 5 bits
  $result{'signed'}        = ($bits & (1    << 23)) >> 23;
  $result{'is_junk'}       = ($bits & (1    << 24)) >> 24;
  $result{'is_not_junk'}   = ($bits & (1    << 25)) >> 25;
  $result{'font_size'}     = ($bits & (0x07 << 26)) >> 26; # 3 bits
  $result{'junk_recorded'} = ($bits & (1    << 29)) >> 29;
  $result{'highlight'}     = ($bits & (1    << 30)) >> 30;

  # wtf?
  $result{'attach_count'} = 0 if $result{'attach_count'} == 63;

  # delete null values
  foreach my $key (keys %result) {
    delete $result{$key} if (! $result{$key});
  }

  # print sprintf("## %b: ", $bits) . join(' | ', keys(%result)) . "\n";

  return \%result;
}


sub showfile($$$$) {
  my ($file, $unread_p, $list_p, $mbox_p) = @_;
  local *IN;
  open (IN, "<$file") || error ("$file: $!");
  my $body = '';
  while (<IN>) { $body .= $_; }
  close IN;

  my ($length, $xml);

  $body =~ m/^(\d+)\n(.*)$/s || error ("$file: unparsable length");
  ($length, $body) = ($1, $2);

  $xml = substr ($body, $length) || error ("$file: unparsable body");
  $body = substr ($body, 0, $length);

  $xml =~ m/^<\?xml version/ || error ("$file: misparsed body");

  my %props;
  my @chunks = split (/<key>/i, $xml);
  shift @chunks;
  foreach (@chunks) {
    my ($key, $val) = m@^(.*?)</key>\s*(.*)$@s;
    $val =~ s@\</dict>.*$@@s;
    $val =~ s@^\s*<([^<>]+)>\s*(.*)\s*</\1>\s*$@$2@s;
    $props{$key} = $val;
  }

  my $flags = parse_flags($props{'flags'});

  return if ($flags->{'deleted'});            # skip deleted messages
  return if ($unread_p && $flags->{'read'});  # skip read messages

  my $attach = $flags->{'attach_count'};

  # don't care about these
  delete $flags->{'priority'};
  delete $flags->{'is_not_junk'};
  delete $flags->{'junk_recorded'};
  delete $flags->{'attach_count'};

  if ($list_p) {
    $file =~ s@^.*/@@;

    my $date = $props{'date-sent'};
    $date = strftime ("%a %b %d %l:%M %p", localtime ($date));

    my $from = $props{'sender'};
    my $subj = $props{'subject'};

    $from =~ s@&lt;@<@g;
    $from =~ s@&gt;@>@g;
    $from =~ s@&amp;@&@g;

    $subj =~ s@&lt;@<@g;
    $subj =~ s@&gt;@>@g;
    $subj =~ s@&amp;@&@g;

    my $flags_str = join (', ', keys (%$flags));
    $flags_str .= " [$attach]" if ($attach);

    $from = substr ($from, 0, 20);
    $subj = substr ($subj, 0, 30);

    my $line = sprintf ("%-20s %-20s  %-30s  %s",
                        $date, $from, $subj, $flags_str);
    $line =~ s/\s+$//s;
    print "$line\n";

  } else {

    my $headers;
    $body =~ m/^(.*?\n)\n(.*)$/s || error ("$file: unparsable headers");
    ($headers, $body) = ($1, $2);

    $body =~ s/\s+$//s;

    if ($mbox_p) {

      if ($headers !~ m/^From /s) {
        my $date = $props{'date-sent'};
        $date = strftime ("%a %b %d %T %Y %z", localtime ($date));
        $headers = "From - $date\n$headers";
      }

      $body =~ s/^(From )/>$1/gm;   # mangle
      print "$headers\n$body\n\n";

    } else {

      $headers =~ s/\n\s+/ /gs;
      my $headers2 = '';
      foreach (split (/\n/, $headers)) {
        $headers2 .= "$_\n" if (m/^(From|To|CC|Subject|Date):/si);
      }

      my $hr = '-' x 72;
      print "$headers2\n$body\n\n$hr\n";
    }
  }
}


sub error($) {
  my ($err) = @_;
  print STDERR "$progname: $err\n";
  exit 1;
}

sub usage() {
  print STDERR "usage: $progname [--verbose] " .
    "[--unread|--all] [--list|--show] file.emlx ...\n";
  exit 1;
}

sub main() {
  my @files = ();
  my $unread_p = 0;
  my $list_p = 1;
  my $mbox_p = 0;

  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }

    elsif (m/^--?unread$/) { $unread_p = 1; }
    elsif (m/^--?all$/)    { $unread_p = 0; }

    elsif (m/^--?list$/)   { $list_p = 1; }
    elsif (m/^--?show$/)   { $list_p = 0; }

    elsif (m/^--?mbox$/)   { $mbox_p = 1;
                             $list_p = 0;
                             $unread_p = 0; }

    elsif (m/^-./) { usage; }
    else { push @files, $_; }
  }

  usage unless ($#files >= 0);
  foreach (@files) {
    showfile ($_, $unread_p, $list_p, $mbox_p);
  }
}

main();
exit 0;
