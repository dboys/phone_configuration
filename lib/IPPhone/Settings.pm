package IPPhone::Settings;

BEGIN {
	push ( @INC, "../" );
}

use v5.14;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use IPPhone::Constants;

use constant {
	GET_TRAILER 	=> "admin/advanced",
	POST_TRAILER	=> "admin/asipura.spa"
};

#install Class::InsideOut

our $ip = undef;

sub new {
	my ( $class ) = @_;
	my $self = bless ( {}, $class );
	return $self;
}

sub init {
	my ( $self, %args ) = @_;
	if ( scalar( keys( %args ) ) != 0 ){
		$ip = $args{$IPPhone::Constants::IP};
	}
	else {
		die( "Not found IP address!\n" );
	}
}

sub get {
	my ( $self ) = @_;

	my $ua = LWP::UserAgent->new();
	my $content = undef;
	eval {
		$content = $ua->request( GET "http://$ip/".GET_TRAILER );
	};
	if ( $! ) {
		die( $! );
	}
	
	return $content->content;
}

sub post {
	my ( $self, %args ) = @_;
	if ( scalar( keys( %args ) ) != 0 ){
		my $ua = LWP::UserAgent->new();

		eval {
			$ua->request( POST "http://$ip/".POST_TRAILER, [%args] );
		};
		if ( $! ) {
			die( $! );
		} 
	}
	else {
		die( "Not found any POST agruments!\n" );
	}
}

sub regex_policy {
	my ( $self, $content, %args ) = @_;
	if ( !defined( $content ) || scalar(keys( %args )) == 0 ){
		die( "Not all agruments found!\n" ); 	
	}

	#need DHCP->no when add static ip
	if ( exists( $args{$IPPhone::Constants::IP} ) ){
		$args{$IPPhone::Constants::DHCP} = 0;
	}

	my %id;
	while ( my( $key, $value ) = each( %args ) ) {
		#Warn: static regex special to parse select and input html fields
		if ( $content =~ /.*$key:<td[^>]*><[select|input][^>]*name="(\w+)".*/ ){
			$id{ $1 } = $value;
		}
	}
	
	return %id;
}

sub UPDATE {
	my ( $self, %args ) = @_;
	my $html = $self->get();
	my %conf = $self->regex_policy( $html, %args );
	$self->post( %conf );
}

1;