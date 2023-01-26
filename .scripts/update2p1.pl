#!perl

use 5.012; # strict, //
use warnings;
use autodie;
use Data::Dump;
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
my %keywords = ();

FNAME: for my $fname ('Zebra_Printing_Language.xml', 'gedcom55_byAnonymous_in2010.xml') { #(sort <*.xml>) {
    local $| = 1;
    print "oldname = $fname\n";
    my @lines = ();
    open my $fh, '<', $fname;
    my $stylePrefix;
    while(<$fh>) {
        if(m{^\h*<UserLang\b}) {
            if(m{udlVersion=}) {
                close $fh;
                print "// EXITING $fname EARLY //\n";
                next FNAME;
            } else {
                s{>}{ udlVersion="2.1">};
            }
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
            for my $label ( @STYLEORDER ) {
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
                push @lines, $line;
            }
        }
        elsif(m{^\h*<Keywords\b}) {
            my $name        = m{name\h*=\h*"(.*?)"} ? $1 : undef;
            next unless defined $name;
            die "$name not in keyword map" unless exists $keywordmap{$name};

            # TODO: extract each of the fields and convert to new syntax in $keywords{$name}{...}

            chomp;s/^\h*//;push @lines, "            <!--$_-->\n";    # DELETE THIS LINE AFTER DEBUG
            next; # don't want to push this line onto the array, because that will happen at </KeywordLists>
        }
        elsif(m{^\h*</KeywordLists\b}) {
            push @lines, "            <!--...reformatted keywords...-->\n";
        }
        #TODO: do Keywords mapping output in /KeywordLists similar to WordsStyles and /Styles above: so `<Keywords ` will put it into data structure, and `</KeywordLists` will trigger output

        push @lines, $_;
    }
    print @lines;
    last;
}
