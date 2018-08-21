use strict;
use Irssi;
use utf8;
use List::Util qw/shuffle/;

sub get_unistring {
	my @chars = ( 
		0x0021,
	        0x0023..0x0026,
	        0x0028..0x007E,
	        0x00A1..0x00AC,
	        0x00AE..0x00FF,
	        0x0100..0x017F,
	        0x0180..0x024F,
	        0x2C60..0x2C7F,
	        0x16A0..0x16F0,
	        0x0370..0x0377,
	        0x037A..0x037E,
	        0x0384..0x038A,
	        0x038C..0x038C
	);

	for (my $i = scalar @chars; --$i; ) {
		my $j = int rand ($i+1);
		next if $j == $i;
		@chars[$i,$j] = @chars[$j,$i];
	}

	my $string;
	$string = join('', map { chr() } @chars);

	return substr($string, 0, (int rand(60) + 125));
}

sub uniflewd {
	my ($length, $server, $witem) = @_;
	return unless $witem;
	return unless $length;
	
	if ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY") {

		for (my $i=0; $i < $length; $i++) {
        		$witem->command("/msg " . $witem->{name} . " " . get_unistring());
			sleep(0.1);

		}

    	}
}

Irssi::command_bind uniflewd => \&uniflewd;
