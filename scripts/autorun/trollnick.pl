use strict;
use vars qw($VERSION %IRSSI);


use Irssi;
use Irssi::Irc;
use String::Multibyte;
$VERSION = '1.00';
%IRSSI = (
    authors     => 'Ragnax',
    contact     => 'ragnax@protonmail.ch',
    name        => 'Troll IRC channels using NICK cmd',
    description => 'This script allows ' .
                   'you to change ' .
                   'your nick in a beautiful ' .
		   'way.',
    license     => 'dowhatyouwant',
);

my %ALPHABET;

my @a_k = ("___00___", "__0__0__", "_0****0_", "_0____0_", "_0____0_");
my @b_k = ("_00000__", "_0___0__", "_000000_", "_0____0_", "_000000_");
my @c_k = ("_00000__", "_0______", "_0______", "_0______", "_00000__");
my @d_k = ("_00000__", "_0___00_", "_0____0_", "_0___00_", "_00000__");
my @e_k = ("_000000_", "_0______", "_000000_", "_0______", "_000000_");
my @f_k = ("_000000_", "_0______", "_00000__", "_0______", "_0______");
my @g_k = ("_000000_", "_0______", "_0_0000_", "_0____0_", "_000000_");
my @h_k = ("_0____0_", "_0____0_", "_000000_", "_0____0_", "_0____0_");
my @i_k = ("_000000_", "___00___", "___00___", "___00___", "_000000_");
my @j_k = ("_000000_", "____0___", "____0___", "____0___", "_0000___");
my @k_k = ("_0___00_", "_0_00___", "_00_____", "_0_00___", "_0___00_");
my @l_k = ("_0______", "_0______", "_0______", "_0______", "_000000_");
my @m_k = ("_00__00_", "_0_00_0_", "_0_00_0_", "_0____0_", "_0____0_");
my @n_k = ("_00___0_", "_0_0__0_", "_0__0_0_", "_0___00_", "_0____0_");
my @o_k = ("__0000__", "_0____0_", "_0____0_", "_0____0_", "__0000__");
my @p_k = ("_000000_", "_0____0_", "_000000_", "_0______", "_0______");
my @q_k = ("_000000_", "_0____0_", "_0___00_", "_000000_", "_______0");
my @r_k = ("_000000_", "_0____0_", "_000000_", "_0_0____", "_0___00_");
my @s_k = ("_000000_", "_0______", "_000000_", "______0_", "_000000_");
my @t_k = ("_000000_", "___00___", "___00___", "___00___", "___00___");
my @u_k = ("_0____0_", "_0____0_", "_0____0_", "_0____0_", "_000000_");
my @v_k = ("_0____0_", "_00__00_", "__0__0__", "__0__0__", "___00___");
my @w_k = ("_0____0_", "_0____0_", "_0_00_0_", "_00__00_", "_0____0_");
my @x_k = ("_0____0_", "__0__0__", "___00___", "__0__0__", "_0____0_");
my @y_k = ("_0____0_", "__0__0__", "___00___", "___00___", "___00___");
my @z_k = ("_000000_", "_____0__", "____0___", "__00____", "_000000_");


$ALPHABET{'a'} = \@a_k;
$ALPHABET{'b'} = \@b_k;
$ALPHABET{'c'} = \@c_k;
$ALPHABET{'d'} = \@d_k;
$ALPHABET{'e'} = \@e_k;
$ALPHABET{'f'} = \@f_k;
$ALPHABET{'g'} = \@g_k;
$ALPHABET{'h'} = \@h_k;
$ALPHABET{'i'} = \@i_k;
$ALPHABET{'j'} = \@j_k;
$ALPHABET{'k'} = \@k_k;
$ALPHABET{'l'} = \@l_k;
$ALPHABET{'m'} = \@m_k;
$ALPHABET{'n'} = \@n_k;
$ALPHABET{'o'} = \@o_k;
$ALPHABET{'p'} = \@p_k;
$ALPHABET{'q'} = \@q_k;
$ALPHABET{'r'} = \@r_k;
$ALPHABET{'s'} = \@s_k;
$ALPHABET{'t'} = \@t_k;
$ALPHABET{'u'} = \@u_k;
$ALPHABET{'v'} = \@v_k;
$ALPHABET{'w'} = \@w_k;
$ALPHABET{'x'} = \@x_k;
$ALPHABET{'y'} = \@y_k;
$ALPHABET{'z'} = \@z_k;

my $utf8 = String::Multibyte->new('UTF8');
my $ret = "";
sub trollnick {
	my ($nick, $server, $dest) = @_;
        my ($username, $hostname) = split(/@/, $dest->{ownnick}{host});
	if (!$server || !$server->{connected}) {
		Irssi:print("Not connected to server");
		return;
	}
	return unless $dest;
	my $l = $utf8->length($nick);
	for (my $c = 0; $c < $l; $c++) {
		my $char = $utf8->substr($nick, $c, 1);
		for (my $i = 0; $i < 5; $i++) {
			$dest->command("NICK " . $ALPHABET{$char}[$i]);
		}
		$dest->command("NICK ________");
	}
	$dest->command("NICK " . $username);
}
Irssi::command_bind("trollnick", "trollnick");
