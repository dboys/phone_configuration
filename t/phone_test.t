#!/usr/bin/perl

BEGIN {
	push ( @INC, "../lib" );
}

use warnings;
use v5.14;
use Test::More tests => 1;
use Data::Dumper;
use IPPhone::Settings;
use IPPhone::Constants;

my %args = (	
					$IPPhone::Constants::PROXY				=> "195.69.76.159",
					$IPPhone::Constants::USER_ID 			=> "10003",
					$IPPhone::Constants::PASSWD 			=> "qwerty1" 
		   );

my $phone = IPPhone::Settings->new();
my %dst_ip = ($IPPhone::Constants::DST_IP => "127.0.0.1");
ok( eval {$phone->init(%dst_ip)},"phone->init" );

#my $dst = "127.0.0.1";
#my $content;
#ok( eval {$content = $phone->_get_($dst)},"phone->_get_" );
#print Dumper($content) if (defined($content));
#
#my $FH;
#open( $FH, '<', "content_html.html" );
#my $html;
#while ( <$FH> ){
#	$html .= $_;	
#}
#my %html_id;			   
#ok( eval {%html_id = $phone->regex_policy($html, \%args)},"phone->regex_policy" );
#print Dumper(%html_id);
#
#ok( eval {$phone->_post_($dst, \%html_id)},"phone->_post_" );

ok( $phone->update( %args ),"phone->update" );

#ok($lan->__read_config(),"read config");
#print Dumper %LAN::Settings::config;