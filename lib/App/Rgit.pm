package App::Rgit;

use strict;
use warnings;

use Object::Tiny qw/config command/;

use App::Rgit::Command;
use App::Rgit::Config;
use App::Rgit::Utils qw/validate/;

=head1 NAME

App::Rgit - Backend that supports the rgit utility.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 DESCRIPTION

Backend that supports the L<rgit> utility.

This is an internal class to L<rgit>.

=head1 METHODS

=head2 C<< new root => $root, git => $git, cmd => $cmd, args => \@args >>

Creates a new L<App::Rgit> object that's bound to execute the command C<$cmd> on all the C<git> repositories inside C<$root> with C<@args> as arguments and C<$git> as C<git> executable.

=cut

sub new {
 my ($class, %args) = &validate;
 my $config = App::Rgit::Config->new(
  root => $args{root},
  git  => $args{git},
 );
 return unless defined $config;
 my $command = App::Rgit::Command->new(
  cmd  => $args{cmd},
  args => $args{args},
 );
 return unless defined $command;
 $class->SUPER::new(
  config  => $config,
  command => $command,
 );
}

=head2 C<run>

Actually run the commands.

=cut

sub run {
 my $self = shift;
 $self->command->run($self->config);
}

=head2 C<config>

=head2 C<command>

Accessors.

=head1 SEE ALSO

L<rgit>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://profvince.com>.
   
You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-rgit at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=rgit>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rgit

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit
