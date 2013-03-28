#!/usr/bin/perl

BEGIN {
	push ( @INC, "../lib" );
}

use warnings;
use v5.14;
use Test::More tests => 1;
use Data::Dumper;
use LAN::Settings;

#ok(my $lan = LAN::Settings->new(),"new LAN");
#
#ok($lan->__read_config(),"read config");
#print Dumper %LAN::Settings::config;
#
#ok(my $addr = $lan->__net_addr(),"network address");
#print Dumper $addr;
#
#$lan->__ip_scaner("127.0.0.1");
#print Dumper %LAN::Settings::ip_port;
