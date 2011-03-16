#!/usr/bin/env perl
#
# Name:
#	create.table.pl.
#
# Purpose:
#	Create a db table called - by default - trees.

use lib 't';
use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Tree::DAG_Node::Persist::Test;

# --------------------

my($option_parser) = Getopt::Long::Parser -> new();

my(%option);

if ($option_parser -> getoptions
(
 \%option,
 'help',
 'tableName=s',
) )
{
	pod2usage(1) if ($option{'help'});

	exit Tree::DAG_Node::Persist::Test -> new(%option) -> run;
}
else
{
	pod2usage(2);
}

__END__

=pod

=head1 NAME

create.table.pl - Create a db table called - by default - trees

=head1 SYNOPSIS

create.table.pl [options]

The program uses $DBI_DSN, $DBI_USER and $DBI_PASS.

	Options:
	-help
	-tableName aTableName

All switches can be reduced to a single letter.

Exit value: 0.

=head1 OPTIONS

=over 4

=item -help

Print help and exit.

=item -tableName aTableName

Use this to override the default table name 'trees'.

=back

=cut
