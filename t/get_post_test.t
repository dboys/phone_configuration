#!/usr/bin/perl

use strict;
use warnings;
use v5.14;
use HTTP::Request::Common;
use feature 'unicode_strings';
use LWP::UserAgent;
use Data::Dumper;
   

#my $ip = '192.168.73.129';
#
##51951 => "kill" -- Station Name
##30639 => "0" -- DHCP
##29807 => "192.168.73.13" -- Static IP
##						  -- User Password
#
#my $ua = LWP::UserAgent->new();
#print Dumper $ua->request(GET "http://$ip/admin/advanced")->content;
##print Dumper $ua->request(POST "http://$ip/admin/asipura.spa", [51951 => "kill",29807 => "192.168.73.13"]);