#!perl

use strict;
use warnings;

use Cwd qw/cwd abs_path/;
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/tempfile tempdir/;

use Test::More tests => 2 + 3 * 1;

use App::Rgit;

sub build {
 my ($tree, $prefix) = @_;
 my @ret;
 my $r = delete $tree->{_};
 while (my ($d, $v) = each %$tree) {
  if (ref $v) {
   my $dir = catdir $prefix, $d;
   mkdir $dir or die "mkdir($dir): $!";
   my @r = build($v, $dir);
   push @ret, map [
               $_->[0],
               ref eq 'main' ? @{$_}[1 .. 3]
                             : map { catdir($d, $_) } @{$_}[1 .. 3]
              ], @r unless $r;
  } else {
   my $file = catfile($prefix, $d);
   open my $fh, '>', $file or die "open($file): $!";
   print $fh $v;
   close $fh;
  }
 }
 return $r ? bless $r, 'main' : @ret;
}

my $repogit = {
 HEAD    => 1,
 refs    => { dummy => 1 },
 objects => { dummy => 1 },
};

sub repo {
 my ($n, $bare) = @_;
 return $bare ? [ $n, "$n.git",           "$n.git", "$n.git" ]
              : [ $n, catdir($n, '.git'), $n,       "$n.git" ]
}

my $tmpdir = tempdir(CLEANUP => 1);
my $cwd = cwd;
chdir $tmpdir or die "chdir($tmpdir): $!";
my @expected = sort { $a->[0] cmp $b->[0] } build({
 x => {
  a => {
   _ => repo('a', 0),
   '.git' => $repogit
  },
  z => {
   '.git' => {
    refs => { dummy => 1 },
   }
  }
 },
 y => {
  'b.git' => {
   _ => repo('b', 1),
   %$repogit
  },
  't' => {
   't.git' => {
    refs => { dummy => 1 },
    objects => { dummy => 1 },
   }
  }
 },
 c => {
  _ => repo('c', 0),
  '.git' => $repogit
 }
}, '.');
chdir $cwd or die "chdir($cwd): $!";

is(@expected, 3, 'only three valid git repos');
is(grep({ ref eq 'ARRAY' } @expected), 3, 'all of them are array references');

@expected = map [
             @$_,
             map({ catdir($tmpdir, $_) } @{$_}[1 .. 3]),
             $tmpdir,
             '^n'
            ], @expected;

for my $cmd (qw/commit/) {
 my ($fh, $filename) = tempfile(UNLINK => 1);
 my $ar = App::Rgit->new(
  git  => abs_path('t/bin/git'),
  root => $tmpdir,
  cmd  => $cmd,
  args => [ abs_path($filename), $cmd, qw/^n ^g ^w ^b ^G ^W ^B ^R ^^n/ ]
 );
 isnt($ar, undef, "each $cmd has a defined object");
 my $exit = $ar->run;
 is($exit, 0, "each $cmd returned 0");
 my @lines = sort split /\n/, do { local $/; <$fh> };
 my $res = [ map [ split /\|/, $_ ], @lines ];
 my $exp = [ map [ $cmd, @$_ ], @expected ];
 is_deeply($res, $exp, "each $cmd did the right thing");
}
