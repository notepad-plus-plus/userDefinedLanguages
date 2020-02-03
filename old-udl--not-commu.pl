#!perl

use warnings;
use strict;
use autodie;
use JSON::PP;
use 5.010;

$|++;

my @list = parse_list('old-udl--rddim-list.txt');
process_other_udl(@list);

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

sub process_other_udl {
    my @keep;
    for my $h ( @_ ) {
        next unless $h->{repository};
        next if $h->{repository} =~ m{commun/userDefinedLang};
        # todo: download file from $h->{repository}
        my $ver = check_for_download(%$h);
        next unless $ver;           # don't keep this entry if it's not downloadable
        $h->{version} ||= $ver;     # if it didn't have a version already, set one...
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

    open my $ofh, '>', 'other-udl-list.json';
    print {$ofh} JSON::PP->new->sort_by($sort)->indent->space_after->encode(\@keep);
}

sub check_for_download {
    my %h = @_;
    return unless $h{repository};
    use LWP::UserAgent;
    use Encode;
    warn sprintf "CHECKING: '%s'\n", $h{repository};
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0 ');
    my $response = $ua->head($h{repository});
    if(!$response->is_success) {
        warn sprintf "PROBLEM: '%s' => '%s'\n", $h{repository}, $response->status_line;
        return;
    }
    #warn sprintf "RESPONSE: '%s' => '%s' '%s' '%s'\n", $h{repository}, $response->status_line,
    #    $response->header('last-modified') || '<unknown>', $response->header('date');
    $h{version} = $response->header('last-modified') || $response->header('date');
    #use Data::Dumper; warn Dumper $response;
    return $h{version};
}