use strict;
use warnings;

use Module::Build;

print "\n";
print "Testing uses the env vars \$DBI_DSN, \$DBI_USER and \$DBI_PASS. \n";
print "t/test.t uses a table called 'menus' (not the default 'trees'). \n";
print "\n";

my $class = Module::Build->subclass(code => <<'EOF');

sub ACTION_authortest
{
	my($self) = @_;

	$self->depends_on('build');
	$self->depends_on('manifest');
	$self->depends_on('distmeta');

	$self->test_files( qw< t xt/author > );
	$self->recursive_test_files(1);

	$self->depends_on('test');

	return;
}
EOF

$class -> new
(
	module_name    => 'Tree::DAG_Node::Persist',
	license        => 'artistic_2',
	dist_abstract  => 'Persist multiple trees in a single db table, preserving child order',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		'Test::More' => 1.001014,
#		'Test::Pod'  => 1.48, # Make it optional. See t/pod.t
	},
	configure_requires =>
	{
		'Module::Build' => 0.4211,
	},
	requires =>
	{
		'DBD::SQLite'              => 1.46,
		'DBI'                      => 1.633,
		'DBIx::Admin::CreateTable' => 2.10,
		'File::Temp'               => 0,
		'Getopt::Long'             => 2.42,
		'Hash::FieldHash'          => 0.14,
		'Pod::Usage'               => 1.65,
		'Scalar::Util'             => 1.41,
		'strict'                   => 0,
		'Tree::DAG_Node'           => 1.24,
		'warnings'                 => 0,
	},
	resources =>
	{
		bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Tree-DAG_Node-Persist',
		license    => 'http://opensource.org/licenses/Artistic-2.0',
		repository => 'https://github.com/ronsavage/Tree-DAG_Node-Persist',
	},
) -> create_build_script();

