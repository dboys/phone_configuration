package PhoneConfiguration;
use Mojo::Base 'Mojolicious';

use DB::Schema;
use LAN::Settings;
use IPPhone::Settings;
use IPPhone::Constants;
use Data::Dumper;

has schema => sub {
	my %dbi_params = (
      quote_names => 1,
      mysql_enable_utf8 => 1,
    );
	my $schema = DB::Schema->connect('dbi:mysql:users:localhost:3306', 'root', 'denis1992', \%dbi_params);
	return $schema;
};

my $lan 	= undef;
my $phone	= undef;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  #alias $self->db
  $self->helper(db => sub { 
  	$self->app->schema 
  });
  
  $self->helper(phone => sub{
	my ( $self, %dst_ip ) = @_;
 	if( !defined($phone) ){
		$phone = IPPhone::Settings->new();
	}

	if ( %dst_ip ) {
		$phone->init_phone(%dst_ip);
	}
	
	return $phone;
  });
  
  $self->helper(lan => sub {
	my ( $self ) = @_;
  	if (!defined($lan)){
  		$lan = LAN::Settings->new();
		$lan->init();
  	}
  	
  	return $lan;
  });

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin('Parallol');
  $self->secret('*pOpRTm;M<;5?fk{');

  # Router
  my $r = $self->routes();

  # Normal route to controller
  $r->get('/')->to('phones#main');
  $r->post('/')->to('phones#main');
  
  $r->get('/settings')->to('phones#settings'); 
  $r->post('/settings')->to('phones#settings');

  $r->get('/users')->to('phones#users');
  $r->post('/users')->to('phones#users');
  
  $r->get('/test')->to('phones#test');
  $r->post('/test')->to('phones#test');
  
  $r->get('/update')->to('phones#update');
}

1;
