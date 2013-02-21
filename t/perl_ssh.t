#!/usr/bin/perl

use Net::OpenSSH;
use strict;
use warnings;

my $host = "denis\@192.168.1.3";
 
my $ssh = Net::OpenSSH->new($host,passwd=>"denis1992");
$ssh->error and
  die "Couldn't establish SSH connection: ". $ssh->error;
 
$ssh->system("passwd") or
  die "remote command failed: " . $ssh->error;

#my @ls = $ssh->capture("ls");
#$ssh->error and
#  die "remote ls command failed: " . $ssh->error;
# 
#my ($out, $err) = $ssh->capture2("find /root");
#$ssh->error and
#  die "remote find command failed: ".$ssh->error;