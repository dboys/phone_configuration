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
	my $content = $ua->request( GET "http://$ip/".GET_TRAILER );
	return $content->content;
}

sub post {
	my ( $self, %args ) = @_;
	if ( scalar( keys( %args ) ) != 0 ){
		my $ua = LWP::UserAgent->new();
		$ua->request( POST "http://$ip/".POST_TRAILER, [%args] );
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

	my %id;
	while ( my( $key, $value ) = each( %args ) ) {
		if ( $content =~ /.*$key:<td><input[^>]*name="(\w+)".*/ ){
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