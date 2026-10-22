#!/usr/bin/perl
# Strips an HTML file to readable text lines (used for the read-only source extraction).
use strict; use warnings;
local $/; my $h = <STDIN>;
$h =~ s/<(script|style|noscript|svg|template)\b.*?<\/\1>//gis;
$h =~ s/<!--.*?-->//gs;
$h =~ s/<(br|\/p|\/div|\/li|\/h[1-6]|\/tr|\/section|\/button|\/a|\/td|\/th)\b[^>]*>/\n/gi;
$h =~ s/<[^>]+>/ /g;
my %e=('&amp;'=>'&','&lt;'=>'<','&gt;'=>'>','&quot;'=>'"','&#039;'=>"'",'&#8217;'=>"'",'&#8216;'=>"'",'&#8220;'=>'"','&#8221;'=>'"','&#8211;'=>'-','&#8212;'=>'--','&nbsp;'=>' ','&#038;'=>'&','&#8230;'=>'...','&rsquo;'=>"'",'&ldquo;'=>'"','&rdquo;'=>'"','&#8226;'=>'*');
$h =~ s/(&[#a-z0-9]+;)/exists $e{$1}?$e{$1}:$1/gie;
my @out; my $prev='';
for my $l (split /\n/, $h) { $l =~ s/\s+/ /g; $l =~ s/^ | $//g; next if $l eq '' || $l eq $prev; push @out,$l; $prev=$l; }
print join("\n",@out),"\n";
