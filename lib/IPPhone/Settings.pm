package IPPhone::Settings;

use v5.14;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;
use Params::Validate qw(:all);
use Class::InsideOut qw(:all);
use Data::Dumper;


use constant {
	GET_TRAILER 	=> "admin/advanced",
	POST_TRAILER	=> "admin/asipura.spa"
};

readonly dst_ip => my %dst_ip;

sub init {
	my $self = shift;
	my %args = validate( @_, {
                   &IPPhone::Constants::DST_IP => { type => SCALAR }
               }
    );
	$self->set_dst_ip($args{&IPPhone::Constants::DST_IP});
	
	return 1;
}

sub set_dst_ip {
	$dst_ip{ id $_[0] } = $_[1];
}

sub _get_ {
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

sub _post_ {
	my $self 	= shift;
	
    my ($dst_ip, $post_args) = validate_pos( @_,
    								{ type => SCALAR },
                   					{ type => HASHREF }
    );
               		   
	my $ua = LWP::UserAgent->new();

	eval {
		$ua->request( POST "http://$dst_ip/".POST_TRAILER, [%$post_args] );
	};
	if ( $! ) {
		die( $! );
	}

	return 1;
}

sub regex_policy {
	my $self = shift;
	my ($content,$args) = validate_pos( @_,
               						{ type => SCALAR  },
		      						{ type => HASHREF }
    );

	my %html_id;
	while ( my( $key, $value ) = each( %$args ) ) {
		#Warn: static regex special to parse select and input html fields
		if ( $content =~ /.*>$key:<td[^>]*><[input?][^>]*name="(\w+)".*/ ){
			$html_id{ $1 } = $value;
		}
	}
	
	return %html_id;
}

sub update {
    my $self = shift;
	my %args = validate ( @_, {
                   		&IPPhone::Constants::PROXY 		=> { type => SCALAR },
                   		&IPPhone::Constants::USER_ID 	=> { type => SCALAR },
                   		&IPPhone::Constants::PASSWD 	=> { type => SCALAR }
               }
    );
	
	my $html = $self->_get_( $self->dst_ip() );
	my %html_id = $self->regex_policy( $html, \%args );
	$self->_post_( $self->dst_ip(), \%html_id );
	
	return 1;
}

our $AUTOLOAD;
sub AUTOLOAD {
  my ($self) = @_;
  die ("Doesn't found $AUTOLOAD");
}

1;