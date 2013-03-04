package LAN::Settings;

use v5.14;
use warnings;

use Net::Ping;
use Net::Netmask;
use Scalar::Util qw (refaddr);
use Config::IniFiles;
use IO::Socket::PortState qw(check_ports);

use constant {
	PING_TIMEOUT	=> 0.1,
	PORT_TIMEOUT	=> 5,
	CONFIG_FILE		=> "/home/denis/build/perl/phone_configuration/lib/LAN/config",
	SECTION_NET		=> "network",
	NET_ADDR 		=> "net_addr"
};

our %config;

our @alive_ip;

my %ports = (
        udp => {
           	5060      => {}
            }
        );

our %ip_port;

sub new {
	my ( $class ) = @_;
	my $self = bless ( {}, $class );
	return $self;
}

sub __net_addr {
	my ( $self ) = @_;
	my %net = %{$config{refaddr $self}};
	if ( exists( $net{&SECTION_NET}{&NET_ADDR} ) ) {
		return $net{&SECTION_NET}{&NET_ADDR};
	}
	else {
		die ( "Couldn't return network address \n" );
	}
}

sub __read_config {
	my ( $self ) = @_;
	my $iniconf = Config::IniFiles->new( -file => CONFIG_FILE )
            						or die( @Config::IniFiles::errors );
    $config{refaddr $self} = $iniconf->{v};
    return 1;
}

sub __ping_detect {
	my ( $self ) = @_;
	
	my $netmask = $self->__net_addr();
	my $block   = Net::Netmask->new2( $netmask )
    							or die "$netmask is not a valid netmask\n";
    my $pinger = Net::Ping->new();
	for my $ip ($block->enumerate) {
	    if ( $pinger->ping($ip, PING_TIMEOUT) ) {
	        say "$ip is alive";
	        push( @alive_ip, $ip );
	    }
	}
	$pinger->close();

	return 1;
}

sub __ports_detect {
	my ( $self ) = @_;
	if ( scalar( @alive_ip ) != 0 ) {
		foreach my $ip ( @alive_ip ) {
			my @open_ports = $self->__check_ip($ip);
			if ( scalar( @open_ports ) == 0 ) {
				die ( "Don't have an open ports\n" );
			}
			else {
				$ip_port{$ip} = \@open_ports;
			}
		}
	}
	else {
		die( "Don't have alive ip\n" );
	}
	
	return 1;
}

sub __check_ip {
	my ( $self, $ip ) = @_;

	my $info = check_ports( $ip, PORT_TIMEOUT, \%ports );
	my @open_ports;
	for my $port ( keys %{$info->{udp}} ) {
#		if ( $info->{udp}{$port}{open} ) {
#			push ( @open_ports, $port );
#		}
		my $command = "nc -zu $ip $port";
		system($command);
		if ( $? ) {
			push ( @open_ports, $port );
		}
	}
	
	return @open_ports;
}

sub devices_info {
	my ( $self ) = @_;
	
	my $resp = undef;
	if ( scalar(keys %ip_port) != 0 ) {
		while ( my ($ip, $port) = each (%ip_port) ) {
			my %inet = (
						PeerAddr => $ip,
						PeerPort => $port, #always 5060
						Proto   => "udp"
					   );
			$resp = $self->__send_recv_sip( %inet );
		}
	}
	else {
		die( "Don't available ip and ports\n" );
	}

	return $resp;
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
	
	#add the regex to parse Model of phone and IP
	
	return $resp;
}

sub detect {
	my ( $self ) = @_;

	$self->__read_config();
	$self->__ping_detect();
	$self->__ports_detect();
	
	return %ip_port;
}

1;