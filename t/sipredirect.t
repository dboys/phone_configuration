#!/usr/bin/perl

# sipredirect.pl - A simple SIP redirect server
# http://vektor.ca/telephony/sipredirect/
#
# Copyright (c) 2004 Billy Biggs <vektor@dumbterm.net>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# sipredirect.pl 0.2 - Mon Feb 16 12:38:33 EST 2004
#  - Some bugfixes, send 501 on unknown method.
# sipredirect.pl 0.1 - Mon Feb 16 10:54:59 EST 2004
#  - Initial release.

use strict;
use Socket;
use Sys::Hostname;

my $contact = "SPA941 <sip:user\@192.168.73.129>";
my $localhost = "127.0.0.1";

# This function returns the full via list from a message.
sub viaList {
	my $vialist;
	my $msg = $_[0];

	my @lines = split("^",$msg);
	foreach my $sipLine (@lines) {
		$_ = $sipLine;
		if(/^v *:/i || /^via *:/i) {
			$vialist .= $_;
		}
	}

	return $vialist;
}

# This function returns the value of the specified SIP header.  This function
# does not handle line folding yet.
sub headerValue {
	my $value;
	my $sipHeader = $_[0]; 
	my $headerName = $_[1]; 
	my $altHeaderName = $_[2]; 

	my @lines = split("^",$sipHeader);  # divide into lines
	foreach my $sipLine (@lines) {
		$_ = $sipLine;
		if(/^$headerName *:/i || /^$altHeaderName *:/i) {
			# extract the value from the line
			(undef, $value) = split(":",$_,2);
			$value =~ s/^\s*//; # remove leading whitespace 
			$value =~ s/[\r\n]*$//;  # remove trailing newlines
			return $value;
		};
	};
	return "none";
}

sub buildResponseWithContact {
	my $msg;
	my $rnum = $_[0];
	my $rtag = $_[1];
	my $vialist = $_[2];
	my $to = $_[3];
	my $from = $_[4];
	my $callid = $_[5];
	my $cseq = $_[6];
	my $contact = $_[7];

	$msg = 	"SIP/2.0 " . $_[0] . " " . $_[1] . "\r\n".
		$vialist.
		"t: " . $to . "\r\n".
		"f: " . $from . "\r\n".
		"i: " . $callid . "\r\n".
		"cseq: " . $cseq . "\r\n".
		"m: " . $contact . "\r\n".
		"L: 0\r\n".
		"\r\n\r\n";

	return $msg;
}

sub isInvite { $_ = $_[0]; return /^INVITE/i; }
sub isCancel { $_ = $_[0]; return /^CANCEL/i; }
sub isAck { $_ = $_[0]; return /^ACK/i; }
sub isResponse { $_ = $_[0]; return /^SIP/i; }

my $iaddr = gethostbyname($localhost); # hostname());

sub listenUDP {
	my $port = shift;
	local *ISOCKET;
	socket(ISOCKET, PF_INET, SOCK_DGRAM, getprotobyname('udp'))
		or die "incoming udp socket: $!";
	bind(ISOCKET, sockaddr_in($port, $iaddr))
		or die "incoming udp bind: $!";
	return *ISOCKET;
};

my $sock = listenUDP(5060);
print "sipredirect: Listening on port 5060...\n";

for(;;) {
	my $port;
	my $ipaddr;
	my $src;
	my $msg;
	my $msgprint;

	$src = recv($sock, $msg, 65535, 0);
	($port, $ipaddr) = sockaddr_in($src);

	print "sipredirect: Incoming message:\n";
	$msgprint = $msg;
	$msgprint =~ s/\n/\n\t/g;
	print "\t$msgprint\n";

	print "sipredirect: Sending response to port $port.\n";

	if(isInvite($msg)) {
		my $vialist = viaList($msg);
		my $to = headerValue($msg, "to");
		my $from = headerValue($msg, "from");
		my $callid = headerValue($msg, "call-id");
		my $cseq = headerValue($msg, "cseq");
		my $resp;

		if("$to" =~ "none") { $to = headerValue($msg, "t"); }
		if("$from" =~ "none") { $from = headerValue($msg, "f"); }
		if("$callid" =~ "none") { $callid = headerValue($msg, "i"); }

		$resp = buildResponseWithContact("302", "Redyrekted 0ldsk00l",
			$vialist, $to, $from, $callid, $cseq, $contact);
		print "sipredirect: Forwarding INVITE:\n";
		$msgprint = $resp;
		$msgprint =~ s/\n/\n\t/g;
		print "\t$msgprint\n";
		send($sock, $resp, 0, $src);
	} elsif(isCancel($msg)) {
		print "sipredirect: Ignoring CANCEL, it's not for us.\n";
	} elsif(isAck($msg)) {
		print "sipredirect: Ignoring ACK message.\n";
	} elsif(!isResponse($msg)) {
		my $vialist = viaList($msg);
		my $to = headerValue($msg, "to");
		my $from = headerValue($msg, "from");
		my $callid = headerValue($msg, "call-id");
		my $cseq = headerValue($msg, "cseq");
		my $resp;

		if("$to" =~ "none") { $to = headerValue($msg, "t"); }
		if("$from" =~ "none") { $from = headerValue($msg, "f"); }
		if("$callid" =~ "none") { $callid = headerValue($msg, "i"); }

		$resp = buildResponseWithContact("501",
			"Unimplemented - I am lazy",
			$vialist, $to, $from, $callid, $cseq, $contact);
		print "sipredirect: Unimplemented request, sending 501.\n";
		$msgprint = $resp;
		$msgprint =~ s/\n/\n\t/g;
		print "\t$msgprint\n";
		send($sock, $resp, 0, $src);
	} else {
		print "sipredirect: Ignoring unknown response.\n";
	}
}

