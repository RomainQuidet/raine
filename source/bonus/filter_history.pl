#!/usr/bin/perl

use v5.10;
use strict;

# take an official history.dat and filter out all the useless stuff for
# raine, + fix the urls they had previously !

my $history = shift @ARGV;
die "pass history file in parameter" if (!$history);

open(F,"./raine -gl|") || die "can't launch ./raine -gl";
my @games = ();
while (<F>) {
	if (/^(.+?)[ \t]*\: /) {
		push @games,$1;
	}
}
close(F);
open(F,"<$history") || die "can't open $history";
my $skip = 0;
my $blank = 0;
while (<F>) {
	chomp;
	s/\r//;
	if (/^\$info\=(.+)/) {
		if (/tnzs,/) {
			$_ .= "tnzsb,tnzs2,";
		} elsif (/=bgaregga,/) {
			$_ .= "battleg,";
		} elsif (/=1944j,$/) {
			$_ .= "1944";
		}
		/^\$info\=(.+)/;
		my $list = $1;
		my @list = split /\,/,$list;
		$skip = 1;
		if (!/=1944,/) {
			foreach (@list) {
				my $game = $_;
				if (grep { $game eq $_} @games) {
					$skip = 0;
				}
			}
		}
	} elsif (/^\$(.+?)\=/) { # toutes les consoles etc de ness sont arrivées là-dedans !
		$skip = 1;
	} elsif (/^\$end/) {
		if ($skip) {
			$skip = 0;
			next;
		}
	}
	next if ($skip);
	next if ($_ eq "" && $blank);
	s/^(.+): (http.+)/<a href="$2">$1<\/a>/;
	say;
	$blank = ($_ eq "");
}
close(F);
