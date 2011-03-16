package Tree::DAG_Node::Persist::Test;

use strict;
use warnings;

use Hash::FieldHash ':all';

use DBI;

use DBIx::Admin::CreateTable;

fieldhash my %dbh        => 'dbh';
fieldhash my %table_name => 'table_name';

our $VERSION = '1.04';

# -----------------------------------------------

sub connect
{
	my($self) = @_;

	$self -> dbh
		(
		 DBI -> connect
		 (
		  $ENV{DBI_DSN},
		  $ENV{DBI_USER},
		  $ENV{DBI_PASS},
		  {
			  AutoCommit => 1,
			  PrintError => 0,
			  RaiseError => 1,
		  }
		 )
		);

	return $self -> dbh;

} # End of connect.

# -----------------------------------------------

sub drop_create
{
	my($self) = @_;
	my($creator)    = DBIx::Admin::CreateTable -> new(dbh => $self -> dbh, verbose => 0);
	my($table_name) = $self -> table_name;

	$creator -> drop_table($self -> table_name);

	my($primary_key) = $creator -> generate_primary_key_sql($table_name);
	my($result)      = $creator -> create_table(<<SQL);
create table $table_name
(
id $primary_key,
mother_id integer not null,
page_id integer default 0,
unique_id integer not null,
context varchar(255) not null,
name varchar(255) not null
)
SQL
	return 0; # Success.

} # End of drop_create.

# -----------------------------------------------

sub init
{
	my($self, $arg)   = @_;
	$$arg{table_name} ||= 'trees';

	return from_hash($self, $arg);

} # End of init.

# -----------------------------------------------

sub new
{
	my($class, %arg) = @_;
    my($self)        = bless {}, $class;

    return $self -> init(\%arg);

}	# End of new.

# -----------------------------------------------

sub run
{
	my($self) = @_;

	$self -> connect;

	# 0 is success.

	return $self -> drop_create;

} # End of run.

# -----------------------------------------------

1;
