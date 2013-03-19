#!/usr/bin/perl

use v5.14;
use warnings;
use lib "../lib";
use IPPhone::Settings;
use IPPhone::Constants;
use LAN::Settings;
use Data::Dumper;


main();

sub main {
	say("detect -- find all device in lan \nupdate -old=<old_ip> -new=<new ip> -user=<username> -passwd=<password> \n");
	while( 1 ) {
		print('$');
		my $cmd = readline( *STDIN );
		if ( $cmd =~ /detect/ ) {
			my $lan = LAN::Settings->new();
			my %ip_port = $lan->detect();
			my %device_info = $lan->devices_info();
		}
		elsif ( $cmd =~ /update -old=([\w|\.]*) -new=([\w|\.]*) -user=([\w|\.]*) -passwd=([\w|\.]*)/ ) {
			my $phone = IPPhone::Settings->new();
			$phone->init( $IPPhone::Constants::IP => $1 );
			my %args = ($IPPhone::Constants::IP				=> $2,
						$IPPhone::Constants::STATION_NAME 	=> $3,
						$IPPhone::Constants::USER_PASSWD 	=> $4);
			if ( $phone->update( %args ) ){
				say( "Looks good" );
			}
			else {
				say( "Looks bad" );
			}
		}
	}
}

sub update_tests_file {
	my $FH;
	my $content;
	open( $FH, "<", "content_html" );
	while(<$FH>){
		$content .= $_;
	}
	
	my $phone = IPPhone::Settings->new();
	my %args = ($IPPhone::Constants::IP				=> '192.168.1.1',
				$IPPhone::Constants::STATION_NAME 	=> "cool",
				$IPPhone::Constants::USER_PASSWD 	=> "denis");
	my %id = $phone->regex_policy($content,%args);
	
	return %id;
}