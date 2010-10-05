use Module::Build;

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
	requires =>
	{
		common::sense            => 3.0,
		DBD::SQLite              => 1.29,
		DBI                      => 1.611,
		DBIx::Admin::CreateTable => 2.04,
		File::Temp               => 0.22,
		Hash::FieldHash          => 0.1,
		Scalar::Util             => 1.23,
		Tree::DAG_Node           => 1.06,
	},
) -> create_build_script();

