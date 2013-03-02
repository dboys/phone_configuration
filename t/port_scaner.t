#!/usr/bin/perl -w
use strict;
use IO::Socket::PortState qw(check_ports);

my $hostfile = 'tmp';

my %port_hash = (
        udp => {
            5060      => {}
            }
        );

my $timeout = 5;
my $host = "127.0.0.1";

#open HOSTS, '<', $hostfile or die "Cannot open $hostfile:$!\n";

#while (my $host = <HOSTS>) {
#    chomp($host);
    my $host_hr = check_ports($host,$timeout,\%port_hash);
    print "Host - $host\n";
    for my $port ( keys %{$host_hr->{udp}}) {
        my $yesno = $host_hr->{udp}{$port}{open} ? "yes" : "no";
        print "$port - $yesno\n";
    }
    print "\n";
#}

#close HOSTS;
