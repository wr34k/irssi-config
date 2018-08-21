use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

sub autistnig {
	my ($data, $server, $witem) = @_;
	return unless $witem;

	my $fname = "/root/.irssi/ascii/autisticnig.txt";

	if ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY") {

		open(INPUT, "<", $fname) or die "oolala : $!\n";
		while (my $row = <INPUT>) {
			chomp $row;


			if ($row =~ m/DAFOOKINNICK/) {
				$row =~ s/DAFOOKINNICK/$data/g;
			}
			$witem->command("/msg $witem->{name} $row");
			sleep(0.1);
		}

    	}
}

Irssi::command_bind autistnig => \&autistnig;
