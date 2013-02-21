#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket::INET;

print "\n>>Server Program <<\n";
#--
#-- server.pl
#--

# Create a new socket
#my $MySocket=new IO::Socket::INET->new(	LocalPort=>1234,
#                                        Proto=>'udp');
                                                                           
my $MySocket=new IO::Socket::INET->new(	PeerPort=>80,
                                        Proto=>'udp',
                     					PeerAddr=>'192.168.73.182'
                     				  );


# Keep receiving messages from client
my $def_msg="\nReceiving message from client.....\n";
my $text = "";

while(1)
{
   $MySocket->recv($text,512);

   if($text ne '')
   {
      print "\nReceived message '", $text,"'\n";
   }
   # If client message is empty exit
   else
   {
      print "Client has exited!";
      exit 1;
   }
}