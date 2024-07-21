#!/usr/bin/perl -I/home/phil/perl/cpan/DataTableText/lib/
#-------------------------------------------------------------------------------
# Catalog music in this repository
# Philip R Brenan at appaapps dot com, Mythoi Music Inc., 2024
#-------------------------------------------------------------------------------
use warnings FATAL => qw(all);
use strict;
use Carp;
use Data::Dump qw(dump);
use Data::Table::Text qw(:all);
use GitHub::Crud qw(writeFileUsingSavedToken);

my $home  = currentDirectory;                                                   # Home
my $user  = q(philiprbrenan);                                                   # User
my $repo  = q(MythoiMusic);                                                     # Repo
my $in    = qq(DataCollection.htm);                                             # Input html
my $wf    = q(.github/workflows/main.yml);                                      # Work flow on Ubuntu

   $user  = q(MythoiMusic);                                                     # User
   $repo  = q(MythoiMusic.github.io);                                           # Repo


push my @files, searchDirectoryTreesForMatchingFiles($home, qw(.htm .md .pl .png .txt));

for my $s(@files)                                                               # Upload each selected file
 {my $c = readBinaryFile $s;                                                    # Load file
  my $t = swapFilePrefix $s, $home;
  my $w = writeFileUsingSavedToken($user, $repo, $t, $c);
  lll "$w $s $t";
 }

if (1)
 {my $d = dateTimeStamp;
  my $y = <<"END";
# Test $d

name: Test

on:
  push:
    paths:
      - '**/main.yml'
      - '**.txt'

concurrency:
  group: \${{ github.workflow }}-\${{ github.ref }}
  cancel-in-progress: true

jobs:

  test:
    permissions: write-all
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout\@v3
      with:
        ref: 'main'

    - name: Cpan
      run:  sudo cpan install -T Data::Dump Data::Table::Text GDS2 Digest::SHA1

    - name: Scan
      run: |
        perl catalog.pl

    - uses: actions/upload-artifact\@v4
      with:
        name: Catalog
        path: |
          catalog.html
          catalog.csv
END

  my $f = writeFileUsingSavedToken $user, $repo, $wf, $y;                       # Upload workflow
  lll "Ubuntu work flow for $repo written to: $f";
 }
