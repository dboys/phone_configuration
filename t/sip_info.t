#!/usr/bin/perl

use IO::Socket;
use strict;
use warnings;

my $server = IO::Socket::INET->new(	LocalPort => '5060',
									PeerAddr => "192.168.73.182",
									PeerPort => "5060",
									Proto => "udp"
								  )
								or die "Couldn't be a udp server on port : $@n";

my $datagram;
my $MAX_TO_READ = 2048;

while (my $user=$server->recv($datagram,$MAX_TO_READ))
{
	print "---n";
	print $datagram;
} 

close($server);
