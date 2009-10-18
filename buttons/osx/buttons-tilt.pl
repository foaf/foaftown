#!/usr/bin/perl -w
#
# Use the MacBook's accelerometers (tilt sensors) to drive Buttons
#
# buttons bits by danbri, based on code by tod e kurt  Created 7 December 2006
#
# OK this is some Perl that reads the OSX tilt sensors and post-processes into 
# signals which were originally ( see http://hackingroomba.com/2006/12/08/roomba-tilt-control-with-macbook-perl/ )
# intended to be sent to a Roomba robot. The idea here instead is to wire them up to
# Buttons XMPP so they can be potentially used as UI eg. for browsing thru a media collection.
# See http://wiki.foaf-project.org/w/Buttons
#
# This may be nuts. But who knows? see eg http://www.reghardware.co.uk/2006/05/25/macbook_motion_sensor_mallarkey/
# which shows how tapping the side of the screen can be picked up by these sensors. And with Buttons/XMPP 
# we can send these events out to be used in media centre UI, or even .js code running inside a widget in a social network 
# site. 
#
# At the moment this script contains loads of roomba robot controller code (or dangling references to it). But it gives you 
# an idea of what can be done. --DanBri



# Notes:
# With AMSTracker, my MacBook spits out:
#  - more negative Z when tilted away from me
#  - more positive Z when tilted toward me
#  - more negative X when tilted to the right
#  - more positive X when tilted to the left
#  - the 'y' value doesn't change in an interesting way

use strict;
use warnings;
use Getopt::Long;
use Time::HiRes qw( sleep );

my $me = "roomba-tilt.pl";
my $verbose = 1;

sub roomba_init  {
    my ($fullmode) = @_;
    $fullmode ||= 0;  # default
    print "[start]";  sleep 0.1;                    # START
    print "[control]";  sleep 0.1;                    # CONTROL
    if( $fullmode ) { print "[full]\n"; sleep 0.5; } # FULL
}

sub roomba_drive($$$) {
    my ($roomba,$vel,$rad) = @_;
    my $vh = ($vel>>8)&0xff;  my $vl = ($vel&0xff);
    my $rh = ($rad>>8)&0xff;  my $rl = ($rad&0xff);
    print "[drive vh: $vh vl: $vl rh: $rh rl: $rl ]\n", $vh,$vl,$rh,$rl;      # DRIVE + 4 databytes
}
sub roomba_forward($) {
    my ($roomba) = @_;
     print "[Forward]\n";
}
sub roomba_backward($) {
    my ($roomba) = @_;
     print "[Backward]\n";
}
sub roomba_spinleft($) {
    my ($roomba) = @_;
     print "[Left]\n";
}
sub roomba_spinright($) {
    my ($roomba) = @_;
     print "[Right]\n";
}
sub roomba_stop($) {
    my ($roomba) = @_;
     print "[Stop]\n";
}

my $tracker_path='./AMSTracker';
my $deadzone = 15;
my $update_rate = "0.25";
my $help = 0;
my $fourway = 0;  # old binary mode
my $fullmode = 0;
my $rc = GetOptions( 
                     'fourway' => \$fourway,
                     'full|fullmode'    => \$fullmode,
                     'deadzone=i' => \$deadzone,
                     'update_rate=f' => \$update_rate,
                     'verbose+' => \$verbose,
                     'help' => \$help,
                     'tracker=s' => \$tracker_path,
                     );
my $tracker_url = 'http://www.osxbook.com/software/sms/amstracker/';
if( !$tracker_path ) {
    $tracker_path = `which AMSTracker`; chomp $tracker_path;
    if( $tracker_path =~ /not found/ ) {
        print "Could not find AMSTracker.\n";
        print "Please download it from\n   $tracker_url\n";
        print "And put it in your PATH\n";
        exit(1);  
    }
}

my $roomba;
if( $fullmode ) {
    $roomba = roomba_init(1);
} else { 
    $roomba = roomba_init();
}

my ($vel,$rad);
open(ACCELDATA, "$tracker_path -u $update_rate -s |") or die "no tracker: $!";
#select ACCELDATA; $|=1;  # make unbuffered
select STDOUT; $|=1;     # make unbuffered
print "$me running ". ($fourway?"(fourway)":"") .", press ctrl-c to exit\n";
while(<ACCELDATA>) {
    chomp;
    if( /(-?\d+)\s+(-?\d+)\s+(-?\d+)/ ) {
        my ($x,$y,$z) = ($1,$2,$3);
        print "x:$x, y:$y, z:$z\n" if($verbose);
        if( $fourway ) {  # boolean drive, like a D-pad
            if( $x < -$deadzone ) { 
                roomba_spinright($roomba);
            } elsif( $x > $deadzone ) {
                roomba_spinleft($roomba);
            } elsif( $z < -$deadzone ) {
                roomba_forward($roomba);
            } elsif( $z > $deadzone ) {
                roomba_backward($roomba);
            } else {
                roomba_stop($roomba);
            }
        } 
        else {            # proportional drive, like an analog stick
            if( abs($x) < $deadzone && abs($z) < $deadzone ) {
                roomba_stop($roomba);             # in deadzone, so stop
            }
            elsif( abs($z) < $deadzone ) {        # no back-forth,spin in place
                $vel = 50 + abs($x)*3;
                $rad = ($x>0) ? 0x0001 : 0xffff;  # spin left or right
                roomba_drive($roomba, $vel, $rad);
            }
            else {
                $vel = -$z * 5;    # these equations empirically determined
                $rad = ($x>0) ? 762 -($x*6) : -762-($x*6);
                roomba_drive($roomba, $vel, $rad);
            }
        }
    }
}

close ACCELDATA or die "bad $tracker_path: $!";


