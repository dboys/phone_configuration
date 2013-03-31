package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';

use lib "../../lib";
use IPPhone::Settings;
use IPPhone::Constants;
use LAN::Constants;
use LAN::Settings;
use Mojo::UserAgent;
use Data::Dumper;

my $lan;
my $phone;

# This action will render a template
sub main {
  	my $self = shift;
	
	#another timeout variant
#	Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
#	
  	$self->stash( users => [ $self->db->resultset('User')->all() ] );
#  	
  	$lan = LAN::Settings->new();
  	$lan->init();
#	my %ip_port = $lan->ip_detect();
#	my @device_info = $lan->devices_info(%ip_port);
	
	my @device_info = test();

	$self->render(phones => [@device_info]);
	$self->app()->log()->debug(Dumper($lan));
}

sub test {
	my @device_info ;
	foreach (1..2 ){
		my %hash = ($_=>$_);
		push(@device_info, \%hash);
	}
	
	return @device_info;
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
								'old ip= '.$old_ip."\n" );
								
	$phone = IPPhone::Settings->new();
	$phone->init( $IPPhone::Constants::DST_IP => $old_ip );
	my %args = (	
					$IPPhone::Constants::PROXY				=> $new_ip,
					$IPPhone::Constants::USER_ID 			=> $new_name,
					$IPPhone::Constants::PASSWD 			=> $new_passwd 
			   );
	if ( $phone->update( %args ) ){
		$self->app()->log()->debug( "Looks good\n" );	
	}
	else {
		$self->app()->log()->debug( "Bad\n" );
	}
}

sub settings {
	my $self = shift;
	
	$lan = LAN::Settings->new();
  	$lan->init();
	
	if ( $self->match()->{'method'} =~ "POST" ) {
		my $config = { &LAN::Constants::SECTION_NET => {
					   &LAN::Constants::NET_ADDR => $self->param('ip_start_range')."-".$self->param('ip_fin_range')
													   }	
					 };
		$self->app()->log()->debug( Dumper($config)  );
		$lan->update_config($config);

		$self->redirect_to('/');
	}
	elsif ( $self->match()->{'method'} =~ "GET" ) {
		$self->app()->log()->debug(Dumper($self->match()->{'method'}));
	}

	$self->app()->log()->debug("phone settings");
}

1;
