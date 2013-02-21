#!/usr/bin/perl

=head1 NAME

sip_poller.pl - A perl script for discovering and polling SIP servers with OpenNMS

=head1 VERSION

0.1

=head1 SYNOPSIS

./sip_poller --hostname=123.123.123.123

=head1 USAGE

./sip_poller.pl --hostname=[hostname] --timeout=[timeout] --user=[user] --src=[IP Address] --codes=[response codes]
 --hostname: Remote host to test. DNS Hostname or Dotted Decimal notation is accepted. Required.
 --timeout: Timeout in seconds to wait for a response. Optional.
 --user: Remote user to send the request to. Optional (default is 'opennms').
 --src: Source IP Address to send the request from. Optional.
 --codes: SIP response codes to exit 0 on. If not given we exit 0 on any response code.

=head1 DESCRIPTION

This script is intended for use with OpenNMS to monitor and discover servers providing the SIP service by sending a
SIP Options packet to the remote host and checking for a response. It only checks for SIP over UDP and does not support
SIP over TCP. If a response is received it will print the response code to STDOUT (e.g. for a 200 OK it would print '200')
and will exit 0 (success). If no response is received or it is not a valid sip packet it will exit 1 (failure).

=head1 OpenNMS Configuration

The examples configurations below assume you have placed the script in /opt/opennms/contrib/ and that you do not have any another
service named 'SIP' already. You will need to restart OpenNMS after applying the configuration.

=head2 capsd-configuration.xml

 <protocol-plugin protocol="SIP" class-name="org.opennms.netmgt.capsd.plugins.GpPlugin" scan="on" user-defined="true">
	<property key="script" value="/opt/opennms/contrib/sip_poller.pl" />
	<property key="args" value="caps-arg1 caps-arg2"/>
	<property key="timeout" value="3000" />
	<property key="retry" value="2" />
 </protocol-plugin>

=head2 poller-configuration.xml

=head3 In a package

 <service name="SIP" interval="300000" user-defined="true" status="on">
	<parameter key="script" value="/opt/opennms/contrib/sip_poller.pl"/>
	<parameter key="args" value="poll-arg1 poll-arg2"/>
	<parameter key="retry" value="1"/>
	<parameter key="timeout" value="2000"/>
	<parameter key="rrd-repository" value="/var/opennms/rrd/response"/>
	<parameter key="rrd-base-name" value="SIP" />
	<parameter key="ds-name" value="SIP"/>
 </service>

=head3 Monitor line

 <monitor service="SIP" class-name="org.opennms.netmgt.poller.monitors.GpMonitor"/>

=head2 response-graph.properties

I don't know how well the following works for graphing. It will show and display a response graph but I do not know
if the scale is correct, or even what it is recording for the response time.

If you know anything more, or have any suggestions on these please send me an email.

=head3 reports=

 To the 'reports=' line add 'sip' at the end. It should look something like the following:

 reports=icmp, avail, dhcp, dns, http, http-8000, http-8080, mail, pop3, radius, smtp, ssh, jboss, snmp, ldap, strafeping, sip

=head3 Report entry

 report.sip.name=SIP
 report.sip.columns=SIP
 report.sip.type=responseTime, distributedStatus
 report.sip.command=--title="SIP Response Time" \
  --vertical-label="Seconds" \
  DEF:rtMills={rrd1}:SIP:AVERAGE \
  DEF:minRtMills={rrd1}:SIP:MIN \
  DEF:maxRtMills={rrd1}:SIP:MAX \
  CDEF:rt=rtMills,1000,/ \
  CDEF:minRt=minRtMills,1000,/ \
  CDEF:maxRt=maxRtMills,1000,/ \
  LINE1:rt#0000ff:"Response Time" \
  GPRINT:rt:AVERAGE:" Avg  \\: %8.2lf %s" \
  GPRINT:rt:MIN:"Min  \\: %8.2lf %s" \
  GPRINT:rt:MAX:"Max  \\: %8.2lf %s\\n"

=head1 LICENSE

Copyright (C) 2010 by Ryan Bullock (rrb3942@gmail.com)

This script is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

use strict;
use warnings;

use Getopt::Long;
use IO::Socket::INET;

my $host;
my $timeout;
my $user = 'user';
my $src;
my $codes;

#Usage output
sub usage {
	print STDERR	"\n",
		"./sip_poller.pl --hostname=[hostname] --timeout=[timeout] --user=[user] --src=[IP Address] --codes=[response codes]\n",
		"--hostname: Remote host to test. DNS Hostname or Dotted Decimal notation is accepted. Required.\n",
		"--timeout: Timeout in seconds to wait for a response. Optional.\n",
		"--user: Remote user to send the request to. Optional (default is 'opennms')\n",
		"--src: Source IP Address to send the request from. Optional.\n",
		"--codes: SIP response codes to exit 0 on. If not given we exit 0 on any response code.\n";

	exit 1;
}

#Get options
GetOptions(	"H|hostname=s"	=> \$host,
		"t|timeout=i"	=> \$timeout,
		"u|user=s"	=> \$user,
		"s|src=s"	=> \$src,
		"c|codes=s"	=> \$codes) or usage();

#Require hostname
unless (defined $host) {
	print STDERR "Hostname must be specified with --hostname=[hostname]\n";
	usage();
}

#Set timeout
$timeout = 0 unless defined ($timeout);

#Connection settings
my %inet = (	PeerAddr => $host,
				PeerPort => 5060,
				Broadcast => 1,
				Proto   => "udp",
		   );

#Local Address setting
if (defined $src) {
	$inet{'LocalAddr'} = $src;
}

#Connect
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
	#Set timeouts
	$SIG{ALRM} = sub { warn "Timed out waiting for response"; exit 1;};
	alarm $timeout;

	#Read Response
	$socket->recv($resp, 1024);

	alarm 0;
};


print($resp);

#If we got a response print the response code and exit 0
if (defined $resp && $resp =~ /^SIP\/(?:\d\.\d) (\d{3}) .+$/m) {
	print $1,"\n";

	#Accept Any response code
	if (!defined $codes) {
		exit 0;	
	} else {
		#Compare to our list and exit 0 on a positive match
		foreach (split /,/, $codes) {
			if ($_ eq $1) { exit 0;}
		}
	}
}
print ($resp);
#Failed
exit 1;
