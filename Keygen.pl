#!/usr/bin/perl

use strict;
use warnings;

my $login = "K4Fr";

# Nag screen patch:
# 00001CAB-00001CAF: 68 69 14 40 00
# 00001CAB-00001CAF: 90 90 90 90 90

sub swap {
    my $key = shift;
    my @temp = (4, 2, 6, 4, -2, -5, 3, -6, -2, -4);
    foreach my $i (0..(length($key) - 1)) {
    if (ord(substr($key, $i, 1)) <= 0x39 && ord(substr($key, $i, 1)) >= 0x30) {
        $key = substr($key, 0, $i) . ($temp[substr($key, $i, 1)] + substr($key, $i, 1)) . substr($key, $i+1, 32-($i+1));
    }
    }
    return $key;
}

sub sumlogin {
    my $login = shift;
    die if length($login) > 16;
    my $alphanum = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    my $temp = -1;
    my $mysum = 0;
    my $j = 0;
    my @serial = ('') x 32;
    foreach my $i (0..(length($login) - 1)) {
    $mysum = ($mysum + ($i * (int($mysum / ($i + 8)) + $i * ord(substr($login, $i, 1))))) & 0xffffff;
    $j = ($j + ord(substr($login, $i, 1))) & 0xffff;
    }
    $mysum *= $mysum if $mysum < 1000;
    $j ^= length($login);
    $j = int((15 * $j + 1) / 16) & 0xffff;
    while ($j >= 36) {
    $j -= 7;
    }

    my $t1;
    my $t2;
    foreach my $k (0..31) {
    if (!$k || $k % 7) {
        if (0x21 % ($k+2) && $k % 4) {
        $t1 = (int($mysum / (35 - $k)) + 1337) & 0xffff;
        $t1 = int($mysum / $t1) & 0xffff;
        $t1 = ($t1 % ($k + 1)) & 0xffff;
        $t1 = int((15 * $t1 + 1) / (int($j / 2) + 1)) & 0xffff;
        $t1 = ($t1 * 2) & 0xffff if ($temp != -1 && $temp == $t1);
        while ($t1 > 36) {
            $t1 -= 2;
        }
        while ($t1 < 0) {
            $t1 = ($t1 + 2) & 0xffff;
        }
        $temp = $t1;
        $serial[$k] = substr($alphanum, $t1, 1);
        }
        else {
        $t2 = (int($mysum / ($k + $j)) + 1337) & 0xffff;
        $t2 = ($mysum / $t2) & 0xffff;
        $t2 = ($t2 ^ ($k + 1)) & 0xffff;
        $t2 = int((15 * $t2 + 1) / (int($j / 2) + 1)) & 0xffff;
        $serial[$k] = uc($serial[$k]);
        $t2 = ($t2 * 2) & 0xffff if ($temp != -1 && $temp == $t2);
        while ($t2 >= 34) {
            $t2 -= 2;
        }
        while ($t2 < 0) {
            $t2 = ($t2 + 2) & 0xffff;
        }
        $temp = $t2;
        $serial[$k] = substr($alphanum, $t2, 1);
        }
    }
    else {
        $serial[$k] = "-";
    }
    }
    return swap(swap(join '', @serial));
}

print $login . "\n";
print sumlogin($login) . "\n"; 
