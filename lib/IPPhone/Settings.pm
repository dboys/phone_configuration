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

private dst_ip 		=> my %dst_ip;
private html_id		=> my %html_id;
private post_param	=> my %post_param;

sub set_html_id {
	$html_id{id $_[0]} = $_[1];
}

sub set_dst_ip {
	$dst_ip{id $_[0]} = $_[1];
}

sub dst_ip {
	return $dst_ip{id $_[0]};
}

sub html_id {
	return $html_id{id $_[0]};
}

sub set_post_param {
	$post_param{id $_[0]} = $_[1];
}

sub post_param {
	return $post_param{id $_[0]};
}

sub proxy {
	my $self = shift;
	my $html_id = $self->html_id();
	if (exists($html_id->{&IPPhone::Constants::PROXY})) {
		return $html_id->{&IPPhone::Constants::PROXY};
	}
	else {
		die(&IPPhone::Constants::PROXY." not exists");
	}
}

sub login {
	my $self = shift;
	my $html_id = $self->html_id();
	if (exists($html_id->{&IPPhone::Constants::USER_ID})) {
		return $html_id->{&IPPhone::Constants::USER_ID};
	}
	else {
		die(&IPPhone::Constants::USER_ID." not exists");
	}
}

sub passwd {
	my $self = shift;
	
	my $html_id = $self->html_id();
	
	print Dumper $html_id;
	
	if (exists($html_id->{&IPPhone::Constants::PASSWD})) {
		return $html_id->{&IPPhone::Constants::PASSWD};
	}
	else {
		die(&IPPhone::Constants::PASSWD." not exists");
	}
}

sub _get_ {
	my $self = shift;
	my $dst_ip = validate_pos( @_,
               		{ type => SCALAR }
    );

	say ("dst ip2".$dst_ip->[0]);
	my $ua = LWP::UserAgent->new();
	my $content = undef;
	eval {
		$content = $ua->request( GET "http://$dst_ip->[0]/".GET_TRAILER );
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
			$html_id{ $key }	= $1;	 		
		}
	}
	
	return %html_id;
}

sub init_phone {
	my $self = shift;
	
	my %args = validate ( @_, {
						&IPPhone::Constants::DST_IP 	=> { type => SCALAR }
               }
    );
	
	$self->set_dst_ip($args{&IPPhone::Constants::DST_IP});

	my $html = $self->_get_( $self->dst_ip() );
	
	my %const =     (
						&IPPhone::Constants::PROXY 		=> &IPPhone::Constants::NULL,
                   		&IPPhone::Constants::USER_ID 	=> &IPPhone::Constants::NULL,
                   		&IPPhone::Constants::PASSWD 	=> &IPPhone::Constants::NULL
					);
	my %html_id = $self->regex_policy( $html, \%const );
	
	$self->set_html_id(\%html_id);
	
	return 1;
}

sub init_post_param {
	my $self = shift;
	my %args = validate_pos( @_,
						&IPPhone::Constants::DST_IP 	=> { type => SCALAR },
						&IPPhone::Constants::PROXY		=> { type => SCALAR },
						&IPPhone::Constants::USER_ID 	=> { type => SCALAR },
						&IPPhone::Constants::PASSWD		=> { type => SCALAR }
    );
	
	print Dumper %args;
	
	my %post =	( 	$html_id{&IPPhone::Constants::USER_ID}	=> $args{&IPPhone::Constants::USER_ID},
					$html_id{&IPPhone::Constants::PROXY}	=> $args{&IPPhone::Constants::PROXY},
					$html_id{&IPPhone::Constants::PASSWD}	=> $args{&IPPhone::Constants::PASSWD}
				);
	
	print Dumper %post;
	
	$self->set_post_param(\%post);
}

sub update {
    my ($self,$dst_ip,$post_param) = @_;
#	my $post_param = validate_pos( @_,
#						{ type => HASHREF }
#    );

	$self->_post_( $dst_ip, $post_param );
	
	return 1;
}

our $AUTOLOAD;
sub AUTOLOAD {
  my ($self) = @_;
  die ("Doesn't found $AUTOLOAD");
}

1;