use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = 'LOL';
%IRSSI = (
  authors     => 'wr34k',
  contact     => 'OAOA',
  name        => 'nflewd',
  description => 'OAOAOA',
  license     => 'General Public License (LOL)',
);

sub flood {
	my ($template, $server, $witem) = @_;
	return unless $witem;
	
	my ($username, $hostname) = split(/@/, $witem->{ownnick}{host});
	my @nicknames = grep { $server->{nick} ne $_->{nick} } $witem->nicks();
	my $data;

	if ($witem->{type} eq "CHANNEL" || $witem->{type} eq "QUERY") {
		for (my $i=0; $i < @nicknames; $i++) {
			$data = $template;
			$data =~ s/\$\$/$nicknames[$i]->{nick}/;
        		$witem->command("/msg $witem->{name} $data");
			sleep(0.8);
		}
    	}
}

Irssi::command_bind nflewd => \&flood;
