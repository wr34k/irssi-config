use strict;
use Irssi;
use Irssi::Irc;

sub masshl {
	my ($data, $server, $channel) = @_;
	#my @nicknames = grep {$server->{nick} ne $_->{nick}} $channel->nicks();
	my @nicknames = map {$_->{nick}} $channel->nicks();
	
	my $fg = int rand(15);
	my $bg = int rand(15);
	while ($fg eq $bg) {
		$bg = int rand(15);
	}
        $server->command("MSG $channel->{name} \003$fg,$bg " . join(" ", @nicknames) . " ");
}

Irssi::command_bind('masshl', 'masshl');
