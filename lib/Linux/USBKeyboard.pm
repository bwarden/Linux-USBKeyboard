package Linux::USBKeyboard;
BEGIN {
  our $VERSION = 0.01;
}

use warnings;
use strict;
use Carp;

=head1 NAME

Linux::USBKeyboard - access devices pretending to be qwerty keyboards

=head1 SYNOPSIS

Use `lsusb` to discover the vendor+product id pair.

=head1 ABOUT

This module gives you access to usb barcode scanners, magstripe readers,
numpads and other "pretend I'm a keyboard" hardware.

It bypasses the keyboard driver so that your dvorak or international
keymap won't get in the way.  It also allows you to distinguish one
device from another, run as a daemon (not requiring X/console focus),
and other good things.

=head1 CAVEATS

This module assumes that you want the device to use a qwerty keymap.  In the
case of magstripes and barcode scanners, this is almost definitely the
case.  A tenkey pad won't matter.  For some kind of secondary usermode
keyboard (e.g. gaming, etc) maybe you actually want to be able to apply
a keymap?

I'm not sure how to let the main hid driver have the device back.  You
have to unplug it and plug it back in or run `libhid-detach-device`.

Patches welcome.

=head1 SETUP

You'll need a fairly modern Linux, Inline.pm, and libhid.

  cpan Inline
  aptitude install libhid-dev

You should setup udev to give the device `plugdev` group permissions or
whatever (rather than developing perl code as root.)

=cut

use Inline (
  C => Config => 
  CLEAN_AFTER_BUILD => 0,
  LIBS => '-lhid',
  NAME    => __PACKAGE__,
  #VERSION => __PACKAGE__->VERSION,
  #FORCE_BUILD => 1,
);

BEGIN {
my $base = __FILE__; $base =~ s#.pm$#/#;
Inline->import(C => "$base/functions.c");
}

=head1 Constructor


=head2 new

  my $kb = Linux::USBKeyboard->new($vendor_id, $product_id);

=cut

sub new {
  my $class = shift;
  my ($vendor_id, $product_id) = @_;

  my $self = $class->create($vendor_id, $product_id, 0);
  return($self);
} # end subroutine new definition
########################################################################


=head2 open

Get a filehandle to a forked process.

  my $fh = Linux::USBKeyboard->open($vendor_id, $product_id);

=cut

sub open {
  my $package = shift;
  my $fh = Linux::USBKeyboard::FileHandle->new;
  my $pid = open($fh, '-|');
  unless($pid) {
    undef($fh); # destroy that
    my $kb = Linux::USBKeyboard->new(@_);
    local $| = 1;
    $SIG{HUP} = sub { exit; };
    while(1) {
      my $c = $kb->char;
      ($c eq "\0") and next;
      print $c if(length($c));
    }
    exit;
  }
  $fh->init(pid => $pid);
  return($fh);
} # end subroutine open definition
########################################################################

=head1 Methods

=head2 char

Returns the character (with shift bit applied.)

  print $k->char;

=cut

*char = *_char;

=head2 keycode

Get the raw keycode.  This allows access to things like numlock, but
also returns keyup events (0).  Returns -1 if there was no event.

This method is somewhat unreliable in that it can't tell you when a key
was pressed while another key is being held down.  Consider it alpha.

=cut

*keycode = *_keycode;


{
package Linux::USBKeyboard::FileHandle;

use base 'IO::Handle';

my %handles;
sub init {
  my $self = shift;
  $handles{$self} = {@_};
}
sub pid {
  my $self = shift;
  return($handles{$self}{pid});
}
sub DESTROY {
  my $self = shift;
  my $data = delete($handles{$self}) or return;
  kill('HUP', $data->{pid});
}
} # end package


=head1 AUTHOR

Eric Wilhelm @ <ewilhelm at cpan dot org>

http://scratchcomputing.com/

=head1 BUGS

If you found this module on CPAN, please report any bugs or feature
requests through the web interface at L<http://rt.cpan.org>.  I will be
notified, and then you'll automatically be notified of progress on your
bug as I make changes.

If you pulled this development version from my /svn/, please contact me
directly.

=head1 COPYRIGHT

Copyright (C) 2007 Eric L. Wilhelm, All Rights Reserved.

=head1 NO WARRANTY

Absolutely, positively NO WARRANTY, neither express or implied, is
offered with this software.  You use this software at your own risk.  In
case of loss, no person or entity owes you anything whatsoever.  You
have been warned.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# vi:ts=2:sw=2:et:sta
1;
