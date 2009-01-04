#!perl

use strict;
use warnings;

use Cwd qw/abs_path/;
use File::Temp qw/tempfile/;

use Test::More tests => 9 * 5;

use App::Rgit;

my @expected = (
 ([ [ qw/%n %g %w %b %%/ ] ]) x 5
);

local $ENV{GIT_DIR} = 't';
local $ENV{GIT_EXEC_PATH} = abs_path('t/bin/git');

for my $cmd (qw/daemon gui help init version/) {
 my ($fh, $filename) = tempfile(UNLINK => 1);
 my $ar = App::Rgit->new(
  git  => $ENV{GIT_EXEC_PATH},
  root => $ENV{GIT_DIR},
  cmd  => $cmd,
  args => [ abs_path($filename), $cmd, qw/%n %g %w %b %%/ ]
 );
 isnt($ar, undef, "once $cmd has a defined object");
 my $exit = $ar->run;
 is($exit, 0, "once $cmd returned 0");
 my @lines = sort split /\n/, do { local $/; <$fh> };
 is(@lines, 1, "once $cmd visited only one repo");
 my $r = [ split /\|/, defined $lines[0] ? $lines[0] : '' ];
 my $e = [ $cmd, qw/%n %g %w %b %%/ ];
 s/[\r\n]*$// for @$r;
 is($r->[$_], $e->[$_], "once $cmd argument $_ is ok")
  for 0 .. 5;
}
