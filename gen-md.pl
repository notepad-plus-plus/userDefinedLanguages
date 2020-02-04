#!perl

use warnings;
use strict;
use autodie;
use JSON::PP;
use 5.010;
use Data::Dumper; $Data::Dumper::Useqq=1;
use Encode qw'encode decode';

$|++;
#binmode STDOUT, ':encoding(UTF-8)';    # this was double-encoding, apparently.

for my $fname ( @ARGV ) {
    warn "file($fname)\n";
    my $struct = do {local $/; open my $ih, '<:raw', $fname; JSON::PP::decode_json(<$ih>) };
    for my $h ( @$struct ) {
        my $f;
        $f = "./UDLs/" . $h->{'id-name'} . ".xml";
        $f = $h->{'repository'} unless -f $f;
        die "no file found", Dumper($h) unless $f;
        my $display = $h->{'display-name'};
        $display = sprintf '[%s](%s)', $display, $f if $f;
        my $desc = $h->{'description'} || $h->{'display-name'};
        my $auth = $h->{'author'};
        $auth =~ m/^\s*<(.*?)>/ && do { $auth = $1 };
        $auth =~ s/\s*<.*?>\s*//;
        $auth =~ m/^mailto:(.*)\@.*$/ && do { $auth = $1 };
        if($h->{homepage}) {
            $auth = sprintf '[%s](%s)', $auth, $h->{homepage};
        }
        my $txt = sprintf qq(| %s | %s | %s |\n), $display, $desc, $auth;
        print encode('UTF-8', $txt );
    }
}