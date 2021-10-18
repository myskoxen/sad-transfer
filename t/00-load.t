#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'SAD::Transfer' ) || print "Bail out!\n";
}

diag( "Testing SAD::Transfer $SAD::Transfer::VERSION, Perl $], $^X" );
