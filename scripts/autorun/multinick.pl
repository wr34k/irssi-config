use strict;
use warnings;
use Irssi;
our ($VERSION, %IRSSI) = ("14.88", (
	"authors"	=> "vxp",
	"contact"	=> "irc://irc.arabs.ps/arab",
	"name"		=> "ARAB",
	"description"	=> "multinick",
	"license"	=> "ARABIC FUCK YOU LICENCE",
	"url"		=> "irc://irc.arabs.ps/arab",
));

my ($g_multinick_chatnet) = ("Arabs");

sub reload {
	$g_multinick_chatnet = Irssi::settings_get_str("multinick_chatnet");
};

Irssi::signal_add("message public", sub {
	my ($server, $msg, $nick, $address, $target) = @_;
	if (($server->{"chatnet"} eq $g_multinick_chatnet)
	and (lc($address) eq lc("pronouns\@I.AM.A.REAL.FEMALE.OK"))
	and ($msg =~ m,^!multinick ([^ ]+?) :(.+)$,)
	and (lc($1) eq lc($server->{"nick"}))) {
		$server->send_raw("NICK :$2");
	};
	Irssi::signal_continue @_;
});

Irssi::signal_add("event 001", sub {
	my ($server) = @_;
	if ($server->{"chatnet"} eq $g_multinick_chatnet) {
		$server->send_raw("MODE ". $server->{"nick"} ." +e");
	};
	Irssi::signal_continue @_;
});

Irssi::settings_add_str("multinick", "multinick_chatnet", $g_multinick_chatnet);
Irssi::signal_add("setup changed", \&reload);
reload();

# vim:ts=8 sw=8 tw=100 noexpandtab foldmethod=marker foldmarker={{{{,}}}}
