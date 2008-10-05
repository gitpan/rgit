package App::Rgit::Utils;

use strict;
use warnings;

use Carp qw/croak/;

=head1 NAME

App::Rgit::Utils - Miscellanous utilities for App::Rgit classes.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

Miscellanous utilities for L<App::Rgit> classes.

This is an internal module to L<rgit>.

=head1 FUNCTIONS

=head2 C<validate @method_args>

Sanitize arguments passed to methods.

=cut

sub validate {
 my $class = shift;
 croak 'Optional arguments must be passed as key/value pairs' if @_ % 2;
 $class = ref($class) || $class;
 $class = caller unless $class;
 return $class, @_;
}

=head1 EXPORT

C<validate> is only exported on request.

=cut

use base qw/Exporter/;

our @EXPORT         = ();
our %EXPORT_TAGS    = (
 funcs => [ qw/validate/ ]
);
our @EXPORT_OK      = map { @$_ } values %EXPORT_TAGS;
$EXPORT_TAGS{'all'} = [ @EXPORT_OK ];

=head1 SEE ALSO

L<rgit>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://profvince.com>.
   
You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-rgit at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=rgit>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rgit::Utils

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Utils
