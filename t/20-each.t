#!perl

use strict;
use warnings;

use Cwd qw/cwd abs_path/;
use File::Spec::Functions qw/catdir/;
use File::Temp qw/tempfile/;

use Test::More tests => 3 * 2;

use App::Rgit;

my $n = 3;

my @expected = (
 undef,
 [ [ 'a', 'a/.git', 'a',     'a.git' ] ],
 [ [ 'b', 'b.git',  'b.git', 'b.git' ] ],
 [
   [ 'c', 'x/c/.git', 'x/c',     'x/c.git' ],
   [ 'd', 'y/d.git',  'y/d.git', 'y/d.git' ],
 ],
);

my $cwd = cwd;
my @repos = (undef, 
             map { catdir $cwd, 't', 'repos', sprintf("%02d", $_) } 1 .. $n);
for my $i (1 .. $n) {
 for my $a (@{$expected[$i]}) {
  $a->[$_+3] = catdir($repos[$i], $a->[$_]) for 1 .. 3;
  push @$a, $repos[$i], '^';
 }
}

for (1 .. $n) {
 my ($fh, $filename) = tempfile(UNLINK => 1);
 my $exit = App::Rgit->new(
  git  => abs_path('t/bin/git'),
  root => $repos[$_],
  cmd  => 'commit',
  args => [ abs_path($filename), 'commit', qw/^n ^g ^w ^b ^G ^W ^B ^R ^^/ ]
 )->run;
 is($exit, 0, "each $_ returned 0");
 my @lines = sort split /\n/, do { local $/; <$fh> };
 my $res = [ map [ split /\|/, $_ ], @lines ];
 my $exp = [ map [ 'commit', @$_ ], @{$expected[$_]} ];
 is_deeply($res, $exp, "each $_ did the right thing");
}
