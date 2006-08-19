#!perl

package foafize;

use strict;
use warnings;

# Since Redland's a bit wordy thanks to all the correctness and stuff, we
# use RDF::Helper instead to make lives easier.  This sits on top of
# Redland and does what we want it to.
use RDF::Helper;

# We're actually going to derive from RDF::Helper::RDFRedland. Usually
# we'd derive from RDF::Helper, but since a call to RDF::Helper DOESN'T
# return an RDF::Helper object (a RDF::Helper::<foo> object instead, where
# <foo> is the helper type), it makes inheritance hard: this class now
# would have to dynamically change its inheritance, to be able to act as
# the correct helper class.
#
# Instead, I'm going to hardcode it as RDFRedland instead.  If you know
# how to fix this, please do.  You'll need to attack new() to rebless the
# class correctly, I think.
use base qw|RDF::Helper::RDFRedland|;

# Used for mbox hashing
use Digest::SHA1 qw(sha1_hex);

# The actual tool for getting the data out of the passed message.
use Mail::Box;

our %default_namespaces = (
	'dc' => 'http://purl.org/dc/elements/1.1/',
	'foaf' => 'http://xmlns.com/foaf/0.1/',
	'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
	);

sub new ($;%) {
# A wrapper around RDF::Helper::new, setting some defaults, and some necessary parameters.
	my ($class, %args) = @_;

	# Set default namespaces if they're not already set.
	foreach my $ns (keys %default_namespaces) {
		$args{'Namespaces'}{$ns} = $default_namespaces{$ns}
			unless($args{'Namespaces'}{$ns});
	}

    # ExpandQNames is a very useful feature that expands things in the
    # above namespaces to their full URIs, rather than having to create
    # URI objects for every little thing.
	$args{'ExpandQNames'} = 1;

	# Call the superclass with the above parameters.
	my $self = $class->SUPER::new(%args);

	# Now, this is the bit that might need changing.  See comment at the
	# top of this file, w.r.t. 'use base'
	return bless $self, $class;
}

sub foaf_author($$) {
# This should take a Mail::Box::Message, assert the author's existence in RDF and
# then return the Person's id for use by the caller.
	my ($self, $msg) = @_;

	# I can't remember how to do this one in one line.  Oddly, the email
	# RFC allows more than one From: guy, although I've never seen it used
	# in real life.  Anyway, screw that, and just use the first one.
	my @fromarr = $msg->from();
	my $from = shift @fromarr;

	# This probably isn't the right thing to pick.  Ho hum.
	my $author_id = 'mailto:'.$from->address;

	# Hash the mailbox for spam protection
	my $sha1sum = Digest::SHA1::sha1_hex('mailto:'.$from->address);

	# Add the Person to the RDF model.
	$self->assert_resource($author_id, 'rdf:type', 'foaf:Person');
	$self->assert_literal($author_id, 'foaf:Name', $from->name);
	$self->assert_literal($author_id, 'foaf:mbox', $from->address);
	$self->assert_literal($author_id, 'foaf:mbox_sha1sum', $sha1sum);

	return $author_id;
}

sub foaf_message($$) {
# This should take a Mail::Box::Thread::Node OR a Mail::Box::Message,
# add it to the model, and return the id used.
	my ($self, $m) = @_;

	# TRUE if this is a threaded message: note, this does not mean it's
	# part of a real-life thread... just that we're instantiating it as
	# such.  It could still be an isolated email.
	my $thread = $m->isa('Mail::Box::Thread::Node');

	# If we're handling threading, then we still need to extract the
	# actual message, giving $m (the thread node), $msg (the node's
	# message).  Otherwise, they're both the message.
	my $msg = $thread ? $m->message : $m;

	# If the message is a dummy (eg. it's actually just a reference to a
	# node we don't know about), we can't really do much.
	return undef unless($msg and !$msg->isDummy);

	# This needs to be used somewhere, I guess.
	my $time = $msg->guessTimestamp();

	# This id is probably wrong.  Might be okay for a nodeID, but not a
	# resource URI.
	my $id = 'mid:'.$msg->messageId();

	# If this is a reply, we need to find out what the parent is.  $ref
	# will hold the parent's ID, if any.
	my $ref = undef;
	if($thread) {
		if(my $parent = $m->repliedTo) {
			if(my $pmsg = $parent->message) {
				$ref = 'mid:'.$pmsg->messageId();
			}
		}
	}

	# Remove any <> chars from the message id, just in case.
	$id =~ tr/[<>]/[\[\]]/;

	# FOAF this message into the model.
	$self->assert_resource($id, 'rdf:type', 'foaf:Document');
	$self->assert_literal($id, 'dc:title', $msg->subject);
	$self->assert_resource($id, 'foaf:maker', $self->foaf_author($msg));

	# If the message is a reply, then link it to the parent message.
	# Using dc:references here... probably very wrong.
	if($ref) {
		$self->assert_resource($id, 'dc:references', $ref);
	}

	# Return the message ID
	return $id;
}

1;
