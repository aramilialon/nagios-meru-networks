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

# OIDs to be used
my $status_oid='.1.3.6.1.4.1.15983.1.1.4.2.1.1.27'; # .meru.meru-reg.meru-wlan.mwConfiguration.mwConfigAp.mwApTable.mwApEntry.mwApAvailabilityStatus
my $name_ap_oid='.1.3.6.1.4.1.15983.1.1.4.2.1.1.2';	# .meru.meru-reg.meru-wlan.mwConfiguration.mwConfigAp.mwApTable.mwApEntry.mwApDescr

# Other variables

my ($session, $response, $varbind, $error); # Variable used in the SNMP queries
my ($crit_msg, $warn_msg, $ok_msg); 		# Return messages
my $number_ap=0;							# Number of APs
my %problematic_ap;							# Hash containing all the problematic APs

GetOptions(
	'hostname=s' =>		\my $Hostname,
	'community=s' =>	\my $Community,
	'perf' =>			\my $Perf,
	'help|?' =>			sub {exec perldoc => -F => $0 or die "Cannot execute perldoc: $!\n";}
	) or Error("$0: Error in command line arguments\n");


Error('Option --hostname needed!') unless $Hostname;
Error('Option --community needed!') unless $Community;

# Connect to the controller

($session, $error) = Net::SNMP->session(
	-hostname 	=> $Hostname,
	-community 	=> $Community,
	-timeout	=> "2",
	);

if (!defined($session)) {
      Error("ERROR: %s ; $error\n");
}

# Let's execute all the necessary SNMP query on first
$response = $session -> get_table(-baseoid => $status_oid);
my %ap_status = %{$response};
$response = $session -> get_table(-baseoid => $name_ap_oid);
my %ap_names = %{$response};

# Get the status of all the APs
foreach my $aa ( keys %ap_status){
	my $ap_number = substr $aa, 34;
	if ($ap_status{$aa} != "3"){
		$problematic_ap{$ap_number} = $ap_status{$aa};
	}
}

# Get the description of all the APs with problems (aka status != "3")

foreach my $bb (keys %ap_names){
	my $ap_number = substr $bb, 33;
	next unless exists $problematic_ap{$ap_number};
	# print $ap_number." ".$ap_names{$bb}."\n";
	if ($problematic_ap{$ap_number} == "2"){
		if ($crit_msg){
			$crit_msg .= ", ($ap_number - $ap_names{$bb})";
		} else {
			$crit_msg = "($ap_number - $ap_names{$bb})";
		}
	} else {
		if ($warn_msg){
			$warn_msg .= ", ($ap_number - $ap_names{$bb})";
		} else {
			$warn_msg = "($ap_number - $ap_names{$bb})";
		}
	}
}

if($crit_msg){
    print "CRITICAL: the following APs are offline: $crit_msg\n";
    if($warn_msg){
        print "WARNING: the following APs are in a unknown state: $warn_msg\n";
    }
    if($ok_msg){
        print "OK: $ok_msg\n";
    }
    exit 2;
} elsif($warn_msg){
    print "WARNING: the following APs are in a unknown state: $warn_msg\n";
    if($ok_msg){
        print "OK: $ok_msg\n";
    }
    exit 1;
} else {
    print "OK: all APs are online\n";
    exit 0;
}


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
			[--perf]

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


