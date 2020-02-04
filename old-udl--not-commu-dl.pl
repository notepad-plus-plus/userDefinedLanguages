#!perl

use warnings;
use strict;
use autodie;
use JSON::PP;
use 5.010;

$|++;

my $struct = do {local $/; open my $ih, '<', 'other-udl-list.json'; JSON::PP::decode_json(<$ih>) };
if(0){
    my @order = qw/id-name display-name version repository description author homepage/;
    my %ORDER;
    @ORDER{@order} = 1 .. @order;
    my $sort = sub {
        package JSON::PP;
        ($ORDER{$a}//1e999) <=> ($ORDER{$b} // 1e999)
            or
        $a cmp $b
    };

    print JSON::PP->new->sort_by($sort)->indent->space_after->encode($struct);
}

process_other_udl(@$struct);

exit;

sub process_other_udl {
    my @keep;
    for my $h ( @_ ) {
# TODO = ignore the {repository} filename; use {'id-name'}.xml as the filename
        next unless $h->{repository};
        my $ver = check_and_download(%$h);
        next unless $ver;           # don't keep this entry if it's not downloadable
        $h->{version} ||= $ver;     # if it didn't have a version already, set one...
        push @keep, $h;
    }
    my @order = qw/id-name display-name version repository description author homepage/;
    my %ORDER;
    @ORDER{@order} = 1 .. @order;
    my $sort = sub {
        package JSON::PP;
        ($ORDER{$a}//1e999) <=> ($ORDER{$b} // 1e999)
            or
        $a cmp $b
    };

    open my $ofh, '>', 'other-udl-list.json';
    print {$ofh} JSON::PP->new->sort_by($sort)->indent->space_after->encode(\@keep);
}


sub check_and_download {
    my %h = @_;
    return unless $h{repository};
    use LWP::UserAgent;
    use Encode;
    warn sprintf "DOWNLOADING: '%s'\n", $h{repository};
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0 ');
    my $response = $ua->get($h{repository});
    if(!$response->is_success) {
        warn sprintf "PROBLEM: '%s' => '%s'\n", $h{repository}, $response->status_line;
        return;
    }
    $h{version} ||= $response->header('last-modified') || $response->header('date');
    #use Data::Dumper; warn Dumper $response;
    my $is_zip = $h{'id-name'} =~ /\.zip$/;
    my $type = $is_zip ? '>:raw' : '>:encoding(UTF-8)';
    my $fname = $h{'id-name'}; $fname .= '.xml' unless $is_zip
    open my $ofh, $type, "UDLs/$fname";
    print {$ofh} $is_zip ? $response->decoded_content() : encode('UTF-8', $response->decoded_content());
    return $h{version};
}