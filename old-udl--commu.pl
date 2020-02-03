#!perl

use warnings;
use strict;
use autodie;
use JSON::PP;
use 5.010;

$|++;

my @list = parse_list('old-udl--rddim-list.txt');
process_commun_udl(@list);

exit;

sub parse_list {
    my $fname = shift;
    open my $fh, '<:raw', $fname;
    local $/ = "\n\n\n";
    my @list;
    while(<$fh>) {
        chomp;
        s{\n}{>};
        #print "$_\n";
        my ($u,$d,$m,$n,$w) = split />/, $_;
        (my $id = $u) =~ s{^.*/}{};
        $n //= '';
        $m //= '';
        my $h = {
            'id-name' => $id,
            'display-name' => $d,
            'version' => '',
            'repository' => $u,
            'description' => $d,
            'author' => "$n <$m>",
        };
        $h->{homepage} = $w if defined $w;
        push @list, $h;
        #use Data::Dumper; print scalar(@list), "\t=> ", Dumper $h;
    }
    return @list;
}

sub process_commun_udl {
    my @keep;
    for my $h ( @_ ) {
        next unless $h->{repository};
        next unless $h->{repository} =~ m{commun/userDefinedLang};
        # todo: download file from $h->{repository}
        my $ver = check_and_download(%$h);
        next unless $ver;           # don't keep this entry if it's not downloadable
        $h->{version} ||= $ver;     # if it didn't have a version already, set one...
        $h->{repository} = '';          # don't need a repository for the ones stored in the local folder
        $h->{'id-name'} =~ s/\.xml$//;  # remove .xml extension
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

    open my $ofh, '>', 'commun-udl-list.json';
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
    my $is_xml = $h{repository} =~ /\.xml$/;
    my $type = $is_xml ? '>:encoding(UTF-8)' : '>:raw';
    open my $ofh, $type, "UDLs/" . $h{'id-name'};
    print {$ofh} $is_xml ? encode('UTF-8', $response->decoded_content()) : $response->decoded_content();
    return $h{version};
}