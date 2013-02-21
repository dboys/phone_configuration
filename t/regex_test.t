#!/usr/bin/perl

use v5.14;
use warnings;

my $FH;
open( $FH, '<', "data_package" );

#while ( <$FH> ){
#	if ( $_ =~ /(.|\n)*Station Name.*\<(\w)\>/ ){
#		say ($1);
#	}
#}

my $str = '
<tr bgcolor="#dcdcdc"><td>Station Name:<td><input class="inputc" size="20" name="51951" value="kill" maxlength=2047><td>Voice Mail Number:<td><input class="inputc" size="20" name="51631" value="" maxlength=2047>
';
if ( $str =~ /.*Station Name:<td><input[^>]*name="(\w+)".*/ ){
	say ( $1 );
}