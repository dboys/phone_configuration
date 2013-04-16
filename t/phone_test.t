#!/usr/bin/perl

use v5.14;
use strict;
use warnings;
use Data::Dumper;

use Test::More qw/no_plan/;

use lib '../lib';

BEGIN {
		use_ok('IPPhone::Settings');
		use_ok('IPPhone::Constants');
	  }

sub get_from_file {
	my $FH;
	open($FH, "<", "content_html.html") or die $!;
	my $html;
	while (<$FH>) {
		$html .= $_;
	}
	
	return $html;
	
}

my @device_info = ({'192.168.73.151'=>'Linksys1'},{'192.168.73.192'=>'Linksys2'});

ok( my $phone = IPPhone::Settings->new(),'create phone object');

my %dst_ip = (&IPPhone::Constants::DST_IP => '192.168.73.151');

ok($phone->set_dst_ip($dst_ip{&IPPhone::Constants::DST_IP}),"set dst ip");
say Dumper $phone->dst_ip;

my $html = get_from_file();
my %const =     (
					&IPPhone::Constants::PROXY 		=> &IPPhone::Constants::NULL,
					&IPPhone::Constants::USER_ID 	=> &IPPhone::Constants::NULL,
					&IPPhone::Constants::PASSWD 	=> &IPPhone::Constants::NULL
				);
ok(my %html_id = $phone->regex_policy( $html, \%const ),'Regex policy');
print Dumper %html_id;

ok($phone->set_html_id(\%html_id),'set html id');
my $id = $phone->html_id();
say Dumper $id;
say $id->{&IPPhone::Constants::PROXY};
say $id->{&IPPhone::Constants::USER_ID};
say $id->{&IPPhone::Constants::PASSWD};

