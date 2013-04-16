package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

use lib "../../lib";
use IPPhone::Settings;
use IPPhone::Constants;
use LAN::Constants;
use LAN::Settings;
use Mojo::UserAgent;
use Mojo::JSON;
use Data::Dumper;

# This action will render a template
sub main {
  	my $self = shift;
	
	#Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
	
	if ( $self->req->method =~ "POST" ) {
		$self->app()->log()->debug( "POST" );
		Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
		
		my %ip_port 	= $self->lan()->ip_detect();
		my @device_info	= $self->lan()->devices_info(%ip_port);
		foreach my $phone ( @device_info ) {
			while( my($ip,$vendor) = each( %$phone ) ) {
				my %dst_ip = (&IPPhone::Constants::DST_IP => $ip);
				my $phone = $self->phone( %dst_ip );
				$self->db->resultset('HtmlInfo')->create({
					'proxy_id'	=> $phone->proxy,
					'login_id'	=> $phone->login,
					'passwd_id'	=> $phone->passwd,
					'ip'		=> $phone->dst_ip
				});
			}
		}
		
		$self->redirect_to('/update');
	}
}

sub test {
	my $self = shift;
	
	if ( $self->req->method =~ "POST" ) {
		my $test = "POST" ;
		$self->stash( test		=> \$test );
	}
	elsif ( $self->req->method =~ "GET" ) {
		my $test = "GET" ;
		$self->stash( test		=> \$test );
	}
}

sub update {
	my $self = shift;
	
	if ( $self->req->method =~ m/post/i ) {
		
		my $headers 	= $self->req->headers();
		my $old_ip 		= $headers->header('x-oldip');
		my $new_passwd 	= $headers->header('x-passwd');
		my $new_name 	= $headers->header('x-name');
		my $new_ip 		= $headers->header('x-ip');
		my $mode		= $headers->header('x-mode');
		
		if ( (defined($mode)) && ($mode =~ m/drag_drop/i) ) {
			#my $phone = IPPhone::Settings->new();
			#$phone->init( $IPPhone::Constants::DST_IP => $old_ip );
	 	
			my %phone_param = (
							&IPPhone::Constants::DST_IP 			=> $old_ip,
							&IPPhone::Constants::PROXY				=> $new_ip,
							&IPPhone::Constants::USER_ID 			=> $new_name,
							&IPPhone::Constants::PASSWD 			=> $new_passwd 
					   );
			$self->phone( %phone_param );
			
			if ( $self->phone()->update( $self->phone->post_param ) ){
				$self->app()->log()->debug( "Looks good\n" );	
			}
			else {
				$self->app()->log()->debug( "Bad\n" );
			}	
		}	
	}
	elsif ( $self->req->method =~ m/get/i ) {

		$self->stash( users => [ $self->db->resultset('User')->all() ] );
			
		#my %ip_port = $lan->ip_detect();
		#my @device_info = $lan->devices_info(%ip_port);
		
		my @device_info ;
		foreach (1..2 ){
			my %hash = ($_=>$_);
			push(@device_info, \%hash);
		}

		$self->render(phones => [@device_info]);
	}
}

sub settings {
	my $self = shift;
	
	if ( $self->match()->{'method'} =~ "POST" ) {
		my $config = { &LAN::Constants::SECTION_NET => {
					   &LAN::Constants::NET_ADDR => $self->param('ip_start_range')."-".$self->param('ip_fin_range')
													   }	
					 };
		$self->app()->log()->debug( Dumper($config)  );
		$self->lan()->update_config($config);

		$self->redirect_to('/');
	}
	elsif ( $self->match()->{'method'} =~ "GET" ) {
		my $net_addr = $self->lan()->config_net_addr();
		$self->stash(range_ip => [ split('-',$net_addr) ]);
		$self->app()->log()->debug($net_addr);
	}

	$self->app()->log()->debug("phone settings");
}

sub users {
	my $self = shift;
	
	$self->app()->log()->debug("users");
	$self->stash( users => [ $self->db->resultset('User')->all() ] );
	
	if ( $self->req->method =~ "GET" ) {
		
		$self->app()->log()->debug("GET");
		$self->stash( users => [ $self->db->resultset('User')->all() ] );
	}
	elsif ( $self->req->method =~ "POST" ) {

		$self->app()->log()->debug("POST");

		if ( $self->param('mode') =~ m/add/i ){

			$self->app()->log()->debug("add");

			$self->db->resultset('User')->create({
				'name' 		=> $self->param('name'),
				'passwd'	=> $self->param('passwd'),
				'ip'		=> $self->param('ip')	
			});
		}
		elsif ( $self->param('mode') =~ m/del/i ){
			$self->app()->log()->debug("del");

			my $user = $self->db->resultset('User')->search({
				'name'		=> $self->param('name'),
				'passwd'	=> $self->param('passwd'),
				'ip'		=> $self->param('ip')
			});

			$user->delete();
		}
	}
}

1;
