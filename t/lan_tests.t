#!/usr/bin/perl

BEGIN {
	push ( @INC, "../lib" );
}

use warnings;
use v5.14;
use Test::More tests => 1;
use Data::Dumper;
use LAN::Settings;

ok(my $lan = LAN::Settings->new(),"new LAN");

ok($lan->read_config(),"read config");
print Dumper %LAN::Settings::config;

ok(my $addr = $lan->net_addr(),"network address");
print Dumper $addr;

ok($lan->ping_detect(),"ping detect");
print Dumper @LAN::Settings::alive_ip;

#ok (my @ports = $lan->check_ip("192.168.1.2"),"check ip");
#print Dumper @ports;

ok ($lan->ports_detect(),"ports detect");
print Dumper %LAN::Settings::ip_port;