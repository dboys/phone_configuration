#!/usr/bin/perl

use v5.14;
use warnings;
use IPPhone::Settings;
use IPPhone::Constants;
use Data::Dumper;

main();

sub main {

	my %arr = ();
	say scalar(keys(%arr));

#	my $phone = IPPhone::Settings->new();
#	$phone->init($IPPhone::Constants::IP => "192.168.73.129");
#	
#	my $content = $phone->get();
#	
#	my %args = ($IPPhone::Constants::STATION_NAME => "cool",
#				$IPPhone::Constants::USER_PASSWD => "denis");
#	my %id = $phone->regex_policy($content,%args);
#	$phone->post(%id);

}