package App::Rgit::Command;

use strict;
use warnings;

use Carp qw/croak/;

use Object::Tiny qw/cmd args policy/;

use App::Rgit::Utils qw/validate :codes/;

=head1 NAME

App::Rgit::Command - Base class for App::Rgit commands.

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 DESCRIPTION

Base class for L<App::Rgit> commands.

This is an internal class to L<rgit>.

=head1 METHODS

=head2 C<< new cmd => $cmd, args => \@args >>

Creates a new command object for C<$cmd> that is bound to be called with arguments C<@args>.

=cut

my %commands;
__PACKAGE__->action($_ => 'Once') for qw/daemon gui help init version/, ' ';

sub new {
 my ($class, %args) = &validate;
 my $cmd = $args{cmd};
 $cmd = ' ' unless defined $cmd;
 my $action = $class->action($cmd);
 if ($class eq __PACKAGE__) {
  $class = $action;
 } else {
  croak "Command $cmd should be executed as a $action"
                               unless $class->isa($action);
 }
 eval "require $action; 1" or croak "Couldn't load $action: $@";
 $class->SUPER::new(
  cmd    => $cmd,
  args   => $args{args} || [ ],
  policy => $args{policy},
 );
}

=head2 C<< action $cmd [ => $pkg ] >>

If C<$pkg> is supplied, handles command C<$cmd> with C<$pkg> objects.
Otherwise, returns the current class for C<$cmd>.

=cut

sub action {
 my ($self, $cmd, $pkg) = @_;
 if (not defined $cmd) {
  return unless defined $self and ref $self and $self->isa(__PACKAGE__);
  $cmd = $self->cmd;
 }
 unless (defined $pkg) {
  return __PACKAGE__ . '::Each' unless defined $commands{$cmd};
  return $commands{$cmd}
 }
 $pkg = __PACKAGE__ . '::' . $pkg unless $pkg =~ /:/;
 $commands{$cmd} = $pkg;
}

=head2 C<report $conf, $repo, $status>

Reports that the execution of the command in C<$repo> exited with C<$status> to the current command's policy.
Returns what the policy callback returned, which should be one of the policy codes listed in C<App::Rgit::Utils>.

=cut

sub report {
 my ($self) = @_;
 my $cb = $self->policy;
 return $_[3] ? LAST : NEXT unless $cb;
 my $code = $cb->(@_);
 return defined $code ? $code : NEXT;
}

=head2 C<cmd>

=head2 C<args>

=head2 C<policy>

Accessors.

=head2 C<run $conf>

Runs the command with a L<App::Rgit::Config> configuration object.
Handles back the code to return to the system and the last policy.
Implemented in subclasses.

=head1 SEE ALSO

L<rgit>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://profvince.com>.
   
You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-rgit at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=rgit>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rgit::Command

=head1 COPYRIGHT & LICENSE

Copyright 2008-2009 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Command
