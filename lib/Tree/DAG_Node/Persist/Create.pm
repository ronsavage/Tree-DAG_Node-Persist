package Tree::DAG_Node::Persist::Create;

use strict;
use warnings;

use Hash::FieldHash ':all';

use DBI;

use DBIx::Admin::CreateTable;

fieldhash my %dbh           => 'dbh';
fieldhash my %dsn           => 'dsn';
fieldhash my %extra_columns => 'extra_columns';
fieldhash my %password      => 'password';
fieldhash my %table_name    => 'table_name';
fieldhash my %username      => 'username';

our $VERSION = '1.06';

# -----------------------------------------------

sub connect
{
	my($self) = @_;

	# Warning: Can't just return $self -> dbh(....) for some reason.
	# Tree::DAG_Node::Persist dies at line 137 ($self -> dbh -> prepare_cached).

	$self -> dbh
		(
		 DBI -> connect
		 (
		  $self -> dsn,
		  $self -> username,
		  $self -> password,
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
	my($self)          = @_;
	my($creator)       = DBIx::Admin::CreateTable -> new(dbh => $self -> dbh, verbose => 0);
	my($table_name)    = $self -> table_name;
	my(@extra_columns) = @{$self -> extra_columns};
	my($extra_sql)     = '';

	if ($#extra_columns >= 0)
	{
		my(@sql);

		for my $extra (@extra_columns)
		{
			$extra =~ tr/:/ /;

			push @sql, "$extra,"; 
		}

		$extra_sql = join("\n", @sql);
	}

	$creator -> drop_table($self -> table_name);

	my($primary_key) = $creator -> generate_primary_key_sql($table_name);
	my($result)      = $creator -> create_table(<<SQL);
create table $table_name
(
id $primary_key,
mother_id integer not null,
$extra_sql
unique_id integer not null,
context varchar(255) not null,
name varchar(255) not null
)
SQL
	# 0 is success.

	return 0;

} # End of drop_create.

# -----------------------------------------------

sub init
{
	my($self, $arg)      = @_;
	$$arg{dsn}           ||= $ENV{DBI_DSN};
	$$arg{password}      ||= $ENV{DBI_PASS};
	$$arg{extra_columns} = $$arg{extra_columns} ? [split(/\s*,\s*/, $$arg{extra_columns})] : [];
	$$arg{table_name}    ||= 'trees';
	$$arg{username}      ||= $ENV{DBI_USER};

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
