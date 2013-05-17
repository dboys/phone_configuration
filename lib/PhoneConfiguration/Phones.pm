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
	
	if ( $self->req->method =~ "POST" ) {
		$self->app()->log()->debug( "POST" );
		Mojo::IOLoop->stream($self->tx->connection)->timeout(300);
		
		#my %ip_port 	= $self->lan()->ip_detect();
		#my @device_info	= $self->lan()->devices_info(%ip_port);
		#foreach my $phone ( @device_info ) {
		#	while( my($ip,$vendor) = each( %$phone ) ) {
		#		my %dst_ip = (&IPPhone::Constants::DST_IP => $ip);
		#		my $phone = $self->phone( %dst_ip );
		#		$self->db->resultset('HtmlInfo')->create({
		#			'proxy_id'	=> $phone->proxy,
		#			'login_id'	=> $phone->login,
		#			'passwd_id'	=> $phone->passwd,
		#			'ip'		=> $phone->dst_ip
		#		});
		#	}
		#}
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
	$self->app()->log()->debug("Update");
	
	if ( $self->req->method =~ m/post/i ) {
		$self->app()->log()->debug("POST Update");
		
		my $headers 	= $self->req->headers();
		my $ip 			= $headers->header('x-ip');
		my $passwd 		= $headers->header('x-passwd');
		my $login 		= $headers->header('x-name');
		my $proxy 		= $headers->header('x-proxy');
		my $mode		= $headers->header('x-mode');
		
		$self->app()->log()->debug("IP $ip");
		$self->app()->log()->debug("PASSWD $passwd");
		$self->app()->log()->debug("Login $login");
		$self->app()->log()->debug("Proxy $proxy");
		$self->app()->log()->debug("Mode $mode");
		
		if ( (defined($mode)) && ($mode =~ m/drag_drop/i) ) {
			$self->app()->log()->debug("drag&drop");
			
			$self->stash( users => [ $self->db->resultset('User')->all() ] );
			
			$self->stash( phones => [$self->lan->test_devices_info] );
	 	
			my %phone_param = (
							&IPPhone::Constants::DST_IP 			=> $ip,
							&IPPhone::Constants::PROXY				=> $proxy,
							&IPPhone::Constants::USER_ID 			=> $login,
							&IPPhone::Constants::PASSWD 			=> $passwd 
					   );
			my $html_info = $self->db->resultset('HtmlInfo')->single({
				'ip'	=> $ip
			});
			
			my $proxy_id 	= $html_info->proxy_id ;
			my $login_id	= $html_info->login_id ;
			my $passwd_id 	= $html_info->passwd_id;
			
			my %post_param = (
							   $proxy_id 	=> $proxy,
							   $login_id 	=> $login,
							   $passwd_id 	=> $passwd
							 );
			
			$self->app->log->debug("Dst ip $ip");
			$self->app->log->debug( Dumper(%post_param) );
			
			if ( $self->phone()->update( $ip, \%post_param ) ){
				$self->app()->log()->debug( "Looks good\n" );	
			}
			else {
				$self->app()->log()->debug( "Bad\n" );
			}
		}	
	}
	elsif ( $self->req->method =~ m/get/i ) {

		$self->stash( users => [ $self->db->resultset('User')->all() ] );

		$self->stash( phones => [$self->lan->test_devices_info]);
	}
}

sub settings {
	my $self = shift;
	
	if ( $self->req->method =~ "POST" ) {
		my $config = { &LAN::Constants::SECTION_NET => {
					   &LAN::Constants::NET_ADDR => $self->param('ip_start_range')."-".$self->param('ip_fin_range')
													   }	
					 };
		$self->app()->log()->debug( Dumper($config)  );
		$self->lan()->update_config($config);

		$self->redirect_to('/');
	}
	elsif ( $self->req->method =~ "GET" ) {
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
