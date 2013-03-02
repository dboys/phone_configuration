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
           	3306      => {}
            }
        );

our %ip_port;

sub new {
	my ( $class ) = @_;
	my $self = bless ( {}, $class );
	return $self;
}

sub net_addr {
	my ( $self ) = @_;
	my %net = %{$config{refaddr $self}};
	if ( exists( $net{&SECTION_NET}{&NET_ADDR} ) ) {
		return $net{&SECTION_NET}{&NET_ADDR};
	}
	else {
		die ( "Couldn't return network address \n" );
	}
}

sub read_config {
	my ( $self ) = @_;
	my $iniconf = Config::IniFiles->new( -file => CONFIG_FILE )
            						or die(@Config::IniFiles::errors);
    $config{refaddr $self} = $iniconf->{v};
    return 1;
}

sub ping_detect {
	my ( $self ) = @_;
	
	my $netmask = $self->net_addr();
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

sub ports_detect {
	my ( $self ) = @_;
	if ( scalar( @alive_ip ) != 0 ) {
		foreach my $ip ( @alive_ip ) {
			my @open_ports = $self->check_ip($ip);
			if ( scalar( @open_ports ) == 0 ) {
				die ( "Don't have an open ports\n" );
			}
			else {
				$ip_port{$ip} = \@open_ports;
			}
		}
	}
	else {
		die("Don't have alive ip\n");
	}
	
	return 1;
}

sub check_ip {
	my ( $self, $ip ) = @_;

	my $info = check_ports( $ip, PORT_TIMEOUT, \%ports );
	my @open_ports;
	for my $port ( keys %{$info->{udp}} ) {
#		if ( $info->{udp}{$port}{open} ) {
#			push ( @open_ports, $port );
#		}
		my $command = "nc -zu $ip $port";
		system($command);
		print ("check ip $?");
		if ( $? ) {
			push ( @open_ports, $port );
		}
	}
	
	return @open_ports;
}

sub detect {
	my ( $self ) = @_;

	$self->read_config();
	$self->ping_detect();
	$self->ports_detect();
	
	return %ip_port;
}

1;