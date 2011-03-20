use Module::Build;

print "\n";
print "Testing uses the env vars \$DBI_DSN, \$DBI_USER and \$DBI_PASS. \n";
print "t/test.t uses a table called 'menus' (not the default 'trees'). \n";
print "\n";

Module::Build -> new
(
	module_name    => 'Tree::DAG_Node::Persist',
	license        => 'artistic',
	dist_abstract  => 'Persist multiple trees in a single db table, preserving child order',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		Test::Simple => 0.94, # For Test::More.
		Test::Pod    => 1.41,
	},
	configure_requires =>
	{
		Module::Build => 0.3800,
	},
	requires =>
	{
		DBD::SQLite              => 1.29,
		DBI                      => 1.611,
		DBIx::Admin::CreateTable => 2.04,
		File::Temp               => 0.22,
		Hash::FieldHash          => 0.1,
		Scalar::Util             => 1.23,
		Tree::DAG_Node           => 1.06,
	},
) -> create_build_script();

