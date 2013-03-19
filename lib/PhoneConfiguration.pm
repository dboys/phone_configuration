package PhoneConfiguration;
use Mojo::Base 'Mojolicious';

use DB::Schema;

has schema => sub {
	my %dbi_params = (
      quote_names => 1,
      mysql_enable_utf8 => 1,
    );
	my $schema = DB::Schema->connect('dbi:mysql:users:localhost:3306', 'root', 'denis1992', \%dbi_params);
	return $schema;
};

# This method will run once at server start
sub startup {
  my $self = shift;
  
  #alias $self->db
  $self->helper(db => sub { $self->app->schema });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->secret('*pOpRTm;M<;5?fk{');

  # Router
  my $r = $self->routes();

  # Normal route to controller
  $r->get('/')->to('phones#main');
  
  $r->get('/ajax')->to('phones#ajax');
  
  $r->post('/')->to('phones#update');
}

1;
