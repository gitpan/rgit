package App::Rgit::Command::Once;

use strict;
use warnings;

use base qw/App::Rgit::Command/;

=head1 NAME

App::Rgit::Command::Once - Class for commands to execute only once.

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 DESCRIPTION

Class for commands to execute only once.

This is an internal class to L<rgit>.

=head1 METHODS

This class inherits from L<App::Rgit::Command>.

It implements :

=head2 C<run>

=cut

sub run {
 my ($self, $conf) = @_;

 $conf->cwd_repo->run($conf, @{$self->args});
}

=head1 SEE ALSO

L<rgit>.

L<App::Rgit::Command>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://profvince.com>.

You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-rgit at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=rgit>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rgit::Command::Once

=head1 COPYRIGHT & LICENSE

Copyright 2008,2009,2010 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Command::Once
