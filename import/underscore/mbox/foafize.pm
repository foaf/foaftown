#!perl

package foafize;

use strict;
use warnings;

# Redland's the API of choice.  Previous use of RDF::Helper was stymied by
# certain (lack of) features, such as setting the xml:lang attribute.
# Redland's harder to work with, but more powerful.
use RDF::Redland;

# Used for mbox hashing
use Digest::SHA1 qw(sha1_hex);

# The actual tool for getting the data out of the passed message.
use Mail::Box;

our %namespaces = (
	'dc' => 'http://purl.org/dc/elements/1.1/',
	'foaf' => 'http://xmlns.com/foaf/0.1/',
	'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
	);

sub new ($;%) {
	my ($class, %args) = @_;

	%args = () unless(%args);

	# Create the new object
	my $self = bless \%args, $class;

	# Set up storage and model if not already set
	unless($self->{'Model'}) {
		unless($self->{'Storage'}) {
			$self->{'Storage'} = new RDF::Redland::Storage("hashes",
														   "test",
														   "new='yes',hash-type='memory'");
		}

		$self->{'Model'} = new RDF::Redland::Model($self->{'Storage'}, "");
	}

	# Set default namespaces if they're not already set.
	$self->{'Namespaces'} = \%namespaces
		unless($self->{'Namespaces'});

	return $self;
}

sub serialize($;%) {
# Returns the XML'ized version of the model, using a serializer supplied
# in the Serializer parameter, or a new one if not supplied.
	my ($self, %args) = @_;

	%args = () unless(%args);

	# Create a new serializer if not supplied.
	my $sz = $args{'Serializer'};
	$sz = new RDF::Redland::Serializer('rdfxml-abbrev') unless($args{'Serializer'});

	# Add each namespace to the serializer
	if($self->{'Namespaces'}) {
		foreach my $key (keys %{$self->{'Namespaces'}}) {
			$sz->set_namespace($key, new RDF::Redland::URI($self->{'Namespaces'}{$key}));
		}
	}

	# Serialise the content
	my $str = $sz->serialize_model_to_string($self->{'BaseURI'}, $self->{'Model'});

    # Is there a better way of doing this with RDF::Redland?
	$str =~ s/<rdf:RDF /<rdf:RDF xml:lang="en" /;


	return $str;
}


# Okay, this lot is fairly random.

sub assert_resource($$$$) {
	my ($self, $s, $p, $o) = @_;

	$self->{'Model'}->add(my $subj = $self->nodify($s),
						  $self->nodify($p),
						  $self->nodify($o));
	return $subj;
}

sub assert_literal($$$$) {
	my ($self, $s, $p, $o) = @_;

	$self->{'Model'}->add(my $subj = $self->nodify($s),
						  $self->nodify($p),
						  $self->nodify($o));
	return $subj;
}

sub nodify($$) {
	my ($self, $inp) = @_;

	return $inp if(ref($inp) and (
					   $inp->isa('RDF::Redland::Node') or
					   $inp->isa('RDF::Redland::URI') or
					   $inp->isa('URI')));

	return $self->uriify($inp) if($inp =~ m/^(\w+):/);

	return new RDF::Redland::LiteralNode($inp); # undef,'en');
}

sub uriify($$) {
	my ($self, $inp) = @_;

	if($inp =~ m/^(\w+):(.+)$/) {
		if(my $uri = $self->{'Namespaces'}{$1}) {
			return new RDF::Redland::URI($uri.$2);
		}
	}
	return new RDF::Redland::URI($inp);
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
	$self->assert_literal($author_id, 'foaf:name', $from->name);
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
