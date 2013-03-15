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

sub test {
	my $self = shift;
	my $headers = $self->req->headers;
	my $cont = Dumper ($headers);
	$self->app()->log()->debug($self->app->dumper($headers));
}

1;
