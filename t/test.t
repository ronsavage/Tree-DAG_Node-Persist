#!/usr/bin/perl

use common::sense;

use DBI;

use DBIx::Admin::CreateTable;

use File::Temp;

use Test::More tests => 22;

use Tree::DAG_Node;

# -----------------------------------------------

BEGIN
{
	use_ok('Tree::DAG_Node::Persist');
}

# -----------------------------------------------

sub build_tree
{
	my($table_name) = @_;
	my($data) = &read_data;

	my(@field);
	my($id);
	my($mother_id);
	my($name, $node);
	my(%tree);

	for (@$data)
	{
		@field     = split(/\s+/, $_);
		$mother_id = pop @field;
		$id        = pop @field;
		$name      = join(' ', @field);
		$node      = Tree::DAG_Node -> new;
		$tree{$id} = $node;

		$node -> name($name);

		if ($mother_id ne 'NULL')
		{
			$tree{$mother_id} -> add_daughter($node);
		}
	}

	return $tree{'001'};

}	# End of build_tree.

# --------------------------------------------------

sub count_nodes
{
	my($node, $opt) = @_;

	$$opt{count}++;

	return 1;

} # End of count_nodes.

# --------------------------------------------------

sub find_junk
{
	my($node, $opt) = @_;
	my($result) = 1;

	if ($node -> name eq $$opt{target})
	{
		$$opt{id} = ${$node -> attribute}{id} || 0;
		$result   = 0; # Short-circuit walking the tree.
	}

	return $result;

} # End of find_junk.

# --------------------------------------------------

sub find_node
{
	my($node, $opt) = @_;
	my($result)     = 1;

	if ($node -> name eq $$opt{target})
	{
		$$opt{node} = $node;
		$result     = 0; # Short-circuit walking the tree.
	}

	return $result;

} # End of find_node.

# --------------------------------------------------

sub pretty_print
{
	my($node, $opt) = @_;
	my($id) = ${$node -> attribute}{id} || '';

	diag ' ' x $$opt{_depth}, $node -> name, " ($id)\n";

	return 1;

} # End of pretty_print.

# -----------------------------------------------

sub read_data
{
	my(@line) = <DATA>;

	chomp @line;

	return [grep{! /^$/ && ! /^#/} map{s/^\s+//; s/\s+$//; $_} @line];

} # End of read_data.

# --------------------------------------------------

my($temp_file_handle, $temp_file_name) = File::Temp::tempfile('temp.XXXX', EXLOCK => 0, UNLINK => 1);
my(@dsn)                               =
(
$ENV{DBI_DSN}  || "dbi:SQLite:$temp_file_name",
$ENV{DBI_USER} || '',
$ENV{DBI_PASS} || '',
);
my($dbh) = DBI -> connect(@dsn, {PrintError => 0});

ok($dbh, 'Created $dbh');

my($creator) = DBIx::Admin::CreateTable -> new(dbh => $dbh, verbose => 0);

ok($creator, 'Created $creator');

my($table_name) = 'menus';

$creator -> drop_table($table_name);

ok(1, "Dropped table '$table_name' if it existed");

my($primary_key) = $creator -> generate_primary_key_sql($table_name);

ok($primary_key, "Generated primary key syntax for $ENV{DBI_DSN}");

my($result) = $creator -> create_table(<<SQL);
create table $table_name
(
id $primary_key,
mother_id integer not null,
unique_id integer not null,
context varchar(255) not null,
name varchar(255) not null
)
SQL

ok(1, "Created table '$table_name'");

my($context) = 'Master';
my($master)  = Tree::DAG_Node::Persist -> new
	(
	 context       => $context,
	 context_col   => 'context',
	 dbh           => $dbh,
	 id_col        => 'id',
	 mother_id_col => 'mother_id',
	 name_col      => 'name',
	 table_name    => $table_name,
	 unique_id_col => 'unique_id',
	);

ok($master, 'Created master persistence manager');

my($tree) = build_tree;

ok($tree, 'Populated master tree');

$tree -> walk_down({callback => \&pretty_print, _depth => 0});

ok(1, 'Printed master tree');

$master -> write($tree);

ok(1, 'Wrote master tree to the database');

my($shrub) = $master -> read;

ok(1, 'Read a copy of the master tree back in from the database');

$shrub -> walk_down({callback => \&pretty_print, _depth => 0});

ok(1, 'Printed the copy of the master tree');

my($opt) =
{
	callback => \&count_nodes,
	count    => 0,
	_depth   => 0,
};

$shrub -> walk_down($opt);

ok($$opt{count} == 20, 'Found 20 nodes in the copy of the master tree read in from the database');

my($target) = 'Beans and Nuts';
$opt        = 
{
	callback => \&find_node,
	_depth   => 0,
	node     => '',
	target   => $target,
};

$shrub -> walk_down($opt);

ok($$opt{node}, "Found the target '$target' within the copy of the master tree");

my(@kids)      = $$opt{node} -> daughters;
my($node)      = Tree::DAG_Node -> new;
my($junk_food) = 'Junk food';

$node -> name($junk_food);

splice(@kids, 1, 0, $node);

$$opt{node} -> set_daughters(@kids);

ok(1, "Inserted the new node '$junk_food' between the 2 children of '$target'");

$shrub -> walk_down({callback => \&pretty_print, _depth => 0});

ok(1, 'Printed the modified tree, with the new node inserted');

$context   = 'Slave';
my($slave) = Tree::DAG_Node::Persist -> new
	(
	 context       => $context,
	 context_col   => 'context',
	 dbh           => $dbh,
	 id_col        => 'id',
	 mother_id_col => 'mother_id',
	 name_col      => 'name',
	 table_name    => $table_name,
	 unique_id_col => 'unique_id',
	);

ok($slave, 'Created slave persistence manager');

$slave -> write($shrub);

ok(1, 'Wrote the modified tree to the database');

my($bush) = $slave -> read;

ok(1, 'Read a copy of the modified tree back in from the database');

$bush -> walk_down({callback => \&pretty_print, _depth => 0});

ok(1, 'Printed a copy of the modified tree, with the new node inserted');

$opt =
{
	callback => \&count_nodes,
	count    => 0,
	_depth   => 0,
};

$bush -> walk_down($opt);

ok($$opt{count} == 21, 'Found 21 nodes in the modified tree read in from the database');

$opt =
{
	callback => \&find_junk,
	id       => 0,
	_depth   => 0,
	target   => $junk_food,
};

$bush -> walk_down($opt);

ok($$opt{id} == 28, "Found node '$junk_food' at node 28 in the modified tree read in from the database");

__DATA__
Food                001       NULL
Beans and Nuts      002       001
Beans               003       002
Nuts                004       002
Black Beans         005       003
Pecans              006       004
Kidney Beans        007       003
Red Kidney Beans    008       007
Black Kidney Beans  009       007
Dairy               010       001
Beverages           011       010
Whole Milk          012       011
Skim Milk           013       011
Cheeses             014       010
Cheddar             015       014
Stilton             016       014
Swiss               017       014
Gouda               018       014
Muenster            019       014
Coffee Milk         020       011
