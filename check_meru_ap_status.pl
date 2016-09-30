#!/usr/bin/perl


# Developer: Giorgio Maggiolo
# Email: giorgio.maggiolo@sanbenedetto.it
# --
# check_meru_ap_status - Check AP Status
# Copyright (C) 2016 Acqua Minerale San Benedetto S.p.A., http://www.sanbenedetto.it
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

use strict;
use warnings;

use Getopt::Long;
use Net::SNMP;

GetOptions(
	'hostname=s' =>		\my $Hostname,
	'community=s' =>	\my $Community,
	'port=i' => 		\my $Port,
	'perf' =>			\my $Perf,
	'help|?' =>			sub {exec perldoc => -F => $0 or die "Cannot execute perldoc: $!\n";},
) or Error("$0: Error in command line arguments\n");


Error('Option --hostname needed!') unless $Hostname;
Error('Option --community needed!') unless $Community;

my ($crit_msg, $warn_msg, $ok_msg);



sub Error {
	print "$0: ".$_[0]."\n";
	exit 2;
}



__END__

=encoding utf8

=head1 NAME

check_meru_ap_status - Check Meru AP Status via Controller

=head1 SYNOPSIS

check_meru_ap_status.pl --hostname HOSTNAME --community SNMP_COMMUNITY \
           [--port SNMP_PORT] [--perf]

=head1 DESCRIPTION

Checks the status of all the APs connected to a specific controller

=head1 OPTIONS

=over 4

=item --hostname FQDN

The Hostname of the controller to monitor

=item --perf

Flag for performance data output

=item -help

=item -?

to see this Documentation

=back

=head1 EXIT CODE

3 on Unknown Error
2 if there are some offline APs
1 if there are some disabled APs or any problem occured
0 if everything is ok

=head1 AUTHORS

 Giorgio Maggiolo <giorgio at maggiolo dot net>


