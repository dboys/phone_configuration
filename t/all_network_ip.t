#!/usr/bin/env perl
# pinger - простой сканер IP-адресов.
use strict;
use warnings;
use v5.10;

use Net::Ping;
use Net::Netmask;

# Если в сети возможны задержки, это значение нужно увеличить, чтобы не было
# ложных срабатываний. Общее время работы сканеры тоже увеличится.
use constant PING_TIMEOUT   => 0.1;

# Максимальное количество IP-адресов в подсети
use constant MAX_BLOCK_SIZE => 2 ** 16;

my $netmask = shift or die "Usage: $0 NETMASK\n";

my $block   = Net::Netmask->new2($netmask)
    or die "$netmask is not a valid netmask";

# Запрещаем блоки слишком больших размеров
my $block_size = $block->size;
if ($block_size > MAX_BLOCK_SIZE) {
    die "Too many IP addresses: $block_size, max is " . MAX_BLOCK_SIZE . "\n";
}

say "Querying $block_size IP addresses";

my $pinger = Net::Ping->new;
for my $ip ($block->enumerate) {

    if ($pinger->ping($ip, PING_TIMEOUT)) {
        say "$ip is alive";
    } else {
        say "$ip is dead";
    }
}
$pinger->close;