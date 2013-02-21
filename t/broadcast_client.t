#!/usr/bin/perl

use warnings;
use strict;
use IO::Socket::INET;

print "\n>>Client Program <<\n";
#--
#-- client.pl
#--
# Create a new socket
my $MySocket=new IO::Socket::INET->new(	PeerPort=>5060,
                                        Proto=>'udp',
                                        Broadcast => 1,
                     					PeerAddr=>'192.168.73.129'
                     				  );


# Send messages
my $def_msg="Enter message to send to server : ";
my $msg = "";

print "\n",$def_msg;
while($msg=<STDIN>)
{
   chomp $msg;
   if($msg ne '')
   {
      print "\nSending message '",$msg,"'";
      if($MySocket->send($msg))
      {
         print ".....<done>","\n";
         print $def_msg;
      }
   }
   else
   {
      # Send an empty message to server and exit
      $MySocket->send('');
      exit 1;
   }
}