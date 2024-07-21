#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Catalog available music in this repository
# Philip R Brenan at appaapps dot com, Mythoi Music Inc., 2024
#-------------------------------------------------------------------------------
use v5.34;
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);

my $catalogHtm = q(catalog.html);                                               # Catalog file as html
my $catalogCsv = q(catalog.csv);                                                # Catalog file as csv

makeDieConfess;

my @f = searchDirectoryTreesForMatchingFiles currentDirectory, qw(.txt);        # Files to process

my @m;
for my $f(@f)                                                                   # Read each txt file for details of each piece of music
 {my $D = readFile $f;
     $D =~ s(":) (" =>)gs;
  my $d = eval $D;                                                              # Load txt file containing one entry
  say STDERR $@ if $@;
  push @m, {%$d, file=>$f};                                                     # Add file from whence came the data
 }

say STDERR "Mythoi Music Cataloger 202407";

if (!@m)
 {say STDERR "  No files to process";
  exit(1)
 }

my %k = map {$_->%*} @m;                                                        # Keys present over all files
my @k = sort keys %k;                                                           # Column header order

my @c = join ', ',  @k;                                                         # Create csv
my @h = <<END;                                                                  # Create html
<table border=0 cellpadding=10>
END

push @h, join ' ', '<tr>', map {"<th>$_"} @k;                                   # Table column headers

for my $i(keys @m)                                                              # Each file
 {my $m = $m[$i];
  say STDERR sprintf "%6d %s", $i+1, $$m{file};                                 # File being read
  my @H = "<tr>";                                                               # Html row created from file being read
  my @C;                                                                        # Csv row from file being read
  for my $j(keys @k)                                                            # Each key in order
   {my $k = $k[$j];
    my $v = $$m{$k} // '';
    push @H, qq(<td>$v);
    push @C, dump($v);                                                          # Quote for csv
   }
  push @h, join '',  @H;
  push @c, join ',', @C;
 }

push @h, <<END;
</table>
END

owf $catalogHtm, join "\n", @h;
owf $catalogCsv, join "\n", @c;

say STDERR scalar(@m), " files cataloged"
