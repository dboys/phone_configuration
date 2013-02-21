#!/usr/bin/perl
use IO::Socket;

#--------------------------------------------------------

$numArgs = $#ARGV + 1;
print "thanks, you gave me $numArgs command-line arguments.\n";

#-------------------------------------------------------

my $sock = new IO::Socket::INET (
                              LocalPort => 8888,
                              PeerAddr => '192.168.73.129',
                              Broadcast => 1,
                       		  PeerPort => '5060',
                			  Proto => 'udp',
               );
die "Could not create socket: $!\n" unless $sock;

#-------------------------------------------------------

my $sip_request="";
my $response = "";

# register
$sip_request = "OPTIONS sip:192.168.73.129:5060 SIP/2.0\r\nFrom: <sip:denis\@192.168.73.199:5060> ;tag=hrs7fes6\r\n";
$sip_request = $sip_request."To: <sip:user\@192.168.73.129:5060> \r\nCall-ID: ft36633sdffff7a21111111z7\r\n";
$sip_request = $sip_request."CSeq: 1 OPTIONS\r\nContact: 1550 ;q=0.9;expires=3600\r\n";
$sip_request = $sip_request."Via: SIP/2.0/UDP 192.168.73.199:8888;branch=z9hG4bK548s97i77d555458fs\r\n";
$sip_request = $sip_request."Max-Forwards: 70\r\n\r\n";

print "Request to be sent: \n$sip_request\n";

print $sock $sip_request;
#
$sock->recv($sip_request, 5000);
print "Response received: \n$sip_request\n";

$sock->recv($sip_request, 5000);
print "Response received: \n$sip_request\n";

#-------------------------------------------------------

$sip_request = "";
$response = "";


while (TRUE) {

 $sock->recv($sip_request, 5000);
 print "Response received: $sip_request\n";

 @sip_headers = split(/\r\n/, $sip_request);

 print "Number of headers in received message: $#sip_headers\n\n";

 print "\n\n-------------------------------------------------\n\n";


 #-------------------------------------------------------------

 #send 100 Trying
 $response = "SIP/2.0 100 Trying\r\n";

 foreach $header (@sip_headers) {
     if (($header =~ "^From") or ($header =~ "^To") or ($header =~ "^Call-ID") or ($header =~ "^CSeq") or ($header =~ "^Via")) {
         $response = $response.$header."\r\n";
     }
 }

 $response = $response."\r\n";

 print "Response to be sent: $response\n";

 print $sock $response;

 #-----------------------------------------------------------

 #send 180 Ringing
 $response = "SIP/2.0 180 Ringing\r\n";

 foreach $header (@sip_headers) {
     if (($header =~ "^From") or ($header =~ "^To") or
         ($header =~ "^Call-ID") or ($header =~ "^CSeq") or
         ($header =~ "^Via")) {

            if ($header =~ "^To") {
                $header = $header.";tag=rfsdf677566577";
            }
         $response = $response.$header."\r\n";
     }
 }

 $response = $response."Contact: ; isfocus\r\nContent-Length:0\r\n";
 $response = $response."Record-Route: ,,\r\n";
 $response = $response."Require: 100rel\r\nRSeq: 1\r\n";
 $response = $response."Content-Type: application/sdp\r\n";

 $response = $response."\r\n";

 print "Response to be sent: $response\n";

 print $sock $response;

 #---------------------------------------------------------------
 # wait for PRACK

 $sock->recv($sip_request, 5000);
 print "Response received: $sip_request\n";

 @sip_headers = split(/\r\n/, $sip_request);

 print "Number of headers in received message: $#sip_headers\n\n";

 print "\n\n-------------------------------------------------\n\n";

 #-----------------------------------------------------------------

 #send 200 OK
 $response = "SIP/2.0 200 OK\r\n";

 foreach $header (@sip_headers) {
     if (($header =~ "^From") or ($header =~ "^To") or
         ($header =~ "^Call-ID") or ($header =~ "^CSeq") or
         ($header =~ "^Via")
        ) {
         $response = $response.$header."\r\n";
     }
 }

 $response = $response."Contact: ; isfocus\r\nContent-Length:189\r\n";
 $response = $response."Content-Type: application/sdp\r\n";

 $response = $response."\r\n";

 $response = $response."v=0"."\r\n"."o=RV-MCU 2021970 2021970 IN IP4 10.232.15.31"."\r\n"."s=RV MCU Session\r\n"."c=IN IP4 10.232.15.31"."\r\n"."b=CT:64"."\r\n"."t=0 0"."\r\n"."m=audio 6028 RTP/AVP 8"."\r\n"."c=IN IP4 10.232.15.31"."\r\n"."a=rtpmap:8 PCMA/8000"."\r\n"."a=sendrecv"."\r\n";

 print "Response to be sent: $response\n";

 print $sock $response;

 #---------------------------------------------------------------

 #Wait for ACK
 $sip_request = "";
 @sip_headers = "";

 $sock->recv($sip_request, 5000);
 print "Response received: $sip_request\n";

 @sip_headers = split(/\r\n/, $sip_request);

 print "Number of headers in received message: $#sip_headers\n\n";

 print "\n\n-------------------------------------------------\n\n";

 print "CALL SETUP\n";
 sleep 100;

 #----------------------------------------------------------------

}

close $sock or die "Died";