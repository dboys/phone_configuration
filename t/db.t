#!/usr/bin/perl

use v5.14;
use warnings;
use lib "../lib";
use DB::Schema;

my $schema = db_connect();

my @all_users = $schema->resultset('User')->all;

foreach my $user (@all_users) {
    print $user->ip, "\n";
}

sub db_connect {
	my %dbi_params = (
      quote_names => 1,
      mysql_enable_utf8 => 1,
    );
	my $schema = DB::Schema->connect('dbi:mysql:users:localhost:3306', 'root', 'denis1992', \%dbi_params);
	return $schema;
}