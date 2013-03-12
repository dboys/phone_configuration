package PhoneConfiguration;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->secret('*pOpRTm;M<;5?fk{');

  # Router
  my $r = $self->routes();

  # Normal route to controller
  $r->get('/')->to('phones#main');
  
  $r->get('/ajax')->to('phones#ajax');
  
  $r->post('/')->to('phones#test');

}

1;
