#!/usr/bin/perl

use v5.14;
use warnings;

my $FH;
open( $FH, '<', "sip_response.dump" );

#while ( <$FH> ){
#	if ( $_ =~ /(.|\n)*Station Name.*\<(\w)\>/ ){
#		say ($1);
#	}
#}

#[.|\n]*Server:[ ]*([\w|.|\/|-]*)
#.*To: \<sip:\w*\@([\w|.]*)

my $str = '
SIP/2.0 404 Not Found
To: <sip:10003@192.168.73.193>;tag=df9eaae8cee85322i0
From: OpenNMS <sip:denis@192.168.73.139>;tag=1363619993342926040.382253
Call-ID: 1363619993875758612.566767@32897
CSeq: 101 OPTIONS
Via: SIP/2.0/UDP 192.168.73.139:32897;branch=z9hG4bK1363619993662070704.464899
Server: Sipura/SPA941-4.1.8
Content-Length: 0';
if ( $str =~ /.*To: \<sip:\w*\@([\w|.]*)/ ){
	say $1;
}