#!perl

use strict;
use warnings;

use Cwd qw/cwd/;
use File::Spec::Functions qw/catdir/;

use Test::More tests => 45;

use App::Rgit;

local $SIG{__WARN__} = sub { die @_ };

eval { App::Rgit->new(qw/foo bar baz/) };
like($@, qr!Optional\s+arguments\s+must\s+be\s+passed\s+as\s+keys?\s*/\s*values?\s+pairs?!, 'App::Rgit->new(even): croaks');

my $res = eval { App::Rgit->new() };
is($@,   '',    'App::Rgit->new(): no root: does not croak');
is($res, undef, 'App::Rgit->new(): no root: returns undef');

$res = eval { App::Rgit->new(root => $0) };
is($@,   '',    'App::Rgit->new(): wrong root: does not croak');
is($res, undef, 'App::Rgit->new(): wrong root: returns undef');

$res = eval { App::Rgit->new(root => 't') };
is($@,   '',    'App::Rgit->new(): no git: does not croak');
is($res, undef, 'App::Rgit->new(): no git: returns undef');

$res = eval { App::Rgit->new(root => 't', git => $0) };
is($@,   '',    'App::Rgit->new(): wrong git: does not croak');
is($res, undef, 'App::Rgit->new(): wrong git: returns undef');

$res = eval { App::Rgit->new(root => 't', git => 't/bin/git') };
is($@,       '',          'App::Rgit->new(): no cmd: does not croak');
isa_ok($res, 'App::Rgit', 'App::Rgit->new(): no cmd: returns an object');

$res = eval { App::Rgit->new(root => 't', git => 't/bin/git', cmd => 'version'); };
is($@,       '',          'App::Rgit->new(): no args: does not croak');
isa_ok($res, 'App::Rgit', 'App::Rgit->new(): no args: returns an object');

$res = eval { $res->new(root => 't', git => 't/bin/git', cmd => 'version'); };
is($@,       '',          '$ar->new(): no args: does not croak');
isa_ok($res, 'App::Rgit', '$ar->new(): no args: returns an object');

$res = eval { App::Rgit::new(undef, root => 't', git => 't/bin/git', cmd => 'version'); };
is($@,       '',         'undef->App::Rgit::new(): no args: does not croak');
isa_ok($res, 'App::Rgit','undef->App::Rgit::new(): no args: returns an object');

use App::Rgit::Command;

eval { App::Rgit::Command::Once->App::Rgit::Command::new(cmd => 'dongs') };
like($@, qr!Command\s+dongs\s+should\s+be\s+executed\s+as\s+a\s+App::Rgit::Command::Each!, 'App::Rgit::Command::Once->App::Rgit::Command::new(cmd => "dongs"): croaks');

{
 no strict 'refs';
 push @{'App::Rgit::Test::Foo::ISA'}, 'App::Rgit::Command::Once';
}
$res = eval { App::Rgit::Test::Foo->App::Rgit::Command::new(cmd => 'version') };
is($@, '', 'App::Rgit::Test::Foo->App::Rgit::Command::new(cmd => "version"): does not croak');
isa_ok($res, 'App::Rgit::Test::Foo', 'App::Rgit::Test::Foo->App::Rgit::Command::new(cmd => "version"): returns valid object');

$res = eval { App::Rgit::Command->action('version') };
is($@,   '', 'App::Rgit::Command->action("version"): does not croak');
is($res, 'App::Rgit::Command::Once', 'App::Rgit::Command->action("version"): returns valid answer');

$res = eval { App::Rgit::Command->new(cmd => 'version')->action() };
is($@,   '', 'App::Rgit::Command->action(): does not croak');
is($res, 'App::Rgit::Command::Once', 'App::Rgit::Command->action(): returns valid answer');

$res = eval { App::Rgit::Command->action() };
is($@,   '',    'App::Rgit::Command->action(): no cmd: does not croak');
is($res, undef, 'App::Rgit::Command->action(); no cmd: returns undef');

$res = eval { App::Rgit::Command::action() };
is($@,   '',    'undef->App::Rgit::Command::action(): no cmd: does not croak');
is($res, undef, 'undef->App::Rgit::Command::action(); no cmd: returns undef');

$res = bless { }, 'App::Rgit::Test::Monkey';
$res = eval { $res->App::Rgit::Command::action() };
is($@,   '',    'App::Rgit::Test::Monkey->App::Rgit::Command::action(): no cmd: does not croak');
is($res, undef, 'App::Rgit::Test::Monkey->App::Rgit::Command::action(); no cmd: returns undef');

$res = eval { App::Rgit::Command->action('beer' => 'App::Rgit::Test::Pub') };
is($@, '', 'App::Rgit::Command->action("beer" => "App::Rgit::Test::Pub"): does not croak');
is($res, 'App::Rgit::Test::Pub', 'App::Rgit::Command->action("beer" => "App::Rgit::Test::Pub"): returns valid answer');

$res = eval { App::Rgit::Command->action('beer') };
is($@, '', 'App::Rgit::Command->action("beer"): does not croak');
is($res, 'App::Rgit::Test::Pub', 'App::Rgit::Command->action("beer"): returns valid answer');

$res = eval { App::Rgit::Command->new(cmd => 'beer') };
like($@, qr!Couldn't\s+load\s+App::Rgit::Test::Pub\s*:!, 'App::Rgit::Command->new(cmd => "pub"): croaks');

use App::Rgit::Config;

my $arc = App::Rgit::Config->new(root => 't', git => 't/bin/git');

$res = eval { $arc->repos };
is($@, '', '$arc->repos: does not croak');
is_deeply($res, [ ], '$arc->repos: found nothing');

$res = eval { $arc->repos };
is($@, '', '$arc->repos: does not croak');
is_deeply($res, [ ], '$arc->repos: cached ok');

use App::Rgit::Repository;

my $cwd = cwd;
my $t = catdir($cwd, 't');
chdir $t or die "chdir($t): $!";

$res = eval { App::Rgit::Repository->new() };
is($@, '', 'App::Rgit::Repository->new: no dir: does not croak');
is($res, undef, 'App::Rgit::Repository->new: no dir: returns undef');

$res = eval { App::Rgit::Repository->new(fake => 1) };
is($@, '', 'App::Rgit::Repository->new: no dir, fake: does not croak');
isa_ok($res, 'App::Rgit::Repository', 'App::Rgit::Repository->new: no dir, fake: returns a valid object');

chdir $cwd or die "chdir($cwd): $!";

$res = eval { App::Rgit::Repository->new(dir => 't', fake => 1) };
is($@, '', 'App::Rgit::Repository->new: relative dir, fake: does not croak');
isa_ok($res, 'App::Rgit::Repository', 'App::Rgit::Repository->new: relative dir, fake: returns a valid object');

