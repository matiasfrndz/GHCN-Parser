package GHCN::Data;

# Perl pragmas
use strict;
use warnings;

use DBIx::Class::Schema;
use Carp;

use GHCN::Data::Schema;

our $VERSION = '0.1';


my $schema;

sub get_schema {
	my $class = shift;
	my ($args) = @_;

	if (not defined $schema) {

		foreach (qw(driver db_name host user password)) {
		  die("'$_' not given") unless defined($args->{$_});
		}

		my $dsn = 'dbi:' . $args->{'driver'} . ':dbname=' . $args->{'db_name'} . ';host=' . $args->{'host'};
		my $user = $args->{'user'};
		my $password = $args->{'password'};

		my %attr              = ();
		my @connectStatements = ('set names utf8');

		$schema            = GHCN::Data::Schema->connect($dsn, $user, $password,
			\%attr, {on_connect_do => \@connectStatements});

		die("could not connect to database") unless defined $schema;

		# because we have reserved SQL keywords in our schema
		$schema->storage()->sql_maker()->quote_char('`');
		$schema->storage()->sql_maker()->name_sep('.');

		return $schema;
	}
	return $schema;
}

1;
