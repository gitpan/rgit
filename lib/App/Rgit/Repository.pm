package App::Rgit::Repository;

use strict;
use warnings;

use Cwd qw/cwd abs_path/;
use File::Spec::Functions qw/catdir splitdir abs2rel file_name_is_absolute/;
use POSIX qw/WIFEXITED WEXITSTATUS WIFSIGNALED WTERMSIG SIGINT SIGQUIT/;

use Object::Tiny qw/fake repo bare name work/;

use App::Rgit::Utils qw/validate/;

=head1 NAME

App::Rgit::Repository - Class representing a Git repository.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 DESCRIPTION

Class representing a Git repository.

This is an internal class to L<rgit>.

=head1 METHODS

=head2 C<< new dir => $dir [, fake => 1 ] >>

Creates a new repository starting from C<$dir>.
If the C<fake> option is passed, C<$dir> isn't checked to be a valid C<git> repository.

=cut

sub new {
 my ($class, %args) = &validate;
 my $dir = $args{dir};
 $dir = abs_path $dir if defined $dir and not file_name_is_absolute $dir;
 $dir = cwd       unless defined $dir;
 my ($repo, $bare, $name, $work);
 if ($args{fake}) {
  $repo = $work = $dir;
 } else { 
  my @tries = ($dir);
  my @chunks = splitdir $dir;
  my $last = pop @chunks;
  push @tries, "$dir.git" unless $last =~ /\.git$/;
  push @tries, catdir($dir, '.git') unless $last eq '.git';
  for (@tries) {
   if (-d $_ && -d "$_/refs" and -d "$_/objects" and -e "$_/HEAD") {
    $repo = $_;
    last;
   }
  }
  return unless defined $repo;
  @chunks = splitdir $repo;
  $last = pop @chunks;
  if ($last eq '.git') {
   $bare = 0;
   $name = $chunks[-1];
   $work = catdir @chunks;
  } else {
   $bare = 1;
   ($name) = $last =~ /(.*)\.git$/;
   $work = $repo;
  }
 }
 $class->SUPER::new(
  fake => !!$args{fake},
  repo => $repo,
  bare => $bare,
  name => $name,
  work => $work,
 );
}

=head2 C<chdir>

C<chdir> into the repository's directory.

=cut

sub chdir {
 my $self = shift;
 my $dir = $self->work;
 chdir $dir or do {
  warn "Couldn't chdir into $dir: $!";
  return;
 };
 return 1;
}

=head2 C<run $conf, @args>

Runs C<git @args> on the repository for the L<App::Rgit::Config> configuration C<$conf>.
When the repository isn't fake, the format substitutions applies to C<@args> elements.
Returns the exit code.

=cut

sub _abs2rel {
 my $a = &abs2rel;
 $a = $_[0] unless defined $a;
 $a;
}

my %escapes = (
 '^' => sub { '^' },
 'n' => sub { shift->name },
 'g' => sub { _abs2rel(shift->repo, shift->root) },
 'G' => sub { shift->repo },
 'w' => sub { _abs2rel(shift->work, shift->root) },
 'W' => sub { shift->work },
 'b' => sub {
  my ($self, $conf) = @_;
  _abs2rel($self->bare ? $self->repo : $self->work . '.git', $conf->root)
 },
 'B' => sub { $_[0]->bare ? $_[0]->repo : $_[0]->work . '.git' },
 'R' => sub { $_[1]->root },
);
my $e = quotemeta join '', keys %escapes;
$e = "[$e]";

sub run {
 my $self = shift;
 my $conf = shift;
 return unless $conf->isa('App::Rgit::Config');
 my @args = @_;
 unless ($self->fake) {
  s/\^($e)/$escapes{$1}->($self, $conf)/eg for @args;
 }
 {
  local $ENV{GIT_DIR} = $self->repo if exists $ENV{GIT_DIR};
  local $ENV{GIT_EXEC_PATH} = $conf->git if exists $ENV{GIT_EXEC_PATH};
  system { $conf->git } $conf->git, @args;
 }
 if ($? == -1) {
  $conf->crit("Failed to execute git: $!\n");
  return;
 }
 my $ret;
 $ret = WEXITSTATUS($?) if WIFEXITED($?);
 my $sig;
 if (WIFSIGNALED($?)) {
  $sig = WTERMSIG($?);
  $conf->warn("git died with signal $sig\n");
  if ($sig == SIGINT || $sig == SIGQUIT) {
   $conf->err("Aborting\n");
   exit $sig;
  }
 } elsif ($ret) {
  $conf->info("git returned $ret\n");
 }
 return wantarray ? ($ret, $sig) : $ret;
}

=head2 C<fake>

=head2 C<repo>

=head2 C<bare>

=head2 C<name>

=head2 C<work>

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

    perldoc App::Rgit::Repository

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of App::Rgit::Repository
