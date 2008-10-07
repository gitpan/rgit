package App::Rgit::Config;

use strict;
use warnings;

use Carp qw/croak/;
use Cwd qw/abs_path/;
use File::Spec::Functions qw/file_name_is_absolute/;

use Object::Tiny qw/root git cwd_repo/;

use App::Rgit::Repository;
use App::Rgit::Utils qw/validate/;

=head1 NAME

App::Rgit::Config - Base class for App::Rgit configurations.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 DESCRIPTION

Base class for L<App::Rgit> configurations.

This is an internal class to L<rgit>.

=head1 METHODS

=head2 C<< new root => $root, git => $git >>

Creates a new configuration object based on the root directory C<$root> and using C<$git> as F<git> executable.

=cut

sub new {
 my ($class, %args) = &validate;
 my $root = $args{root};
 return unless defined $root and -d $root;
 $root = abs_path $root unless file_name_is_absolute $root;
 return unless defined $args{git} and -x $args{git};
 my $conf = 'App::Rgit::Config::Default';
 eval "require $conf; 1" or croak "Couldn't load $conf: $@";
 my $r = App::Rgit::Repository->new(fake => 1);
 return unless defined $r;
 $conf->SUPER::new(
  root     => $root,
  git      => $args{git},
  cwd_repo => $r,
 );
}

=head2 C<root>

=head2 C<git>

=head2 C<repos>

=head2 C<cwd_repo>

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

    perldoc App::Rgit::Config

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Config
