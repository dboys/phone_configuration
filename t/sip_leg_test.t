#!/usr/bin/perl

use Net::SIP;

# create new agent
my $ua = Net::SIP::Simple->new(
  outgoing_proxy => '192.168.73.129',
  registrar => '192.168.73.129',
  domain => '192.168.73.129',
  from => 'denis',
  to => 'user@192.168.73.129'
);

# Register agent
$ua->register;

# Mainloop
$ua->loop;