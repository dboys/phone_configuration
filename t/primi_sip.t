#!/usr/bin/perl

my $me = "192.168.73.199";  #Replace with your IP address


use IO::Socket;

sub send_msg
{
  my $ip = shift;
  my $msg= shift;

  my $sock = new IO::Socket::INET (
    LocalAddr => $me,
    LocalPort => '1234',
    PeerAddr => $ip, 
    PeerPort => '5060',
    Proto => 'udp',
    Reuse => 1);
  die "Could not create socket: $!\n" unless $sock;
  print $sock $msg;
  close($sock);
}

my $MAX_TO_READ = 2048;
my ($mb, $si, $sp, $method, $rb, $headers, $mline);
my ($ou, $tu, $ft, $fu, $du);
my ($ru, $sendhdr);

my %location=();

sub load_parameters
{
  $mline=$mb;
  $mline=~s/^([^\r\n]*).*$/$1/s;

  $headers=$mb;
  $headers=~s/^[^\r\n]*\r?\n(.*(\r?\n){2}).*$/$1/s;
  $sendhdr=$headers;

  $rb=$mb;
  $rb=~s/^.*(\r?\n){2}(.*)$/$2/s;

  $method=$mline;
  $method=~s/^([^ ]*) .*$/$1/s;

  if($method ne "SIP/2.0")
  {
    $ou=$mline;
    $ou=~s/^[^ ]+ +([^ ]*) .*$/$1/s;

  }
  else
  {
    $ou="";
  }
  $ru=$ou;
  $rU=$ru;
  $rU=~s/^sip:([^@]*)@.*/$1/;

  $du="";

  $tu=$headers;
  $tu=~s/.*(^|\n)To:[^\n<]*<([^>]*)>.*$/$2/s;

  $fu=$headers;
  $fu=~s/.*(^|\n)From:[^\n<]*<([^>]*)>.*$/$2/s;

  $ft=$headers;
  $ft=~s/.*(^|\n)From:[^\n<]*<[^>]*>[\n]*;tag=([^;\r\n]*).*/$2/s;
}

sub hdr_query
{
  my $field = shift;
  my $s=$headers;
  $s=~s/(^|\n)(?!$field)[^\n]*/$1/gs;
  $s=~s/^\n*//gs;
  $s=~s/\n+/\n/gs;
  return $s;
}

sub print_locations
{
  print '%'."location = (\r\n";
  while ( my ($key, $value) = each(%location) ) {
        print "  $key => $value,\n";
  }
  print ");\r\n";
}

sub save
{
  my $msg;
  $msg=
    "SIP/2.0 200 OK\r\n" .
    hdr_query("Via|From|To|CSeq|Call-ID|Contact") .
    "Server: PrimiSIP\r\n" .
    "Content-Length: 0\r\n" .
    "\r\n";
  $location{$tu}=$si;
  send_msg($si,$msg);
}

sub sl_send_reply
{
  my $code = shift;
  my $text = shift;
  my $msg=
    "SIP/2.0 $code $text\r\n" .
    hdr_query("Via|From|To|CSeq|Call-ID") .
    "Server: PrimiSIP\r\n" .
    "Content-Length: 0\r\n" .
    "\r\n";
  send_msg($si,$msg);
}

sub sl_reply_error
{
  sl_send_reply("500","Server error occured");
}

sub forward
{
  $sendhdr=~s/(^|\n)(Via[^\n]*\n)/$1$2$2/s;
  $sendhdr=~s/(^|\n)(Via: +[^ ]+ +)\d+(\.\d+){3}/$1$2$me/s;

  my $host;
  if($du eq "")
  {
    $host=$ru;
  }
  else
  {
    $host=$du;
  }
  $host=~s/^sip:(.*@)?([^;]*).*$/$2/;
  my $msg=$method." ".$ru." SIP/2.0\r\n".$sendhdr.$rb;
  send_msg($host,$msg);
}

sub rewritehost
{
  my $host=shift;
  $ru=~s/(sip:.*\@)([^;]*)(.*)/$1$host$3/;
}

sub topmost
{
  my $field = shift;
  my $s=$sendhdr;
  $s=~s/.*(?:^|(?:^|\n)(?!$field)[^\n]*\n)($field[^\r\n]*).*$/$1/s;
  return $s;
}

sub forward_reply
{
  $sendhdr=~s/(^|\n)Via:[^\n]*\n/$1/s;

  my $host=topmost("Via");
  $host=~s/^Via: +[^ ]+ +(\d+(?:\.\d+){3}).*$/$1/;
  my $msg=$mline."\r\n".$sendhdr.$rb;
  send_msg($host,$msg);
}

sub record_route
{
  my $rr="Record-Route: <sip:$me;lr=on;ftag=$ft>\r\n";
  if($sendhdr=~m/(^|\n)Record-Route/)
  {
    $sendhdr=~s/(^|\n)(Record-Route)/$1$rr$2/s;
  }
  else
  {
    $sendhdr=~s/(^|\n)(Via[^\n]*\n)(?!Via)/$1$2$rr/s;
  }
}

sub loose_route
{
  if($sendhdr=~m/(^|\n)Route/)
  {
    $sendhdr=~s/(^|\n)Route[^\n]*\n/$1/s;
    if($sendhdr=~m/(^|\n)Route/)
    {
      $du=topmost("Route");
      $du=~s/^Route:[^\n<]*<([^>]*)>.*$/$1/s;
    }
    return 1;
  }
  else
  {
    return !1;
  }
}

#====================
#=== User Section ===
#====================

sub route
{
  print "$mline from $si:$sp\n";

  if($method eq "REGISTER")
  {
    save();
    #print_locations();
  }

  if(loose_route())
  {
    print "Loose Route \$du=$du\n";
    forward();
    return;
  }

  if($method eq "INVITE")
  {
    record_route();
  }

  if($method=~m/(^INVITE$|^CANCEL$|^ACK$)/)
  {
    if($method eq "INVITE")
    {
      sl_send_reply("100","Giving a try");
    }
    if($method eq "CANCEL")
    {
      sl_send_reply("200","Cancelling");
    }
  
    if($location{$ou} ne "")
    {
      my $ip=$location{$ou};
      rewritehost($ip);
      forward();
    }
    elsif($rU=~m/^\+41215509.{3}/)
    {
      rewritehost("128.179.67.76");
      forward();
    }
    else
    {
      sl_reply_error();
    }

  }

}

sub onreply_route
{
  print "$mline from $si:$sp\n";
}

#===========================
#=== End of User Section ===
#===========================

sub listen_sip_port
{
  my $server = IO::Socket::INET->new(
    LocalAddr=>$me,
    LocalPort=>'5060',
    Proto=>"udp",
    Reuse=>1,
  ) or die "Cannot be a udp server: $@\n";

  while (my $user=$server->recv($mb,$MAX_TO_READ))
  {
    $si=$server->peerhost;
    $sp=$server->peerport;
    load_parameters();
    if($method ne "SIP/2.0")
    {
      route();
    }
    else
    {
      onreply_route();
      forward_reply();
    }
  }
  close($server);
}

listen_sip_port();