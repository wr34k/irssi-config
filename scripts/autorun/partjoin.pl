use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = 'LOL';
%IRSSI = (
  authors     => 'wr34k',
  contact     => 'OAOA',
  name        => 'flewd',
  description => 'Chikiboom',
  license     => 'General Public License (LOL)',
);

sub partjoin {
	my ($data, $server, $witem) = @_;
	$server->send_raw("PART $witem->{name} $data");
	sleep(0.5);
	$server->send_raw( "JOIN $witem->{name}" );
}

Irssi::command_bind pjoin => \&partjoin;
