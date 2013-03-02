#!/usr/bin/perl

use v5.14;
use warnings;
use lib "../lib";
use IPPhone::Settings;
use IPPhone::Constants;
use Data::Dumper;

main();

sub add {
	my (%info) = @_;
	my @arr = (1,2,3);
	my @arr2 = (1,2,3,4);
	
	$info{1} = \@arr;
	
	return %info;
}

sub main {

my %info;
%info = add(%info);

print @{$info{1}};

#	my $FH;
#	my $content;
#	open( $FH, "<", "content_html" );
#	while(<$FH>){
#		$content .= $_;
#	}

#	my $phone = IPPhone::Settings->new();
#	$phone->init($IPPhone::Constants::IP => "192.168.73.129");
#	
#	my $content = $phone->get();
#	
#	my %args = ($IPPhone::Constants::STATION_NAME => "cool",
#				$IPPhone::Constants::USER_PASSWD => "denis");
#	my %id = $phone->regex_policy($content,%args);
#	print Dumper (%id);
#	$phone->post(%id);

}