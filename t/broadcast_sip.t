#!/usr/bin/perl

use v5.14;
use warnings;
use Net::SIP::Request;

my $user = '10003';
my $host = '192.168.73.129';

#Connection settings
my %inet = (	PeerAddr => $host,
				PeerPort => 5060,
				Broadcast => 1,
				Proto   => "udp",
		   );
my $socket = IO::Socket::INET->new(%inet) or die "$!";
$socket->autoflush(1);

#Build and send Options Packet
print $socket	'OPTIONS sip:' , $user , '@' , $host , ' SIP/2.0' , "\015\012",
		'Via: SIP/2.0/UDP ' , $socket->sockhost() , ':' , $socket->sockport() , ';branch=z9hG4bK' , time() , rand(1000000000) , "\015\012",
		'Max-Forwards: 70' , "\015\012",
		'To: <sip:' , $user , '@' , $host , '>' , "\015\012",
		'From: OpenNMS <sip:denis@' , $socket->sockhost() , '>;tag=' , time() , rand(1000000000) , "\015\012",
		'Call-ID: ' , time() , rand(1000000000) , '@' , $socket->sockport() , "\015\012",
		'CSeq: 101 OPTIONS' , "\015\012",
		'Contact: <sip:denis', $socket->sockhost() , ':' , $socket->sockport() , '>' , "\015\012",
		'Accept: application/sdp' , "\015\012",
		'Content-Length: 0' , "\015\012",
		"\015\012";

#Buffer for response
my $resp;

#Eval with a timeout (if one was set)
eval {
	#Read Response
	$socket->recv($resp, 1024);
};


print($resp);
