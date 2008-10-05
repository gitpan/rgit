package App::Rgit::Config::Default;

use strict;
use warnings;

use File::Find qw/find/;

use base qw/App::Rgit::Config/;

use App::Rgit::Repository;

=head1 NAME

App::Rgit::Config::Default - Default App::Rgit configuration class.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 DESCRIPTION

Default L<App::Rgit> configuration class.

This is an internal class to L<rgit>.

=head1 METHODS

This class inherits from L<App::Rgit::Config>.

It implements :

=head2 C<repos>

=cut

sub repos {
 my $self = shift;
 return $self->{repos} if defined $self->{repos};
 my %repos;
 find {
  wanted => sub {
   return unless -d $_;
   return if $_ eq '.' or $_ eq '..';
   my $r = App::Rgit::Repository->new(dir => $File::Find::name);
   $repos{$r->repo} = $r if $r 
                         and not exists $repos{$r->repo};
  },
  follow => 1
 }, $self->root;
 $self->{repos} = [ values %repos ];
}

=head1 SEE ALSO

L<rgit>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://profvince.com>.

You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-rgit at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=rgit>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Rgit::Command::Default

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Command::Default
