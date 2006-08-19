#!perl

sub underscore_unmunge($) {
# The Underscore "raw" archive files at http://www.under-score.org.uk are
# spam-protected.  This function undoes the protection solely on the From:
# header, on all messages in the passed Mail::Box.  This should be run
# before anything else is done, otherwise all author names will be
# truncated, as Mail::Box::Message doesn't know how to unmunge.

	my ($mbm) = @_;

	my @messages = $mbm->messages;

	foreach my $msg (@messages) {
		$msg->{'MM_head'}{'MMH_fields'}{'from'}[1] =~ s/^(\s*.*?)\s+at\s+(.*?)/$1\@$2/;
	}
}

1;
