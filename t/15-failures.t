#!perl

use strict;
use warnings;

use Test::More tests => 17;

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

$res = eval { App::Rgit->new(root => 't/repos') };
is($@,   '',    'App::Rgit->new(): no git: does not croak');
is($res, undef, 'App::Rgit->new(): no git: returns undef');

$res = eval { App::Rgit->new(root => 't/repos', git => $0) };
is($@,   '',    'App::Rgit->new(): wrong git: does not croak');
is($res, undef, 'App::Rgit->new(): wrong git: returns undef');

$res = eval { App::Rgit->new(root => 't/repos', git => 't/bin/git') };
is($@,       '',          'App::Rgit->new(): no cmd: does not croak');
isa_ok($res, 'App::Rgit', 'App::Rgit->new(): no cmd: returns an object');

$res = eval { App::Rgit->new(root => 't/repos', git => 't/bin/git', cmd => 'version'); };
is($@,       '',          'App::Rgit->new(): no args: does not croak');
isa_ok($res, 'App::Rgit', 'App::Rgit->new(): no args: returns an object');

$res = eval { $res->new(root => 't/repos', git => 't/bin/git', cmd => 'version'); };
is($@,       '',          '$ar->new(): no args: does not croak');
isa_ok($res, 'App::Rgit', '$ar->new(): no args: returns an object');

$res = eval { App::Rgit::new(undef, root => 't/repos', git => 't/bin/git', cmd => 'version'); };
is($@,       '',         'undef->App::Rgit::new(): no args: does not croak');
isa_ok($res, 'App::Rgit','undef->App::Rgit::new(): no args: returns an object');
