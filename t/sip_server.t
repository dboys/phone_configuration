#!/usr/bin/perl

use IO::Socket;
$server = IO::Socket::INET->new(LocalPort=>'5060',Proto=>"udp")
or die "Couldn't be a udp server: $@\n";

#write here your IP address
my $me = "192.168.1.2";

my $MAX_TO_READ = 2048;

sub header
{
  my $field = shift;
  my $headers = shift;
  my $s;
  $s=$headers;
  $s=~s/(^|\n)(?!$field)[^\n]*/$1/gs;
  $s=~s/(^\n*|\n*$)//gs;
  $s=~s/\n+/\n/gs;
  return $s
}

sub sender_ip
{
  my $headers = shift;
  my $contact = header("Contact",$headers);
  my $s;
  $s=$contact;
  $s=~s/^.*\@(\d+(\.\d+){3})\D.*$/$1/s;
  return $s;
}

%location=();

sub save
{
  my $headers = shift;
  my $contact = header("Contact",$headers);
  my $to = header("To",$headers);
  $to=~s/^.*<(.*)>.*$/$1/;
  $contact=~s/^.*<(.*)>.*$/$1/;
  $ip=sender_ip($headers);
  $location{$to}=$ip;
}

sub send_msg
{
  my $ip = shift;
  my $infoline = shift;
  my $headers = shift;
  my $body = shift;
  my $msg=$infoline."\r\n".$headers.$body;

  my $sock = new IO::Socket::INET (
    PeerAddr =>$ip, 
    PeerPort => '5060',
    Proto => 'udp');
  die "Could not create socket: $!\n" unless $sock;
  print $sock $msg;
  close($sock);
}

my $datagram;
my $infoline;
my $headers;
my $body;
my $ip;
my $uri;
my $msg;

while (my $user=$server->recv($datagram,$MAX_TO_READ))
{
  print "---\n";

  $infoline=$datagram;
  $headers=$datagram;
  $body=$datagram;
  $method=$datagram;

  $infoline=~s/^([^\r\n]*).*$/$1/s;
  $headers=~s/^[^\r\n]*\r?\n(.*(\r?\n){2}).*$/$1/s;
  $body=~s/^.*(\r?\n){2}(.*)$/$2/s;
  $method=~s/^([^ ]*) .*$/$1/s;

  print "Message: $infoline\n...\n";

  if($method eq "REGISTER")
  {
    print "$method\n";
    $ip=sender_ip($headers);
    save($headers);
    while(($key,$val)=each(%location))
    {
      print "$key => $val\n";
    }
    send_msg($ip,"SIP/2.0 200 OK",$headers,"");
  }

  if($method eq "INVITE")
  {
    print "$method\n";
    $uri=$datagram;
    $uri=~s/^INVITE +([^ ]*) .*$/$1/s;
    print "$uri => $location{$uri}\n";
    if($location{$uri} eq "")
    {
      print "Unknown URI $uri\n";
      $ip=sender_ip($headers);
      $msg=$headers;
      $msg=~s/\nContent-Length:[^\n]*\n/\n/s;
      $msg=~s/\nContent-Type:[^\n]*\n/\n/s;
      send_msg($ip,"SIP/2.0 500 Error",$msg,"");
    }
    else
    {
      print "Known URI $uri\n";

      $ip=sender_ip($headers);
      $msg=$headers;
      $msg=~s/\nContent-Length:[^\n]*\n/\n/s;
      $msg=~s/\nContent-Type:[^\n]*\n/\n/s;
      send_msg($ip,"SIP/2.0 100 Trying",$msg,"");

      #adding the Via header
      $msg=$headers;
      $msg=~s/(^|\n)(Via[^\n]*\n)/$1$2$2/s;
      $msg=~s/(^|\n)(Via: +[^ ]+ +)\d+(\.\d+){3}/$1$2$me/s;

      $ip=$location{$uri};
      print "Forwarding to $ip\n";
      send_msg($ip,$infoline,$msg,$body);
    }
  }

  if($method eq "SIP/2.0")
  {
    #handling replies of the transaction
    $msg=$headers;
    $msg=~s/(^|\n)Via:[^\n]*\n/$1/s;
    $ip=$msg;
    $ip=~s/.*(^|\n)(Via: +[^ ]+ +)(\d+(\.\d+){3}).*$/$3/s;
    send_msg($ip,$infoline,$msg,$body);
  }
}

close($server);