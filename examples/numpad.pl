#!/usr/bin/perl

use warnings;
use strict;

use lib 'lib';

use Linux::USBKeyboard;

my $k = Linux::USBKeyboard->create(0x0e6a, 0x0001, 0);
if(0) {
  print $k->_char, ".1\n";
  print $k->_char, ".2\n";
  print $k->_char, ".3\n";
  print $k->_char, ".4\n";
  print $k->_char, ".5\n";
  print $k->_char, ".6\n";
}
else {
  local $| = 1;
  while(1) {
    print $k->_char;
  }
}

# vim:ts=2:sw=2:et:sta
