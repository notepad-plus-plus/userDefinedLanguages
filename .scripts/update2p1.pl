#!perl

# TODO: fix bug that it cannot handle elements that cross multiple lines; for now, just fix the files manually and re-convert; but if I need this again some day, I will need to fix this
# TODO: the Delimiters didn't work right with sequence of six like this one: &quot;`0&quot;`

use 5.012; # strict, //
use warnings;
use autodie;
use Data::Dump qw{dd pp};
use FindBin;

BEGIN {
    chdir "$FindBin::Bin/../UDLs/";
}

my %stylemap = (
    'DEFAULT' => 'DEFAULT',
    'COMMENT' => 'COMMENTS',
    'COMMENT LINE' => 'LINE COMMENTS',
    'NUMBER' => 'NUMBERS',
    'KEYWORD1' => 'KEYWORDS1',
    'KEYWORD2' => 'KEYWORDS2',
    'KEYWORD3' => 'KEYWORDS3',
    'KEYWORD4' => 'KEYWORDS4',
    'KEYWORD5' => 'KEYWORDS5',
    'KEYWORD6' => 'KEYWORDS6',
    'KEYWORD7' => 'KEYWORDS7',
    'KEYWORD8' => 'KEYWORDS8',
    'OPERATOR' => 'OPERATORS',
    'FOLDEROPEN' => 'FOLDER IN CODE1',
    'FOLDERCLOSE' => 'FOLDER IN CODE2',
    'FOLDERCOMMENT' => 'FOLDER IN COMMENT',
    'DELIMINER1' => 'DELIMITERS1',
    'DELIMINER2' => 'DELIMITERS2',
    'DELIMINER3' => 'DELIMITERS3',
    'DELIMINER4' => 'DELIMITERS4',
    'DELIMINER5' => 'DELIMITERS5',
    'DELIMINER6' => 'DELIMITERS6',
    'DELIMINER7' => 'DELIMITERS7',
    'DELIMINER8' => 'DELIMITERS8',
    'DELIMITER1' => 'DELIMITERS1',
    'DELIMITER2' => 'DELIMITERS2',
    'DELIMITER3' => 'DELIMITERS3',
    'DELIMITER4' => 'DELIMITERS4',
    'DELIMITER5' => 'DELIMITERS5',
    'DELIMITER6' => 'DELIMITERS6',
    'DELIMITER7' => 'DELIMITERS7',
    'DELIMITER8' => 'DELIMITERS8',
    'REGEX' => 'REGEX',
);
my @STYLEORDER = (
    'DEFAULT',
    'COMMENTS',
    'LINE COMMENTS',
    'NUMBERS',
    'KEYWORDS1',
    'KEYWORDS2',
    'KEYWORDS3',
    'KEYWORDS4',
    'KEYWORDS5',
    'KEYWORDS6',
    'KEYWORDS7',
    'KEYWORDS8',
    'OPERATORS',
    'FOLDER IN CODE1',
    'FOLDER IN CODE2',
    'FOLDER IN COMMENT',
    'DELIMITERS1',
    'DELIMITERS2',
    'DELIMITERS3',
    'DELIMITERS4',
    'DELIMITERS5',
    'DELIMITERS6',
    'DELIMITERS7',
    'DELIMITERS8',
);
my %wordsstyles = ();

my %keywordmap = (
    'Delimiters' => 'Delimiters',
    'Folder+' => 'Folders in code1, open',
    'Folder-' => 'Folders in code1, close',
    'Operators' => 'Operators1',
    'Comment' => 'Comments',
    'Words1' => 'Keywords1',
    'Words2' => 'Keywords2',
    'Words3' => 'Keywords3',
    'Words4' => 'Keywords4',
    'Words5' => 'Keywords4',
    'Words6' => 'Keywords4',
    'Words7' => 'Keywords4',
    'Words8' => 'Keywords4',
);
my @KEYWORDORDER = (
    "Comments",
    "Numbers, prefix1",
    "Numbers, prefix2",
    "Numbers, extras1",
    "Numbers, extras2",
    "Numbers, suffix1",
    "Numbers, suffix2",
    "Numbers, range",
    "Operators1",
    "Operators2",
    "Folders in code1, open",
    "Folders in code1, middle",
    "Folders in code1, close",
    "Folders in code2, open",
    "Folders in code2, middle",
    "Folders in code2, close",
    "Folders in comment, open",
    "Folders in comment, middle",
    "Folders in comment, close",
    "Keywords1",
    "Keywords2",
    "Keywords3",
    "Keywords4",
    "Keywords5",
    "Keywords6",
    "Keywords7",
    "Keywords8",
    "Delimiters",
);
my %keywords = (
    "Comments" => '',
    "Numbers, prefix1" => '',
    "Numbers, prefix2" => '',
    "Numbers, extras1" => '',
    "Numbers, extras2" => '',
    "Numbers, suffix1" => '',
    "Numbers, suffix2" => '',
    "Numbers, range" => '',
    "Operators1" => '',
    "Operators2" => '',
    "Folders in code1, open" => '',
    "Folders in code1, middle" => '',
    "Folders in code1, close" => '',
    "Folders in code2, open" => '',
    "Folders in code2, middle" => '',
    "Folders in code2, close" => '',
    "Folders in comment, open" => '',
    "Folders in comment, middle" => '',
    "Folders in comment, close" => '',
    "Keywords1" => '',
    "Keywords2" => '',
    "Keywords3" => '',
    "Keywords4" => '',
    "Keywords5" => '',
    "Keywords6" => '',
    "Keywords7" => '',
    "Keywords8" => '',
    "Delimiters" => '',
);

#FNAME: for my $fname ('Zebra_Printing_Language.xml', 'X3D_ClassicEncoding_byJordiRCardona.xml') { #(sort <*.xml>) {
#FNAME: for my $fname ('CoffeeScript_by-blakmatrix.xml') { #(sort <*.xml>) {
FNAME: for my $fname (sort <*.xml>) {
    local $| = 1;
    my @lines = ();
    open my $fh, '<', $fname;
    my ($stylePrefix, $keywordsPrefix);
    while(<$fh>) {
        s/\r*\n/\n/; # CRCRLF or CRLF => EOL
        if(m{^\h*<UserLang\b}) {
            if(m{udlVersion=}) {
                close $fh;
                print "// SKIPPING UDL2.1 $fname\n";
                next FNAME;
            } else {
                print "// CONVERTING UDL1.x to UDL2.1 for $fname\n";
                my $tstamp = scalar gmtime;
                s{>}{ udlVersion="2.1" converted="$tstamp UTC">};
            }
        }
        elsif(m{^\h*<(Languages|LexerStyles)}) {
            close $fh;
            print "// ERROR! $fname is a StyleConfigurator file, not a UDL!\n";
            next FNAME;
        }
        elsif(m/^\s+$/) {
            next; # skip whitespace-only lines
        }
        elsif(m{^\h*<Global\b}) {
            s{/>}{caseIgnored="no" />} unless m{\bcaseIgnored\h*=};
            s{/>}{allowFoldOfComments="no" />} unless m{\ballowFoldOfComments\h*=};
            s{/>}{foldCompact="no" />} unless m{\bfoldCompact\h*=};
            s{/>}{forcePureLC="0" />} unless m{\bforcePureLC\h*=};
            s{/>}{decimalSeparator="no" />} unless m{\bdecimalSeparator\h*=};
        }
        elsif(m{^\h*<TreatAsSymbol\b}) {
            next;
        }
        elsif(m{^\h*<Prefix\b}) {
            s{\bwords\b}{Keywords}g;
            s{/>}{Keywords5="no" Keywords6="no" Keywords7="no" Keywords8="no" />}
        }
        elsif(m{^\h*<WordsStyle\b}) {
            my $name        = m{name\h*=\h*"(.*?)"} ? $1 : undef;
            next unless defined $name;
            if(!exists $stylemap{$name} or !defined $stylemap{$name}) {
                print "Cannot find stylemap for '$name'... SKIPPING\n";
                next;
            }
            my $label       = $stylemap{$name};
            m{fgColor\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{fgColor} = $1 };
            m{bgColor\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{bgColor} = $1 };
            m{fontName\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{fontName} = $1 if length($1)};
            m{fontStyle\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{fontStyle} = $1 };
            m{fontSize\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{fontSize} = $1 };
            m{nesting\h*=\h*"(.*?)"} && do { $wordsstyles{$label}{nesting} = $1 };
            m{^(\h*)<WordsStyle\b} && do { $wordsstyles{$label}{_prefix} = $1; $stylePrefix //= $1; };
            #print "WordsStyle: "; dd $wordsstyles{$label};
            next;   # don't want to push this line onto the array, because that will happen at </Styles>
        }
        elsif(m{^\h*</Styles\b}) {
            my @styles = @STYLEORDER;
            push @styles, 'REGEX' if exists $wordsstyles{REGEX};
            for my $label ( @styles ) {
                my $line = defined($wordsstyles{$label}{_prefix}) ? $wordsstyles{$label}{_prefix} : $stylePrefix;
                $wordsstyles{$label}{$_} //= $wordsstyles{DEFAULT}{$_} for qw/fgColor bgColor fontStyle/;
                $wordsstyles{$label}{nesting} //= 0;
                $line .= qq(<WordsStyle name="$label");
                $line .= qq( fgColor="$wordsstyles{$label}{fgColor}") if defined $wordsstyles{$label}{fgColor};
                $line .= qq( bgColor="$wordsstyles{$label}{bgColor}") if defined $wordsstyles{$label}{bgColor};
                $line .= qq( fontName="$wordsstyles{$label}{fontName}") if defined $wordsstyles{$label}{fontName};
                $line .= qq( fontStyle="$wordsstyles{$label}{fontStyle}") if defined $wordsstyles{$label}{fontStyle};
                $line .= qq( fontSize="$wordsstyles{$label}{fontSize}") if defined $wordsstyles{$label}{fontSize};
                $line .= qq( nesting="$wordsstyles{$label}{nesting}") if defined $wordsstyles{$label}{nesting};
                $line .= " />\n";
                $line =~ s{name="REGEX"}{name="REGEX" styleID="52" comment="converted from UDL1.x"};    # not technically valid, but since multiple UDL had it, I want to track it
                push @lines, $line;
            }
        }
        elsif(m{^(\h*)<Keywords\b}) {
            $keywordsPrefix //= $1;
            my $name        = m{name\h*=\h*"(.*?)"} ? $1 : undef;
            next unless defined $name;
            die "$fname: Keyword '$name' not in keyword map: >>$_<<" unless exists $keywordmap{$name};
            my $label = $keywordmap{$name};

            # Found v6.0 uses old-style UDL (UDL2 started in v6.2, and v6.3 had major updates (probably UDL2.1))

            #   <Keywords name="Delimiters">000000</Keywords>
            #                               000000 => no delimiters defined
            #                               ^  ^   => open and close for delimiter 1 go here, as &ent;
            #                                ^  ^  => delimiter 2
            #                                 ^  ^ => cannot find delimiter 3 in GUI
            #                               &lt;&quot;0&gt;&apos;0 => open 1:< 2:" close 1:> 2:'
            #   UDL2.1 uses 00 - 23 as the prefixes, with each group of three being open/escape/close for each subsequent delimiter#
            m{"Delimiters">(.*?)</Keywords>} and do {
                my $v = $1;
                my ($o1,$o2,$o3,$c1,$c2,$c3) = ($v =~ m{(0|&\w+;|.)((?1))((?1))((?1))((?1))((?1))});
                s/^0$// for ($o1,$o2,$o3,$c1,$c2,$c3);  # convert "0" to empty

                # create the 00 .. 23 format string
                my $fmt = "00%s 01 02%s 03%s 04 05%s 06%s 07 08%s ";
                $fmt .= sprintf "%02d ", $_ for 9 .. 23;

                # make the new Delimiters value from the fmt string and the three open/close pairs
                $keywords{$label} = sprintf $fmt, $o1, $c1, $o2, $c2, $o3, $c3;
            };

            #   <Keywords name="Comment"> 1 1/* 2 2*/ 0# 0//</Keywords>
            #                             ^     ^           => first block open/close token
            #                               ^     ^         => second block open/close
            #                                         ^  ^  => first and second comment-line starter
            #   UDL 2.1 uses 00_ for line-open, 01_ for line-cont, 02_ for line-close, 03_ for block-open, 04_ for block-close
            m{"Comment">(.*?)</Keywords>} and do {
                my $v = $1;
                my @blk_opn = ($v =~ m{1(.*?)(?=\s|$)}g);
                my @blk_cls = ($v =~ m{2(.*?)(?=\s|$)}g);
                my @ln_cmnt = ($v =~ m{0(.*?)(?=\s|$)}g);
                $keywords{$label} = sprintf "00%s 01%s 02%s 03%s 04%s",
                    join(" ", @ln_cmnt), "", "",                # line open/cont/close
                    join(" ", @blk_opn), join(" ", @blk_cls),   # block open/close
                    ;
            };

            # The remaining names/labels are just lists that can be copied straight across
            m{"Folder\+">(.*?)</Keywords>} and do { $keywords{$label} = $1; };
            m{"Folder\-">(.*?)</Keywords>} and do { $keywords{$label} = $1; };
            m{"Operators">(.*?)</Keywords>} and do { $keywords{$label} = $1; };
            m{"Words\d">(.*?)</Keywords>} and do { $keywords{$label} = $1; };

            #chomp;s/^\h*//;push @lines, "            <!--$_-->\n";    # DELETE THIS LINE AFTER DEBUG

            # don't want to push this line onto the array, because that will happen at </KeywordLists>
            next;
        }
        elsif(m{^\h*</KeywordLists\b}) {
            $keywordsPrefix //= "    "x3;   # give a default prefix
            for my $label ( @KEYWORDORDER ) {
                my $line = sprintf qq{%s<Keywords name="%s">%s</Keywords>\n}, $keywordsPrefix, $label, $keywords{$label};
                push @lines, $line;
            }
        }

        push @lines, $_;
    }
    close $fh;

    rename $fname, "$fname.bak";
    open $fh, '>', $fname;
    print {$fh} grep { m/^.+$/ } @lines;    # only output non-blank lines
}
