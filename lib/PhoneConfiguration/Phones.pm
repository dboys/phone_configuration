package PhoneConfiguration::Phones;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub main {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
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

1;
