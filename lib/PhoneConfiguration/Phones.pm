package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;

# This action will render a template
sub main {
  	my $self = shift;

  	$self->stash( users => [ $self->db->resultset('User')->all() ] );
}

sub ajax {
    my $self = shift;

    my $header = $self->req->headers->header('X-Requested-With');

    # AJAX request
    if ($header && $header eq 'XMLHttpRequest') {
        $self->render_json({answer => "$ENV{MOJO_HOME}"});
    }

    # Normal request
    else {
        $self->render(answer => 'Hello from Mojolicious!');
    }
}

sub update {
	my $self = shift;
	my $headers = $self->req->headers();

	my $new_passwd 	= $headers->{'headers'}->{'x-passwd'}->[0]->[0];
	my $new_name 	= $headers->{'headers'}->{'x-name'}->[0]->[0];
	my $new_ip 		= $headers->{'headers'}->{'x-ip'}->[0]->[0];
	
	$self->app()->log()->debug(	'new ip= '.$new_ip."\n".
								'new name= '.$new_name."\n".
								'new passwd= '.$new_passwd."\n");
}

1;
