#!perl

package indexer;

use strict;
use warnings;

use Sys::Hostname;
use DBI;
use Mail::Box;

sub new($;%) {
	my ($class, %args) = @_;

	%args = () unless(%args);

	$args{word_table} = 'word'       unless($args{word_table});
	$args{word_table_text} = 'word'  unless($args{word_table_text});
	$args{word_table_id} = 'word_id' unless($args{word_table_id});

	$args{doc_table} = 'message'          unless($args{doc_table});
	$args{doc_table_text} = 'name'        unless($args{doc_table_text});
	$args{doc_table_id} = 'message_id'    unless($args{doc_table_id});
	$args{doc_table_author} = 'author_id' unless($args{doc_table_author});
	$args{doc_table_timestamp} = 'time'   unless($args{doc_table_timestamp});

	$args{author_table} = 'author'       unless($args{author_table});
	$args{author_table_text} = 'email'   unless($args{author_table_text});
	$args{author_table_name} = 'name'    unless($args{author_table_name});
	$args{author_table_id} = 'author_id' unless($args{author_table_id});

	$args{occur_table} = 'occurrence'                 unless($args{occur_table});
	$args{occur_table_doc_id} = $args{doc_table_id}   unless($args{occur_table_doc_id});
	$args{occur_table_word_id} = $args{word_table_id} unless($args{occur_table_word_id});
	$args{occur_table_pos} = 'position'               unless($args{occur_table_pos});

	$args{table_type} = 'MyISAM' unless($args{table_type});

	return bless \%args, $class;
}

sub connect($;$$$$) {
# Returns a DBI database handle, connecting to the database if necessary.
# The parameters are optional iff they have already been provided in the
# construction of this object.
	my ($self, $host, $db, $user, $pass) = @_;

	return $self->{dbh} if($self->{dbh});

	$host = $self->{Host} unless($host);
	$db   = $self->{DB}   unless($db);
	$user = $self->{User} unless($user);
	$pass = $self->{Pass} unless($pass);

	die "DB Parameters missing/incomplete"
		unless($host and $db and $user and $pass);

	$self->{dbh} = DBI->connect("DBI:mysql:database=$db;host=$host", $user, $pass)
		unless(defined($self->{dbh}));

	die "Can't Connect to MySQL: $!" unless($self->{dbh});
	$self->{dbh}->do('SET SESSION wait_timeout=3600');

	return $self->{dbh};
}

sub set_sql_indexes_onoff($$) {
	my ($self, $onoff) = @_;

	my $dbh = $self->connect();

	$onoff = $onoff ? 1 : 0;
	my $endisable = $onoff ? 'ENABLE' : 'DISABLE';

	$dbh->do("SET UNIQUE_CHECKS=$onoff") or die "Can't $endisable unique checks: $!";
	$dbh->do("ALTER TABLE $self->{author_table} $endisable KEYS") or die "Can't $endisable keys: $!";
	$dbh->do("ALTER TABLE $self->{word_table} $endisable KEYS") or die "Can't $endisable keys: $!";
	$dbh->do("ALTER TABLE $self->{occur_table} $endisable KEYS") or die "Can't $endisable keys: $!";
	$dbh->do("ALTER TABLE $self->{doc_table} $endisable KEYS") or die "Can't $endisable keys: $!";
}

sub database_setup_script($) {
# Returns the SQL to cut-and-paste into a root mysql client to setup the
# database correctly.
	my ($self) = @_;

	my @buf;

	my $myhost;
	if($self->{Host} eq 'localhost') {
		$myhost = 'localhost';
	} else {
		$myhost = hostname();
	}

	push @buf, "CREATE DATABASE $self->{DB}";

	push @buf, "GRANT ALL ON $self->{DB}.* ".
		"TO '$self->{User}'\@'$myhost' ".
		"IDENTIFIED BY '$self->{Pass}'";

	push @buf, "USE $self->{DB}";

	push @buf, "CREATE TABLE $self->{author_table} (".
		"$self->{author_table_id} INT NOT NULL AUTO_INCREMENT,".
		"$self->{author_table_text} VARCHAR(255) NOT NULL,".
		"$self->{author_table_name} VARCHAR(255) NOT NULL,".
		"PRIMARY KEY ($self->{author_table_id}),".
		"UNIQUE ($self->{author_table_text})".
		") ENGINE=$self->{table_type}";

	push @buf, "CREATE TABLE $self->{word_table} (".
		"$self->{word_table_id} INT NOT NULL AUTO_INCREMENT,".
		"$self->{word_table_text} VARCHAR(255) NOT NULL,".
		"PRIMARY KEY ($self->{word_table_id}),".
		"UNIQUE ($self->{word_table_text})".
		") ENGINE=$self->{table_type}";

	push @buf, "CREATE TABLE $self->{doc_table} (".
		"$self->{doc_table_id} INT NOT NULL AUTO_INCREMENT,".
		"$self->{doc_table_text} VARCHAR(255) NOT NULL,".
		"$self->{doc_table_author} INT NOT NULL,".
		"$self->{doc_table_timestamp} INT DEFAULT NULL,".
		"PRIMARY KEY ($self->{doc_table_id}),".
		"UNIQUE ($self->{doc_table_text}),".
		"INDEX ($self->{doc_table_timestamp}, $self->{doc_table_author}),".
		"INDEX ($self->{doc_table_author})".
		") ENGINE=$self->{table_type}";

	push @buf, "CREATE TABLE $self->{occur_table} (".
		"$self->{occur_table_doc_id} INT NOT NULL,".
		"$self->{occur_table_word_id} INT NOT NULL,".
		"$self->{occur_table_pos} INT NOT NULL,".
		"PRIMARY KEY ($self->{occur_table_doc_id}, $self->{occur_table_pos}),".
		"INDEX wordpos_to_doc ($self->{occur_table_word_id}, $self->{occur_table_pos})".
		") ENGINE=$self->{table_type}";

	push @buf, '';

	return join ";\n", @buf;
}

# Item ID cache.
our %id_cache;

sub selectinsert_to_get_id($$$;$) {
# Conversion of item to id within the domain $base.  Firstly, it looks for
# the id in the local hash cache.  If not found, it checks the database.
# If not found, it adds it to the database.
	my ($self, $base, $val, $extra) = @_;

	# First, check cache
	return $id_cache{$base}{$val} if($id_cache{$base}{$val});

	# Get database handle
	my $dbh = $self->connect();

	# Start with a transaction.
	$dbh->begin_work();

	# Prepare query if necessary
	my $sq;
	$sq = $self->{'q_select_'.$base} =
		$dbh->prepare('SELECT '.$self->{$base.'_table_id'}.' '.
					  'FROM '.$self->{$base.'_table'}.' '.
					  'WHERE '.$self->{$base.'_table_text'}.'=?')
		unless($sq = $self->{'q_select_'.$base});

	# Perform query
	my $id;
	die "Can't prepare $base SELECT query: $!" unless($sq);
	die "Cannot get $base: $!" unless($sq->execute($val));
	die "Can't bind column: $!" unless($sq->bind_columns(\$id));

	# Get result, if any
	if($sq->fetch and $id) {
		# Value has been found in database, so finish transaction
		$dbh->rollback;

		# and cache and return the id.
		return $id_cache{$base}{$val} = $id;
	}

	# Include extra columns
	my ($extracols, $extraplaces, $extraid) = ('','','');
	if($extra) {
		foreach my $key (keys %$extra) {
			$extracols .= $self->{$base.'_table_'.$key}.',';
			$extraplaces .= '?,';
			$extraid .= '_'.$key;
		}
	}

	# Word not found, so prepare the insert query if necessary
	my $iq;
	$iq = $self->{'q_insert_'.$base.$extracols} =
		$dbh->prepare('INSERT INTO '.$self->{$base.'_table'}.' '.
					  '('.$extracols.
					  $self->{$base.'_table_id'}.','.$self->{$base.'_table_text'}.') '.
					  'VALUES ('.$extraplaces.'NULL,?)')
		unless($iq = $self->{'q_insert_'.$base});

	# Construct values array
	my @vals = values %$extra;
	push @vals, $val;

	# Execute the query
	die "Can't prepare $base INSERT query: $!" unless($iq);
	die "Can't INSERT $val INTO $base: $!" unless($iq->execute(@vals));

	# Get the inserted id
	die "Can't get inserted id for $base: $!"
		unless($id = $dbh->{'mysql_insertid'});

	# Commit the data
	$dbh->commit;

	# and cache and return the id.
	return $id_cache{$base}{$val} = $id;
}

sub word_normalize($$) {
# Returns a cleaned-up version of $word, ready for indexing/searching
	my ($self, $word) = @_;

	# Normalize.  A bit simplistic, I suppose.  Stemming might be handy.
	$word =~ s/^\W*(.+?)\W*$/$1/;
	return lc($word);
}

sub word_id($$) {
# Returns the primary key for a word, either from cache or database, or by
# adding it if it's not already known.
	my ($self, $word) = @_;

	return $self->selectinsert_to_get_id('word', $word);
}

sub doc_id($$;$$) {
# Returns the primary key for a doc, either from cache or database, or by
# adding it if it's not already known.
	my ($self, $doc_id, $author_id, $time) = @_;

	return $self->selectinsert_to_get_id('doc', $doc_id,
										 {author=>$author_id,
										  timestamp=>$time});
}

sub author_id($$$) {
# Returns the primary key for an author, either from cache or database, or by
# adding it if it's not already known.
	my ($self, $email, $name) = @_;

	return $self->selectinsert_to_get_id('author', $email, {name=>$name});
}

sub index_content($$$$$) {
# Indexes a given document, and returns the numeric doc_id which was
# assigned to the document.
	my ($self, $doc_name, $content, $author_id, $time) = @_;

	my $count = 0;

	my $doc_id = $self->doc_id($doc_name, $author_id, $time);

	$self->delete_occurrences_for_doc($doc_id);

	foreach my $word ($self->extract_words($content)) {
		next unless($word =~ m/\w/);

		my $word_normal = $self->word_normalize($word);

		next unless($word =~ m/\S/);

		my $word_id = $self->word_id($word_normal);

		next unless($word_id);

		$self->add_word_occurrence($doc_id, $word_id, $count++);
	}

	return $doc_id;
}

sub delete_occurrences_for_doc($$) {
# Deletes all occurrences for a given doc_id, ready for reindexing.  This
# is a good thing.
	my ($self, $doc_id) = @_;

	# Get database handle
	my $dbh = $self->connect();

	# Start with a transaction.
	$dbh->begin_work();

	# Prepare the delete query, if necessary
	my $dq;
	$dq = $self->{'q_delete_occur'} =
		$dbh->prepare('DELETE FROM '.$self->{'occur_table'}.' '.
					  'WHERE '.$self->{'occur_table_doc_id'}.'=?')
		unless($dq = $self->{'q_delete_occur'});

	# Execute the query
	die "Can't prepare occurrence DELETE query: $!" unless($dq);
	die "Can't DELETE FROM occurrence: $!"
		unless($dq->execute($doc_id));

	# Commit the delete.
	$dbh->commit;
}

sub add_word_occurrence($$$$) {
# Adds a word-occurrence (inverted index) tuple into the occurrence table.
	my ($self, $doc_id, $word_id, $position) = @_;

	# Get database handle
	my $dbh = $self->connect();

	# Start with a transaction.
	$dbh->begin_work();

	# Prepare the insert query, if necessary
	my $iq;
	$iq = $self->{'q_insert_occur'} =
		$dbh->prepare('INSERT INTO '.$self->{'occur_table'}.' ('.
					  $self->{'occur_table_doc_id'}.','.
					  $self->{'occur_table_word_id'}.','.
					  $self->{'occur_table_pos'}.') '.
					  'VALUES (?,?,?)')
		unless($iq = $self->{'q_insert_occur'});

	# Execute the query
	die "Can't prepare occurrence INSERT query: $!" unless($iq);
	die "Can't INSERT INTO occurrence: $!"
		unless($iq->execute($doc_id, $word_id, $position));

	# Commit the data
	$dbh->commit;
}

sub and_search($$) {
	my ($self, @words) = @_;

	my $qid = "q_search_".('A'x$#words);

	my $dbh = $self->connect();

	my $rq;
	unless($rq = $self->{$qid}) {
		my @sql;

		push @sql, "SELECT d.$self->{doc_table_id},";
		push @sql, "d.$self->{doc_table_text},";
		push @sql, "COUNT(*) AS rows";
		push @sql, "FROM $self->{doc_table} d";

		my $c = 0;
		foreach my $word (@words) {
			push @sql, "INNER JOIN $self->{occur_table} o$c ".
				"ON d.$self->{doc_table_id} = ".
				"   o$c.$self->{occur_table_doc_id}";

			push @sql, "INNER JOIN $self->{word_table} w$c ".
				"ON o$c.$self->{occur_table_word_id} = ".
				"   w$c.$self->{word_table_id} ".
				"AND w$c.$self->{word_table_text} = ?";

			$c++;
		}

		push @sql, "GROUP BY d.$self->{doc_table_id}";
		push @sql, "ORDER BY rows";

		my $sql = join ' ', @sql;
		print $sql;

		die "Can't prepare search query: $!"
			unless($rq = $self->{$qid} = $dbh->prepare($sql));
	}

	my $c = 1;
	foreach my $word (@words) {
		$rq->bind_param($c++, $self->word_normalize($word));
	}

	die "Can't execute search query: $!" unless($rq->execute());

	return $rq;
}

sub extract_words($$) {
# Should return an array of words (in order) from a passed string.  This
# could be a lot smarter: deal with non-wordlike stuff, like "2.0",
# "175,000", URIs, "wouldn't", "ie.", etc.
	my ($self, $content) = @_;

	return split(/[\s\W]+/, $content);
}

sub extract_content($$) {
# This function takes a body text string (multiline) and attempts to
# remove sigs from it, including those that have been quoted.  It also
# removes the standard "On ... \d+ ... wrote:" bit.

	my ($self, $body) = @_;

	# Convert any carriage-returns
	$body =~ s#\r\n?#\n#s;

	# Try to convert non-standard delimiters (rows of dashes, underscores
	# or equals) to normal '-- '
	$body =~ s#\n+[\-=_]{30,}\s*\n(.*)$#\n-- \n$1#s;

	# Remove any trailing sig.
	$body =~ s#\n+--\s*\n(.+)$##s;

	# Try to remove any apparent indented sigs (in quoted sections)
	$body =~ s#\n+([A-Z]{0,3}[>:]\s*)+--\s*\n(\1([^\n]*)\n)*#\n#sg;

	# Try to remove any quoting prefaces
	$body =~ s#\n*([A-Z]{0,3}[>:]\s*)?On[^\n]+?(\d{4})?[^\n]+?wrote:\s*\n##sg;

	return $body;
}

1;
