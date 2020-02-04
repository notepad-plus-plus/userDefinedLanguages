#!perl

use warnings;
use strict;
use autodie;
use JSON::PP;
use 5.010;
use Data::Dumper; $Data::Dumper::Useqq=1;

$|++;
binmode STDOUT, ':encoding(UTF-8)';

for my $fname ( @ARGV ) {
    print "file($fname):\n";
    my $struct = do {local $/; open my $ih, '<', $fname; JSON::PP::decode_json(<$ih>) };
    print "file($fname): $struct\n";
    for my $h ( @$struct ) {
        my $f;
        $f = "./UDLs/" . $h->{'id-name'} . ".xml";
        warn "try '$f'\n";
        $f = $h->{'repository'} unless -f $f;
        unless(defined $f) {
            warn "File not defined! ", Dumper $h;
            next;
        }
        printf qq(| %s |\n), $f||'<empty>';
        die "empty" unless $f;
    }
}