package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';

use lib "../../lib";
use IPPhone::Settings;
use IPPhone::Constants;
use LAN::Settings;

# This action will render a template
sub main {
  	my $self = shift;

  	$self->stash( users => [ $self->db->resultset('User')->all() ] );
  	
  	my $lan = LAN::Settings->new();
	$lan->detect();
	my %device_info = $lan->devices_info();
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
								
	my $phone = IPPhone::Settings->new();
	$phone->init( $IPPhone::Constants::IP => $old_ip );
	my %args = (	$IPPhone::Constants::IP				=> $new_ip,
					$IPPhone::Constants::STATION_NAME 	=> $new_name,
					$IPPhone::Constants::USER_PASSWD 	=> $new_passwd);
	if ( $phone->update( %args ) ){
		$self->app()->log()->debug( "Looks good\n" );	
	}
	else {
		$self->app()->log()->debug( "Bad\n" );
	}
}

1;
