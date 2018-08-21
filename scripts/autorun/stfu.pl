# ==================================================== 
# 	STFU!		  				   
#   Irssi script developed by ragnax to grey out dumb
# 	people who speak too much on IRC
# 			/script load stfu.pl
# 			/stfu help 
# ====================================================

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "lol";
%IRSSI = (
    authors     => "RRRRagnax",
    contact     => "ragnax\@protonmail.ch",
    name        => "stfu",
    description => "When you don't want to read someone's bullshit",
    license     => "LOL",
    url         => "http://motherfuckingwebsite.org"
);

my @fuckers;

sub help_stfu {
    my $help_str = 
    "STFU HELP
STFU SAVE
STFU ADD <fucker>
STFU DEL <notsofucker>
STFU LIST";

    Irssi::print($help_str, MSGLEVEL_CLIENTCRAP);
}

sub list_stfu {
    Irssi::print("List of fuckers:", MSGLEVEL_CLIENTCRAP);
    for (@fuckers) {
        Irssi::print("$_", MSGLEVEL_CLIENTCRAP);
    }
}

sub save_stfu {
	open FUCKERS, ">", "$ENV{HOME}/.irssi/fuckers";

	foreach my $fucker (@fuckers) {
		print FUCKERS "$fucker";
	}
	close FUCKERS;
    Irssi::print("Fuckers list saved yo", MSGLEVEL_CLIENTCRAP);
}

sub load_fuckers {
	open my $fuckers_fh, "<", "$ENV{HOME}/.irssi/fuckers";
	while (my $line = <$fuckers_fh>) {
		chomp;
		push @fuckers, $line;
	}
}

sub sig_nick {
	my ($server, $newnick, $nick, $address) = @_;
	$newnick = substr($newnick, 1) if ($newnick =~ /^:/);
	for my $index (reverse 0..$#fuckers) {
		if ($fuckers[$index] =~ /$nick/) {
			splice(@fuckers, $index, 1, ());
			push @fuckers, $newnick;
			last;
		}
	}
}

sub set_stfu {
	my ($fucker, $server, $dest) = @_;
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected yo", MSGLEVEL_CLIENTCRAP);
		return;
	}
	if (!$fucker) {
		Irssi::print("Choose someone to stfu yo (/stfu help)", MSGLEVEL_CLIENTCRAP);
		return
	}
	
	Irssi::print("Adding $fucker to fuckers to stfu.", MSGLEVEL_CLIENTCRAP);
	push @fuckers, $fucker;
}

sub unset_stfu {
	my ($notsofucker, $server, $dest) = @_;
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected yo", MSGLEVEL_CLIENTCRAP);
		return;
	}
	if (!$notsofucker) {
		Irssi::print("Choose someone to free yo (/stfu help)", MSGLEVEL_CLIENTCRAP);
		return
	}
	Irssi::print("Removing $notsofucker from fuckers to stfu", MSGLEVEL_CLIENTCRAP);
	for my $index (reverse 0..$#fuckers) {
		if ($fuckers[$index] =~ /$notsofucker/) {
			splice(@fuckers, $index, 1, ());
		}
	}
}

sub run_sig_stfu {
	my ($server, $data, $nick, $address) = @_;
	my ($target, $msg) = split(/ :/, $data,2);
	for (@fuckers) {
		if ($nick eq $_) {
			Irssi::signal_continue($server, "$target :\00314$msg", "\00314$nick", $address);
		}
	}
}

load_fuckers;
Irssi::signal_add('event privmsg', 'run_sig_stfu');

Irssi::command_bind('stfu help', 'help_stfu');
Irssi::command_bind('stfu list', 'list_stfu');
Irssi::command_bind('stfu save', 'save_stfu');
Irssi::command_bind('stfu add', 'set_stfu');
Irssi::command_bind('stfu del', 'unset_stfu');
Irssi::signal_add("event nick", "sig_nick");

Irssi::command_bind 'stfu' => sub {
	my ($data, $server, $target) = @_;
	Irssi::command_runsub('stfu', $data, $server, $target);
}
