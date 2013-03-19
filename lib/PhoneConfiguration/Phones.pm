package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';

use lib "../../lib";
use IPPhone::Settings;
use IPPhone::Constants;

# This action will render a template
sub main {
  	my $self = shift;

  	$self->stash( users => [ $self->db->resultset('User')->all() ] );
  	
  	#my $lan = LAN::Settings->new();
	#$lan->detect();
	#my %device_info = $lan->devices_info();
	my %device_info = ( '192.168.2.4'=>'SipuraSPA1','192.168.2.3'=>'SipuraSPA2' );
	$self->stash( phones => \%device_info );
}

sub update {
	my $self = shift;
	my $headers = $self->req->headers();

	my $old_ip 		= $headers->{'headers'}->{'x-oldip'}->[0]->[0];
	my $new_passwd 	= $headers->{'headers'}->{'x-passwd'}->[0]->[0];
	my $new_name 	= $headers->{'headers'}->{'x-name'}->[0]->[0];
	my $new_ip 		= $headers->{'headers'}->{'x-ip'}->[0]->[0];
	
	$self->app()->log()->debug(	'new ip= '.$new_ip."\n".
								'new name= '.$new_name."\n".
								'new passwd= '.$new_passwd."\n".
								'old ip= '.$old_ip."\n");
								
#	my $phone = IPPhone::Settings->new();
#	$phone->init( $IPPhone::Constants::IP => $old_ip );
#	my %args = (	$IPPhone::Constants::IP				=> $new_ip,
#					$IPPhone::Constants::STATION_NAME 	=> $new_name,
#					$IPPhone::Constants::USER_PASSWD 	=> $new_passwd);
#	if ( $phone->update( %args ) ){
#		print( STDERR "Looks good\n" );	
#	}
#	else {
#		print( STDERR "Bad\n" );
#	}
}

1;
