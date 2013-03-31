package LAN::Settings;

BEGIN {
	push ( @INC, "../" );
}

use v5.14;
use warnings;

use Net::Ping;
use Net::IP;
use Scalar::Util qw (refaddr);
use Config::IniFiles;
use Nmap::Scanner;
use Data::Dumper;

use constant {
	SCAN_PORT		=> 5060,
	PING_TIMEOUT	=> 0.1,
	PORT_TIMEOUT	=> 200,
	CONFIG_FILE		=> "/home/denis/build/perl/phone_configuration/lib/LAN/config"

};

our %config;

our %ip_port;

sub new {
	my ( $class ) = @_;
	my $self = bless ( {}, $class );
	return $self;
}

sub init {
	my $self = shift;	
	$self->__read_config();
	return 1;
}

sub config_net_addr {
	my ( $self ) = @_;
	my %net = %{$config{refaddr $self}->{v}} if( exists($config{refaddr $self}) );
	if ( exists( $net{&LAN::Constants::SECTION_NET}{&LAN::Constants::NET_ADDR} ) ) {
		return $net{&LAN::Constants::SECTION_NET}{&LAN::Constants::NET_ADDR};
	}
	else {
		die ( "Couldn't return network address \n" );
	}
}

sub __read_config {
	my ( $self ) = @_;
	my $iniconf = Config::IniFiles->new( -file => CONFIG_FILE )
            						or die( @Config::IniFiles::errors );
    $config{refaddr $self} = $iniconf;
    return 1;
}

sub update_config {
	my $self 	= shift;
	my $config 	= shift;

	my $iniconf = $config{refaddr $self};
	while ( my($sect_name,$sect_ref) = each(%$config) ) {
		my($param,$value) = each( %$sect_ref );
		
		if ( $iniconf->exists($sect_name,$param) ){
			$iniconf->setval( $sect_name, $param, $value );
		}
		else {
			$iniconf->newval( $sect_name, $param, $value );
		}
	}

	$iniconf->WriteConfig( CONFIG_FILE, -delta=>1 );

	return 1;
}

sub ip_detect {
	my ( $self, $range_ip ) = @_;
	
	if ( !defined($range_ip) ) {
		$range_ip = $self->config_net_addr();
	}

	my $ip = new Net::IP($range_ip) or
					die(Net::IP::Error());

    my $pinger = Net::Ping->new();
    do {
    	if ( $pinger->ping($ip->ip(), PING_TIMEOUT) ) {
	        $self->__ip_scaner($ip->ip());
	    }
  	} while (++$ip);
	$pinger->close();

	return %ip_port;
}

sub __ip_scaner {
	my ( $self, $ip ) = @_;
	
	my $scanner = Nmap::Scanner->new();
  	$scanner->udp_scan();
  	$scanner->add_scan_port( SCAN_PORT );
  	$scanner->guess_os();
  	$scanner->max_rtt_timeout( PORT_TIMEOUT );
  	$scanner->add_target( $ip );
  	
  	#instance of Nmap::Scanner::Backend::Results
  	my $results = $scanner->scan();

  	my $hosts = $results->get_host_list();

 	while (my $host = $hosts->get_next()) {
      my $ports = $host->get_port_list();

      while (my $port = $ports->get_next()) {
      	if ( $port->state() =~ /open.*/ ) {
      		my $ip = (map {$_->addr()} $host->addresses())[0];
        	$ip_port{$ip} = $port->portid();
        	say ("IP=".$ip);
        	say ("Port=".$port->portid());
        }
      }
  	}

  	return 1;
}

sub devices_info {
	my ( $self, %ip_port ) = @_;
	
	my @out;
	if ( scalar(keys %ip_port) != 0 ) {
		while ( my ($ip, $port) = each (%ip_port) ) {
			my %inet = (
						PeerAddr => $ip,
						PeerPort => $port, #always 5060
						Proto   => "udp"
					   );
			my %resp = $self->__send_recv_sip( %inet );
			push (@out,\%resp);
		}
	}
	else {
		die( "Don't available ip and ports\n" );
	}

	return @out;
}

sub __send_recv_sip {
	my ( $self, %inet ) = @_;
	
	my $socket = IO::Socket::INET->new(%inet)
									or die ("Can't create socket $!\n");
	$socket->autoflush(1);
	
	print $socket	'OPTIONS sip: anonymous' , '@' , $inet{PeerAddr} , ' SIP/2.0' , "\015\012",
		'Via: SIP/2.0/UDP ' , $socket->sockhost() , ':' , $socket->sockport() , ';branch=z9hG4bK' , time() , rand(1000000000) , "\015\012",
		'Max-Forwards: 70' , "\015\012",
		'To: <sip: anonymous', '@' , $inet{PeerAddr} , '>' , "\015\012",
		'From: GNU/Linux <sip:denis@' , $socket->sockhost() , '>;tag=' , time() , rand(1000000000) , "\015\012",
		'Call-ID: ' , time() , rand(1000000000) , '@' , $socket->sockport() , "\015\012",
		'CSeq: 101 OPTIONS' , "\015\012",
		'Contact: <sip:denis', $socket->sockhost() , ':' , $socket->sockport() , '>' , "\015\012",
		'Accept: application/sdp' , "\015\012",
		'Content-Length: 0' , "\015\012",
		"\015\012";

	my $resp;
	
	eval {
		$socket->recv($resp, 1024);
	};
	if ( $! ) {
		die( $! );
	}

	my $device_name = undef;
	my $ip_device	= undef;
	if ( $resp =~ /.*Server:[ ]*([\w|.|\/|-]*)/ ){
		$device_name = $1;
	}
	if ( $resp =~ /.*To:[ ]*\<sip:[ ]*\w*\@([\w|.]*)/ ){
		$ip_device = $1;
	}
	my %out = ($ip_device => $device_name);
	
	return %out;
}

our $AUTOLOAD;
sub AUTOLOAD {
  my ($self) = @_;
  die ("Doesn't found $AUTOLOAD");
}

sub DESTROY {
	
}

1;