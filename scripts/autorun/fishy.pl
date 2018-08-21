use 5.010;
use Irssi;
use strict;
no warnings 'experimental';

# {{{ Irssi variables
use vars qw ($VERSION %IRSSI);
%IRSSI = (
	authors		=> "arab",
	contact		=> "irc://irc.arabs.ps/arab",
	name		=> "fishy",
	description	=> "EFnet #irc-fishing support script",
	license		=> "Arabic Fuck You Licence (AFYL)",
);
$VERSION = "3.1";
# }}}
# {{{ Private subroutines
sub bindUnit {
	my ($unit) = @_;
	Irssi::command_bind("fishy", sub { $unit->("cmd", $_[1], $_[0]); });
	Irssi::signal_add("message public", sub { $unit->("msg", $_[0], $_[1], $_[4], $_[2], $_[0]->{"nick"}); Irssi::signal_continue(@_); });
	Irssi::signal_add("setup changed", sub { $unit->("reload"); });
	$unit->("init"); $unit->("reload");
};

sub mapLocationFull {
	my ($fmtfl, @location) = @_;
	my (%location_map) = (
		""	=> "",
		"ne"	=> "North Eastern",
		"nw"	=> "North Western",
		"se"	=> "South Eastern",
		"sw"	=> "South Western",
		"e"	=> "Eastern",
		"n"	=> "Northern",
		"port"	=> "Port",
		"s"	=> "Southern",
		"w"	=> "Western");
	my ($unit) = ("");
	given ($location[1]) {
	when ($_ eq "") { $unit = $location_map{$location[0]} ." quadrant"; }
	default {
		given ($fmtfl) {
		when ($_ == 1) { $unit = $location_map{$location[0]} ." quadrant (". join(",", @location[1..2]) .")"; }
		when ($_ == 2) { $unit = $location_map{$location[0]} ." quadrant sub-region (". join(",", @location[1..2]) .")"; }};
	}}; return $unit;
};
# }}}
# {{{ Unit function & globals: /FISHY GETTRAP ([ensw]|[ns][ew]|port) ([0-9]) ([0-9])
my ($g_gettrap_channel, $g_gettrap_nick, $g_gettrap_tag) = ("#irc-fishing", "[Mr_Fish]", "EFnet");
my (@g_gettrap_location, @g_gettrap_locations_next, $g_gettrap_pause, @g_gettrap_status);
sub unitGETTRAP { given ($_[0]) {
	when ($_ eq "cmd") {
		my (undef, $server, $msg) = @_; given ($msg) {
		when ($_ =~ m,^(?i:GETTRAP)\s+([ensw]|[ns][ew]|port)\s+([0-9])\s+([0-9])\s*$,) {
			given ($g_gettrap_location[0]) {
			when ($_ eq "") {
				@g_gettrap_location = ($1, $2, $3);
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_sail", mapLocationFull(1, @g_gettrap_location));
				$server = Irssi::server_find_chatnet($g_gettrap_tag);
				$server->command("msg $g_gettrap_channel sail ". $1 ." ". $2 ." ". $3);
			}
			default {
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_queue", mapLocationFull(1, ($1, $2, $3)));
				unshift(@g_gettrap_locations_next, [$1, $2, $3]);
			}};
		}
		when ($_ =~ m,^(?i:GETTRAP\s+(CANCEL|STATUS)\s*),) {
			my ($cmd, $item_num) = ($1, 1);
			given ($g_gettrap_location[0]) {
			when ($_ ne "") {
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_status_sail", mapLocationFull(1, @g_gettrap_location));
				for (my $item_num = scalar(@g_gettrap_locations_next); $item_num > 0; $item_num--) {
					Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_status_item",
						(scalar(@g_gettrap_locations_next) - $item_num) + 1,
						mapLocationFull(1, @{$g_gettrap_locations_next[$item_num-1]}));
				};
			}
			default {
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_status_none");
			}};
			given ($g_gettrap_pause) {
			when ($_ == 1) { Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_status_paused"); }};
			given (uc($cmd)) {
			when ($_ eq "CANCEL") {
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_cancel");
				@g_gettrap_location = (); @g_gettrap_status = (); $g_gettrap_pause = 0;
			}};
		}
		when ($_ =~ m,^(?i:GETTRAP\s+PAUSE\s*),) {
			$g_gettrap_pause = 1;
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_interrupt_pause");
		}
		when ($_ =~ m,^(?i:GETTRAP\s+RESUME\s*),) {
			$g_gettrap_pause = 0;
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_interrupt_resume");
		}
		when ($_ =~ m,^(?i:GETTRAP),) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_syntax", $msg);
		}
		when ($_ =~ m,^(?i:HELP)\s*(?i:GETTRAP)?\s*$,) {
			Irssi::active_win()->print("Usage: /FISHY GETTRAP ([ensw]|[ns][ew]|port) ([0-9]) ([0-9])");
			Irssi::active_win()->print("Usage: /FISHY GETTRAP CANCEL");
			Irssi::active_win()->print("Usage: /FISHY GETTRAP PAUSE");
			Irssi::active_win()->print("Usage: /FISHY GETTRAP RESUME");
			Irssi::active_win()->print("Usage: /FISHY GETTRAP STATUS");
		}};
	}
	when ($_ eq "msg") {
		my (undef, $server, $msg, $target, $nick, $own_nick) = @_;
		my ($donefl, $loc_full1, $loc_full2);

		given ((lc($target) ne lc($g_gettrap_channel)
		||     (lc($nick) ne lc($g_gettrap_nick))
		||     (lc($server->{"tag"}) ne lc($g_gettrap_tag))
		||     ($g_gettrap_location[0] eq "")
		||     ($g_gettrap_pause == 1))) {
		when ($_ == 0) {
			($donefl, $loc_full1, $loc_full2) = (0, mapLocationFull(1, @g_gettrap_location), mapLocationFull(2, @g_gettrap_location));
		}
		default { return; }};

		given ($msg) {
		when ($_ =~ m/$own_nick has set sail to the \Q$loc_full2\E\./) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_sailing", mapLocationFull(1, @g_gettrap_location));
		}
		when ($_ =~ m,$own_nick has arrived in the \Q$loc_full1\E in \d+ seconds\.,
		or    $_ =~ m/$own_nick, you can't sail to a place you already are!/) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_getting", $loc_full1);
			$server->command("msg $g_gettrap_channel !gettrap");
		}
		when ($_ =~ m/$own_nick has arrived in the (.+? quadrant(?: \(\d+,\d+\)))? in \d+ seconds\./
		or    $_ =~ m/$own_nick has set sail to the (.+? quadrant(?: sub-region \(\d+,\d+\)))? in \d+ seconds\./) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_interrupt_confuzzled", $1);
			$g_gettrap_pause = 1;
		}
		when ($_ =~ m,$own_nick You pull your (.+?) lobster trap up,) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_placing", $loc_full1);
			$server->command("msg $g_gettrap_channel !placetrap $1");
		}

		when ($_ =~ m,$own_nick Your (?:small|medium|large) trap has been ravaged by Mean Mother Ocean\.,) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_done_dead", mapLocationFull(1, @g_gettrap_location));
			push(@g_gettrap_status, ["\x0304dead\x03\x02\x02", @g_gettrap_location]); $donefl = 1;
		}
		when ($_ =~ m/$own_nick You have carefully lowered your lobster trap to the ocean depths, only time will tell what, if anything, it yields\./) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_done", mapLocationFull(1, @g_gettrap_location));
			push(@g_gettrap_status, ["\x0309done\x03\x02\x02", @g_gettrap_location]); $donefl = 1;
		}
		when ($_ =~ m/$own_nick You must wait longer until you harvest this trap\./) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_done_wait", mapLocationFull(1, @g_gettrap_location));
			push(@g_gettrap_status, ["\x0312wait\x03\x02\x02", @g_gettrap_location]); $donefl = 1;
		}
		when ($_ =~ m,$own_nick You search but cannot find any of your traps in this sub-region\.,) {
			Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_done_none", mapLocationFull(1, @g_gettrap_location));
			push(@g_gettrap_status, ["\x0305none\x03\x02\x02", @g_gettrap_location]); $donefl = 1;
		}};

		given ($donefl) {
		when ($_ == 1) {
			given (scalar(@g_gettrap_locations_next)) {
			when ($_ > 0) {
				@g_gettrap_location = @{pop(@g_gettrap_locations_next)};
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_sail", mapLocationFull(1, @g_gettrap_location));
				$server->command("msg $g_gettrap_channel sail ". join(" ", @g_gettrap_location));
			}
			default {
				my (@status_items) = ();
				for (my $item_num = scalar(@g_gettrap_status); $item_num > 0; $item_num--) {
					push(@status_items, mapLocationFull(1, @{$g_gettrap_status[$item_num-1]}[1..3])
						.": ". @{$g_gettrap_status[$item_num-1]}[0]);
				};
				Irssi::printformat(MSGLEVEL_CLIENTCRAP, "fishy_gettrap_status_done", join(", ", @status_items));
				@g_gettrap_location = (); @g_gettrap_status = ();
			}};
		}};
	}

	when ($_ eq "init") {
		Irssi::settings_add_str("fishy", "fishy_gettrap_channel", $g_gettrap_channel);
		Irssi::settings_add_str("fishy", "fishy_gettrap_nick", $g_gettrap_nick);
		Irssi::settings_add_str("fishy", "fishy_gettrap_tag", $g_gettrap_tag);
		Irssi::theme_register([
			"fishy_gettrap_cancel", "{line_start}{hilight fishy:} Cancelling!",
			"fishy_gettrap_getting", "{line_start}{hilight fishy:} %_[\$0]%_: getting trap.",
			"fishy_gettrap_interrupt_confuzzled", "{line_start}{hilight fishy:} %_[\$0]%_: pausing: confuzzled!",
			"fishy_gettrap_interrupt_pause", "{line_start}{hilight fishy:} pausing!",
			"fishy_gettrap_interrupt_resume", "{line_start}{hilight fishy:} resuming!",
			"fishy_gettrap_placing", "{line_start}{hilight fishy:} %_[\$0]%_: placing trap.",
			"fishy_gettrap_sail", "{line_start}{hilight fishy:} %_[\$0]%_: sailing...",
			"fishy_gettrap_queue", "{line_start}{hilight fishy:} %_[\$0]%_: added to queue!",
			"fishy_gettrap_sailing", "{line_start}{hilight fishy:} %_[\$0]%_: sailing.",
			"fishy_gettrap_status_done", "{line_start}{hilight fishy:} Trap run finished, report: %_\$0%_",
			"fishy_gettrap_status_item", "{line_start}{hilight fishy:} %_[#\$0]%_: \$1",
			"fishy_gettrap_status_none", "{line_start}{hilight fishy:} Status: Not currently sailing!",
			"fishy_gettrap_status_paused", "{line_start}{hilight fishy:} Status: Paused!",
			"fishy_gettrap_status_sail", "{line_start}{hilight fishy:} Status: Currently sailing to %_\$0%_, queued quadrant sub-regions:",
			"fishy_gettrap_done", "{line_start}{hilight fishy:} %_[\$0]%_: done!",
			"fishy_gettrap_done_dead", "{line_start}{hilight fishy:} %_[\$0]%_: done: trap dead!",
			"fishy_gettrap_done_none", "{line_start}{hilight fishy:} %_[\$0]%_: done: no traps found!",
			"fishy_gettrap_done_wait", "{line_start}{hilight fishy:} %_[\$0]%_: done: must wait longer!",
			"fishy_syntax", "{line_start}{hilight fishy:} %_[\$0]%_: syntax error!",
		]);
	}
	when ($_ eq "reload") {
		$g_gettrap_channel = Irssi::settings_get_str("fishy_gettrap_channel");
		$g_gettrap_nick = Irssi::settings_get_str("fishy_gettrap_nick");
		$g_gettrap_tag = Irssi::settings_get_str("fishy_gettrap_tag");
		@g_gettrap_location = ("", "", ""); @g_gettrap_locations_next = ();
		$g_gettrap_pause = 0; @g_gettrap_status = ();
	}};
};
# }}}

#
# Script entry point
#

bindUnit(\&unitGETTRAP);

# vim:foldmethod=marker
