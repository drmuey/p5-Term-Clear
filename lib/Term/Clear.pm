package Term::Clear;

use strict;
use warnings;

our $VERSION = '0.01';

our $_clear_str;    # out for testing; _ for don’t use this directly

sub clear {
    $_clear_str //= _get_clear_str();
    print $_clear_str;
}

sub _get_clear_str {
    eval { require Term::Cap };
    if ($@) {       # kind of gross but works a lot of places; patches welcome :)
        if ( $^O eq 'MSWin32' ) {
            return scalar(`cls`);
        }
        else {
            return scalar(`/usr/bin/clear`);
        }
    }

    # blatently stolen and slightly modified from PerlPowerTools v1.016 bin/clear
    my $OSPEED = 9600;
    eval {
        require POSIX;
        my $termios = POSIX::Termios->new();
        $termios->getattr;
        $OSPEED = $termios->getospeed;
    };

    my $terminal = Term::Cap->Tgetent( { OSPEED => $OSPEED } );
    my $cl = "";
    eval {
        $terminal->Trequire("cl");
        $cl = $terminal->Tputs( 'cl', 1 );
    };

    if ( $cl eq "" ) {    # kind of gross but works a lot of places; patches welcome :)
        if ( $^O eq 'MSWin32' ) {
            return scalar(`cls`);
        }
        else {
            return scalar(`/usr/bin/clear`);
        }
    }

    return $cl;
}

1;

__END__

=encoding utf-8

=head1 NAME

Term::Clear - `clear` the terminal via a perl function

=head1 VERSION

This document describes Term::Clear version 0.01

=head1 SYNOPSIS

    use Term::Clear ();

    Term::Clear::clear();

=head1 DESCRIPTION

Perl function to replace C<system("clear")>.

=head1 INTERFACE

=head2 clear()

Takes no arguments and clears the terminal screen in as portable way as possible.

=head1 DIAGNOSTICS

Throws no warnings or errors of its own.

=head1 CONFIGURATION AND ENVIRONMENT

Term::Clear requires no configuration files or environment variables.

=head1 DEPENDENCIES

It will use L<Term::Cap> and L<POSIX::Termios> if available.

=head1 INCOMPATIBILITIES AND LIMITATIONS

None reported.

=head1 BUGS AND FEATURES

Please report any bugs or feature requests (and a pull request for bonus points)
 through the issue tracker at L<https://github.com/drmuey/p5-Term-Clear/issues>.

=head1 AUTHOR

Daniel Muey  C<< <http://drmuey.com/cpan_contact.pl> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2020, Daniel Muey C<< <http://drmuey.com/cpan_contact.pl> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
