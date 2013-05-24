#!/usr/bin/env perl

use strict;
use warnings;
use DDP;

my ($src_file) = @ARGV;
usage() unless $src_file && -e $src_file;

sub usage {
    warn "usage: $0 <input pdldoc.db> <output pdldoc.db>\n";
    warn @_;
    exit 1;
}

my $hash = ensuredb( { File => [$src_file], Scanned => [], } );
p $hash;

# Taken from PDL::Doc with minor modifications
sub ensuredb {
    my ($this) = @_;
    while ( my $fi = pop @{ $this->{File} } ) {
        open IN, $fi
          or die "can't open database $fi, scan docs first";
        binmode IN;
        my ( $plen, $txt );
        while ( read IN, $plen, 2 ) {
            my ($len) = unpack "S", $plen;
            read IN, $txt, $len;
            my ( $sym, %hash ) = split chr(0), $txt;
            $this->{SYMS}->{$sym} = {%hash};
        }
        close IN;
        push @{ $this->{Scanned} }, $fi;
    }
    return $this->{SYMS};
}
