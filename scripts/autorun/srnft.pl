use strict;
use Irssi;
use Irssi::Irc;

sub string_rainbow_shift {
	my ($data, $server, $channel) = @_;

	my ($fg, $bg, $a, $i);
	my @letters = (split //, $data);

	my $len = length $data;
	for ($i = 0; $i < $len+1; $i++) {
		($fg,$bg) = get_colors();
		$server->command("MSG $channel->{name} \00304,01!\00301,04!\00304,01!\003$fg,$bg ".join('', @letters)."\003$fg,$bg \00304,01!\00301,04!\00304,01!\n");
		$a = shift @letters;
		push @letters, $a;
	}
}

sub get_colors {
	my $fg = int rand(15);
	my $bg = int rand(15);

	while ($fg eq $bg) {
		$bg = int rand(15);
	}
	return ($fg,$bg);
}


Irssi::command_bind('srnft', 'string_rainbow_shift');
#string_rainbow_shift("I HAVE A BIG PENIS");
