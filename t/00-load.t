#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
	use_ok( 'App::Rgit' );
	use_ok( 'App::Rgit::Command' );
	use_ok( 'App::Rgit::Command::Each' );
	use_ok( 'App::Rgit::Command::Once' );
}

diag( "Testing App::Rgit $App::Rgit::VERSION, Perl $], $^X" );
