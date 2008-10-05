#!perl

use strict;
use warnings;

use Cwd qw/abs_path/;
use File::Temp qw/tempfile/;

use Test::More tests => 4 * 2;

use App::Rgit;

my @expected = (
 ([ [ qw/^n ^g ^w ^b ^^/ ] ]) x 4
);

for (qw/version help daemon init/) {
 my ($fh, $filename) = tempfile(UNLINK => 1);
 my $exit = App::Rgit->new(
  git  => abs_path('t/bin/git'),
  root => 't',
  cmd  => $_,
  args => [ abs_path($filename), $_, qw/^n ^g ^w ^b ^^/ ]
 )->run;
 is($exit, 0, "each $_ returned 0");
 my @lines = sort split /\n/, do { local $/; <$fh> };
 my $res = [ map [ split /\|/, $_ ], @lines ];
 my $exp = [ [ $_, qw/^n ^g ^w ^b ^^/ ] ];
 is_deeply($res, $exp, "each $_ did the right thing");
}
