use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		AUTHOR   => 'Ron Savage (ron@savage.net.au)',
		ABSTRACT => 'Persist multiple trees in a single db table, preserving child order',
	) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Tree-DAG_Node-Persist-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Tree-DAG_Node-Persist',
	NAME      => 'Tree::DAG_Node::Persist',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		common::sense            => 3.0,
		DBD::SQLite              => 1.29,
		DBI                      => 1.611,
		DBIx::Admin::CreateTable => 2.04,
		File::Temp               => 0.22,
		Hash::FieldHash          => 0.1,
		Scalar::Util             => 1.23,
		Test::Simple             => 0.94, # For Test::More.
		Test::Pod                => 1.41,
		Tree::DAG_Node           => 1.06,
	},
	VERSION_FROM => 'lib/Tree/DAG_Node/Persist.pm',
);
