package IPPhone::Settings;

BEGIN {
	push ( @INC, "../" );
}

use v5.14;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use Scalar::Util qw(refaddr);
use Params::Validate qw(:all);

use IPPhone::Constants;


use constant {
	GET_TRAILER 	=> "admin/advanced",
	POST_TRAILER	=> "admin/asipura.spa"
};

our %dst_ip;

sub new {
	my ( $class ) = @_;
	my $self = bless ( {}, $class );
	return $self;
}

sub init {
	my $self = shift;
	my %args = validate(
               @_, {
                   $IPPhone::Constants::DST_IP => { type => SCALAR }
               }
           );
	$dst_ip{refaddr $self} = $args{$IPPhone::Constants::DST_IP};
	
	return 1;
}

sub __get {
	my $self = shift;
	my $dst_ip = validate_pos( @_,
               		{ type => SCALAR }
    );

	my $ua = LWP::UserAgent->new();
	my $content = undef;
	eval {
		$content = $ua->request( GET "http://$dst_ip/".GET_TRAILER );
	};
	if ( $! ) {
		die( $! );
	}
	
	return $content->content;
}

sub __post {
	my $self = shift;
	my $dst_ip = validate_pos( @_,
               		{ type => SCALAR }
    );
    my %post_args = validate( @_, {
                   			$IPPhone::Constants::PROXY 		=> { type => SCALAR },
                   			$IPPhone::Constants::USER_ID 	=> { type => SCALAR },
                   			$IPPhone::Constants::PASSWD 	=> { type => SCALAR }
               			 }
               		   );
               		   
	my $ua = LWP::UserAgent->new();

	eval {
		$ua->request( POST "http://$dst_ip/".POST_TRAILER, [%post_args] );
	};
	if ( $! ) {
		die( $! );
	}

	return 1;
}

sub __regex_policy {
	my $self = shift;
	my $content = validate_pos( @_,
               		{ type => SCALAR }
    );
	my %args = validate ( @_, {
                   			$IPPhone::Constants::PROXY 		=> { type => SCALAR },
                   			$IPPhone::Constants::USER_ID 	=> { type => SCALAR },
                   			$IPPhone::Constants::PASSWD 	=> { type => SCALAR }
               			 }
               			);
	if ( !defined( $content ) || scalar(keys( %args )) == 0 ){
		die( "Not all agruments found!\n" ); 	
	}

	my %id;
	while ( my( $key, $value ) = each( %args ) ) {
		#Warn: static regex special to parse select and input html fields
		if ( $content =~ /.*>$key:<td[^>]*><[input?][^>]*name="(\w+)".*/ ){
			$id{ $1 } = $value;
		}
	}
	
	return %id;
}

sub update {
	my ( $self, %args ) = @_;

	my $html = $self->__get();
	my %conf = $self->__regex_policy( $html, %args );
	$self->__post( %conf );
	
	return 1;
}

1;