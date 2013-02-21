#!/usr/bin/perl -w 

#sipsak -vvvv -U -s sip:denis@192.168.1.2:5060

use strict;
use warnings;
use Net::SIP;

my $loop = Net::SIP::Dispatcher::Eventloop->new;

my $leg = Net::SIP::Leg->new(addr => '192.168.73.129');

my $disp = Net::SIP::Dispatcher->new(
        [ $leg ],
	$loop,
);
$disp->set_receiver(\&receive);

$loop->loop;


sub receive {
    my ($packet,$leg,$from_addr) = @_;

    print "\nPacket IN:\n";
    print $packet->as_string;

    my ($request,$response) = $packet->is_request
        ? ($packet, undef)
        : (undef, $packet);

    my $cseq = $packet->cseq;
    my ($num,$method) = split( ' ', $cseq);

    if($request) {
	if($method eq 'REGISTER') {
            my $resp  = $request->create_response('200', 'OK');
            print "\nPacket OUT:\n";
            print $resp->as_string;
            #$disp->deliver($resp);
	    $disp->deliver($resp, leg => $leg, dst_addr => $from_addr );
	}
    }
}
