#!/usr/bin/perl
#
# geoloc_media.pl
# 
# 
# Changes by danbri@danbri.org from original (by @@jo/schuyler/???...)
#
# -added use of Geo::Coordinates::DecimalDegrees to get EXIF-friendly
# -using Image::ExifTool instead of Image::EXIF so we can write into EXIF
#  (controlled with $make_tagged_jpgs)

# Example usage:
# ../../bin/geoloc_media.pl 0 http://rdfweb.org/people/danbri/media/2005/07/  \
# 	../../mydata/2005-08-03-Tracks.gpx danbri@foaf-project.org \
# 	2005-08-03-walk/*.jpg > 2005-08-03-walk.rdf

#
# nearby docs:
# http://search.cpan.org/~exiftool/Image-ExifTool-5.46/lib/Image/ExifTool.pod#SYNOPSIS
# http://search.cpan.org/~waltman/Geo-Coordinates-DecimalDegrees-0.04/DecimalDegrees.pm
# http://search.cpan.org/~exiftool/Image-ExifTool-5.46/lib/Image/ExifToolTagNames.pod#GPS_Tags

use RDF::Simple::Serialiser;
use Time::Piece;
use Geo::Track::Log;
use strict;
use warnings;
use Image::ExifTool; 			# added by danbri
use Geo::Coordinates::DecimalDegrees;   # added by danbri (used for EXIF GPS)
my $make_tagged_jpgs=1; # emit .JPEGs with GPS fields in the EXIF (experimental)

die "Usage: $0 <offset> <base href> <track.gpx> <maker\@email.com> <files.jpg> ...\nOffset can take the form [+-]3h2m1s etc.\n\n"
	unless @ARGV >= 5;

my $offset = parse_duration(shift);
my $base  = shift;
my $gpx_track = shift;
my $maker_email = shift;
my @files = map(glob, @ARGV);

my $s = RDF::Simple::Serialiser->new;
$s->ns->lookup('locative' => 'http://locative.net/2004/packet#');

my $log = Geo::Track::Log->new;
$log->loadTrackFromGPX($gpx_track);

my @rdf = ();
my $person_id = $s->genid;

push @rdf, [$person_id,'rdf:type','foaf:Person'];
push @rdf, [$person_id, 'foaf:mbox', 'mailto:'.$maker_email];
push @rdf, geoloc_images(\@files, $log, $offset); 
print $s->serialise(@rdf);

sub geoloc_images {
	my ($images,$log,$offset) = @_;
	my $exifTool = new Image::ExifTool; 
	my @triples;

	foreach my $img (@$images) {

		my $imgfile = $img;
		# print STDERR "Imgfile: $imgfile\n"; # swapped EXIF APIs. old:
		# $exif->file_name($img);
		# my $i = $exif->get_image_info() or next;
		# my $created = $i->{'Image Created'} or next;

		# We're now using EXIF::ExifTool API, as it is read/write:
		#
		$exifTool->ExtractInfo($imgfile) or next; # ..or next?
		my @taglist = $exifTool->GetFoundTags('File');
		# print STDERR "EXIFTool found tags: ".join(" ; ", @taglist);
		my $created = $exifTool->GetValue('CreateDate') or next;
		print STDERR "Created was: $created\n\n";

		# exif date format looks like '2004:08:28 08:34:45'

		my $t = Time::Piece->strptime($created, "%Y:%m:%d %H:%M:%S");

		# add time offset to time here, if applicable.

		$t = $t + $offset if $offset;		
		my $logtime = $t->strftime("%Y-%m-%d %H:%M:%S");
		# worry about UTC or timezone specification?	
		my $icaltime = $t->strftime("%Y%m%dT%H%M%S");


		my ($approx,$previous,$next) = $log->whereWasI($logtime);
			

		my $pkt = $s->genid;
		$img =~ s/^\/?/$base/os;
		push @triples, [$img,'ical:datetime',$icaltime];
		push @triples, [$img,'foaf:maker',$person_id];
		push @triples, [$pkt,'locative:media',$img];
		push @triples, [$pkt,'geo:lat',$approx->{lat}];
		push @triples, [$pkt,'geo:long',$approx->{long}];
		push @triples, [$pkt,'rdf:type','locative:Packet'];		
		## TODO: emit RDF EXIF here, [er
		# http://www.w3.org/2003/12/exif/ (need example!)
		# http://www.kanzaki.com/test/exif2rdf (ah, examples...)
		# see also related work, eg:
		# http://nwalsh.com/java/jpegrdf/jpegrdf.html
		# http://norman.walsh.name/2004/05/16/images/20040514-173117.html
		
		# WARNING: this might damage data. !! # #  ! # !! !# !! # ! # !#
		# (except that we're writing out foo.jpg into foo-geotagged.jpg )
		my ($degrees, $minutes, $seconds); 


		# "Must be a positive number for GPS:GPSLongitude" error
		# hence we flip N/S, E/W as the numbers must be +ve

		# set latitude
		my $north_or_south='North'; # default
		my $lat=$approx->{'lat'};
		if ($lat < 0) {
			$north_or_south='South';
			$lat = abs($lat);
		} # pesky Australians, etc.
		($degrees, $minutes, $seconds) = decimal2dms($lat);
		print STDERR "Lat: $lat\nlat: $degrees, $minutes, $seconds \n\n";
		$exifTool->SetNewValue('GPSLatitude', "$degrees, $minutes, $seconds");
		
		# set longitude
		my $long=$approx->{long};
		my $east_or_west='East'; # default
		if ($long < 0) {
			$east_or_west='West';
			$long = abs($long);
		}
	 	($degrees, $minutes, $seconds) = decimal2dms($long);
		print STDERR "Long: $long\nlong: $degrees, $minutes, $seconds \n";
		$exifTool->SetNewValue('GPSLongitude', "$degrees, $minutes, $seconds");

		print STDERR "\n\n";

		# OK let's add in other stuff, mindlessly copying Dav's example below.
		# CPAN has tag names...
		# http://search.cpan.org/~exiftool/Image-ExifTool-5.46/lib/Image/ExifTool/TagNames.pod#GPS_Tags
		$exifTool->SetNewValue( 'GPSLatitudeRef', $north_or_south);
		$exifTool->SetNewValue( 'GPSLongitudeRef', $east_or_west);
		$exifTool->SetNewValue( "GPSMapDatum", "WGS-84");

		# here we get stuck, with datatype/value encoding ignorance
		# hopefully we can flesh this out later, and tools won't mind ommissions.
		# $exifTool->SetNewValue( 'GPSAltitudeRef', "Above Sea Level"); # -> integer?
		# GPS Time Stamp                  : 22:29:14
		# GPS Processing Method           : HYBRID-FIX
		# GPS Date Stamp                  : 2003:05:24
		# GPS Date/Time                   : 2003:05:24 22:29:14

		# avoid recursive mess
		if ($make_tagged_jpgs && (!$imgfile =~ m/-geotagged\.jpg/) ) {
			my $newfile = $imgfile;
			$newfile =~ s/\.jpg/-geotagged.jpg/;
			print STDERR "WriteInfo: $imgfile -> $newfile\n\n";
			my $worked = $exifTool->WriteInfo($imgfile, $newfile);
			print STDERR "return code: $worked\n";
			if (!$worked) {
   				print STDERR "[$worked] - failed to write image.";
				#   print $exifTool->GetValue('Error');
			}
		}	
		## end danbri addons

		if ((my $thumb = $img) =~ s/-l.jpg/-s.jpg/ios) {
		    push @triples, [$img,'foaf:thumbnail',$thumb];
		}
	}
	return @triples;
}	

sub parse_duration {
    my $duration = shift;
    my %units = ( d => 86400, h => 3600, m => 60, s => 1 );
    my $sum = 0;
    while ($duration =~ s/(\d+)([dhms])//ios) {
	$sum += $1 * $units{lc $2};	
    }	
    $sum += $1 if $duration =~ /(\d+)/os;
    $sum = -$sum if $duration =~ /-/os;
    return $sum;
}


# looking for something to copy...

# http://akuaku.org/archives/2003/05/gps_tagged_jpeg.shtml
# http://akuaku.org/hiptop_images/default/2003-05-24_115510_28166_0.jpg
# exiftool 2003-05-24_115510_28166_0.jpg| grep GPS
# gives: 
# GPS Version ID                  : 2.2.0.0
# GPS Latitude Ref                : North
# GPS Latitude                    : 35 deg 36' 57.67"
# GPS Longitude Ref               : East
# GPS Longitude                   : 139 deg 41' 50.34"
# GPS Altitude Ref                : Above Sea Level
# GPS Altitude                    : 78 metres
# GPS Time Stamp                  : 22:29:14
# GPS Map Datum                   : WGS-84
# GPS Processing Method           : HYBRID-FIX
# GPS Date Stamp                  : 2003:05:24
# GPS Date/Time                   : 2003:05:24 22:29:14



# from dirk, un-integrated as of now:

# while(my $deg = shift @ARGV) {
#         print join('/',wack($deg,360));
# };
#
# "You propably need something like below to make sure that you use strict 
# 0..90 and 0..180 with N/S or E/W values. Some of the (propably TIFF
# derived) code otherwise chokes."


sub wack {
        my ($deg, $max) = (@_);
        my $dir = 1;

        if ($deg < 0) {
                $deg = -$deg;
                $dir = -$dir;
        };

        while ($deg > $max) {
                $deg -= $max;
        };

        if ($deg > $max / 2) {
                $dir = -$dir;
                $deg = $max - $deg;
        };
        return ($deg, $dir);
};




