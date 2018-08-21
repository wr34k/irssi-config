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

sub flood {
	my ($data, $server, $witem) = @_;
	return unless $witem;
	my ($count) = split(/ /, $data);

	$data =~ s/^\S+\s*//;
	
	if ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY") {
		for (my $i=0; $i < $count; $i++) {
        		$witem->command("/msg " . $witem->{name} . " " . $data);
			sleep(0.1);
		}
    	}
}

Irssi::command_bind flewd => \&flood;
