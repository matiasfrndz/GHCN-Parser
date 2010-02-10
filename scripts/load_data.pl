#!/opt/local/bin/perl

use strict;
use warnings;

use IO::File;

use lib qw(
	../lib/
);

use GHCN::Data;

############################################################################
# get data from: ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/v2/
#
# files:
# v2.country.codes
# v2.prcp.inv
# v2.temperature.inv
#
# zipped files: (please unzip)
# v2.max.Z
# v2.mean.Z
# v2.min.Z
# v2.prcp.Z
#
############################################################################

$| = 1; # disable output buffering

my $countries_file = 'v2.country.codes';
my $prcp_stations_file = 'v2.prcp.inv';
my $temp_stations_file = 'v2.temperature.inv';

my $max_temps_file = 'v2.max';
my $mean_temps_file = 'v2.mean';
my $min_temps_file = 'v2.min';
my $prcp_temps_file = 'v2.prcp';

my $db_config = {
  driver => 'mysql',
  db_name => 'ghcn',
  host => 'localhost',
  user => 'ghcn',
  password => 'ghcnpwd'
};

my $schema = GHCN::Data->get_schema($db_config);

my $rs_country = $schema->resultset('Country');
$rs_country->delete();
my $fh = IO::File->new("< $countries_file") or die("could not open $countries_file");
print "loading countries from '$countries_file'\n";
while(my $line = $fh->getline()) {
	$line =~ m/(\d)(\d{2})\s(.*)/;
	$rs_country->create({
		id => ($1 . $2) + 0,
		id_region => $1,
		name => trim($3)
	});
}
$fh->close();

my $rs_station = $schema->resultset('Station');
$rs_station->delete();
$fh = IO::File->new("< $prcp_stations_file") or die("could not open $prcp_stations_file");
print "loading precipitation stations from '$prcp_stations_file'\n";
while(my $line = $fh->getline()) {
	chomp($line);
	$line =~ m/			# station number (i11)
			(.{3})		# country code (i3.3)
			(.{5})		# wmo station number (i5.5)
			(.{3})		# digit modifier (i3.3)
			.			# space (1x)
			(.{20})		# station name (a20)
			(.{10})		# country (a10)
			(.{7})		# latitude (f7.2)
			(.{8})		# longitude (f8.2)
			(.{5})		# elevation in meters (i5)
			/x;

	my $name =
	$rs_station->create({
		id => ($2 . $3) + 0,
		id_country => $1,
		wmo_number => $2,
		modifier => $3,
		name => trim($4),
		latitude => $6,
		longitude => $7,
		elevation1 => (($8 * 1) == -999) ? undef : $8,
		precipitation => 1
	});
}
$fh->close();

my $suspicious_entries = 0;

$fh = IO::File->new("< $temp_stations_file") or die("could not open $temp_stations_file");
print "loading temperature stations from '$temp_stations_file'\n";
while(my $line = $fh->getline()) {
	chomp($line);
# ic		i3.3 	digit country code; the first digit represents WMO region/continent
# iwmo		i5.5	digit WMO station number
# imod		i3.3	digit modifier; 000 means the station is probably the WMO
# 					station; 001, etc. mean the station is near that WMO station
# space		1x
# name		a30		character station name
# space 	1x
# rlat		f6.2	latitude in degrees.hundredths of degrees, negative = South of Eq.
# space		1x
# rlong		f7.2	longitude in degrees.hundredths of degrees, - = West
# space		1x
# ielevs	i4		station elevation in meters, missing is -999
# space		1x
# ielevg	i4		station elevation interpolated from TerrainBase gridded data set
# pop		a1		character population assessment:  R = rural (not associated
# 					with a town of >10,000 population), S = associated with a small
# 					town (10,000-50,000), U = associated with an urban area (>50,000)
# ipop		i5		population of the small town or urban area (needs to be multiplied
# 					by 1,000).  If rural, no analysis:  -9.
# topo		a2		general topography around the station:  FL flat; HI hilly,
# 					MT mountain top; MV mountainous valley or at least not on the top
# 					of a mountain.
# stveg		a2		general vegetation near the station based on Operational
# 					Navigation Charts;  MA marsh; FO forested; IC ice; DE desert;
# 					CL clear or open;
# 					not all stations have this information in which case: xx.
# stloc		a2		station location based on 3 specific criteria:
# 					Is the station on an island smaller than 100 km**2 or
# 						narrower than 10 km in width at the point of the
# 						station?  IS;
# 					Is the station is within 30 km from the coast?  CO;
# 					Is the station is next to a large (> 25 km**2) lake?  LA;
# 					A station may be all three but only labeled with one with
# 						the priority IS, CO, then LA.  If none of the above: no.
# iloc		i2		if the station is CO, iloc is the distance in km to the coast.
# 					If station is not coastal:  -9.
# airstn	a1		A if the station is at an airport; otherwise x
# itowndis	i2		the distance in km from the airport to its associated
# 					small town or urban center (not relevant for rural airports
# 					or non airport stations in which case: -9)
# grveg		a16		gridded vegetation for the 0.5x0.5 degree grid point closest
# 					to the station from a gridded vegetation data base. 16 characters.
	$line =~ m/(.{3})    # ic
			(.{5})    # iwmo
			(.{3})    # imod
			.         # space
			(.{30})   # name
			.         # space
			(.{6})    # rlat
			.         # space
			(.{7})    # rlong
			.         # space
			(.{4})    # ielevs
			.         # space
			(.{4})    # ielevg
			(.)       # pop
			(.{5})    # ipop
			(.{2})    # topo
			(.{2})    # stveg
			(.{2})    # stloc
			(.{2})    # iloc
			(.)       # airstn
			(.{2})    # itowndis
			(.{16})   # grveg
			(.)       # ?
			/x;

	my $station = $rs_station->find( ($2 . $3) + 0 );

	if($station) {
		my $lat = $5 * 1.0;
		my $lng = $6 * 1.0;
		my $tolerance = 0.5;
		unless ($station->latitude() == $lat and $station->longitude() == $lng) {
			if ((abs($lat - $station->latitude()) > $tolerance) or (abs($lng - $station->longitude()) > $tolerance)) {
				$suspicious_entries++;
				print "$1 $2 $3: $lat / $lng versus " . $station->latitude() . "/" . $station->longitude() . "\n";
			}
		}
		$station->set_columns({
			elevation2 => (($8 * 1) == -999) ? undef : $8,
			population_assessment => $9,
			population => (($10 * 1) == -9) ? undef : $10,
			topography => $11,
			vegetatation => ($12 eq 'xx') ? undef : $12,
			location => $13,
			coast_distance => (($14 * 1) == -9) ? undef : $14,
			airport => $15,
			town_distance => (($16 * 1) == -9) ? undef : $16,
			temperature => 1
		});
		$station->update();
	} else {
		check_country($1);
		$rs_station->create({
			id => ($2 . $3) + 0,
			id_country => $1,
			wmo_number => $2,
			modifier => $3,
			name => trim($4),
			latitude => $5,
			longitude => $6,
			elevation1 => (($7 * 1) == -999) ? undef : $7,
			elevation2 => (($8 * 1) == -999) ? undef : $8,
			population_assessment => $9,
			population => (($10 * 1) == -9) ? undef : $10,
			topography => $11,
			vegetatation => ($12 eq 'xx') ? undef : $12,
			location => $13,
			coast_distance => (($14 * 1) == -9) ? undef : $14,
			airport => $15,
			town_distance => (($16 * 1) == -9) ? undef : $16,
			temperature => 1
		});
	}
}
$fh->close();

print "found $suspicious_entries suspicious entries\n";

$schema->resultset('DataSet')->delete();

my $rs_data_set_type = $schema->resultset('DataSetType');
my $max_type = $rs_data_set_type->find({name => 'max_temperature'});
my $min_type = $rs_data_set_type->find({name => 'min_temperature'});
my $mean_type = $rs_data_set_type->find({name => 'mean_temperature'});
my $prcp_type = $rs_data_set_type->find({name => 'precipitation'});

read_data_file($mean_temps_file, $mean_type);
read_data_file($min_temps_file, $min_type);
read_data_file($max_temps_file, $max_type);
read_data_file($prcp_temps_file, $prcp_type);

sub read_data_file {
	my ($file, $data_set_type) = @_;

	my $rs_data_set = $schema->resultset('DataSet');

	my $regexp = "
				(.{3})		# country code (i3.3)
				(.{5})		# wmo station number (i5.5)
				(.{3})		# digit modifier (i3.3)
				(.{1})      # duplicates
				(.{4})      # year
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				(.{5})		#
				";

	my $num_records = 0;
	my $fh = IO::File->new("< $file") or die("could not open $file");
	print "reading '$file' ... ";
  while(my $line = $fh->getline()) {
    chomp($line);
		$num_records++;
		$line =~ m/$regexp/x;
		check_station($1, ($2 . $3) + 0, $data_set_type);
		$rs_data_set->create({
			id_station => ($2 . $3) + 0,
			id_data_set_type => $data_set_type->id(),
			duplicate => $4,
			year => $5,
			january => ($6 eq '-9999') ? undef : ($6 eq '-8888') ? 0 : $6 / 10.0,
			february => ($7 eq '-9999') ? undef : ($7 eq '-8888') ? 0 : $7 / 10.0,
			march => ($8 eq '-9999') ? undef : ($8 eq '-8888') ? 0 : $8 / 10.0,
			april => ($9 eq '-9999') ? undef : ($9 eq '-8888') ? 0 : $9 / 10.0,
			may => ($10 eq '-9999') ? undef : ($10 eq '-8888') ? 0 : $10 / 10.0,
			june => ($11 eq '-9999') ? undef : ($11 eq '-8888') ? 0 : $11 / 10.0,
			july => ($12 eq '-9999') ? undef : ($12 eq '-8888') ? 0 : $12 / 10.0,
			august => ($13 eq '-9999') ? undef : ($13 eq '-8888') ? 0 : $13 / 10.0,
			september => ($14 eq '-9999') ? undef : ($14 eq '-8888') ? 0 : $14 / 10.0,
			october => ($15 eq '-9999') ? undef : ($15 eq '-8888') ? 0 : $15 / 10.0,
			november => ($16 eq '-9999') ? undef : ($16 eq '-8888') ? 0 : $16 / 10.0,
			december => ($17 eq '-9999') ? undef : ($17 eq '-8888') ? 0 : $17 / 10.0
		});
	}
	print "$num_records records imported\n";
	$fh->close();
}

sub check_country {
	my ($id) = @_;

	my $rs_country = GHCN::Data->get_schema($db_config)->resultset('Country');
	my $country = $rs_country->find($id);
	unless($country) {
		print "unknown country: '$id'\n";
		$rs_country->create({
			id => $id,
			id_region => int($id / 100),
			name => 'UNKNOWN'
		});
	}
}

sub check_station {
	my ($id_country, $id, $data_set_type) = @_;

	my $rs_station = GHCN::Data->get_schema($db_config)->resultset('Station');
	my $station = $rs_station->find($id);
	unless($station) {
		print "unknown station: '$id'\n";
		$station = $rs_station->create({
			id => $id,
			id_country => $id_country,
			wmo_number => int($id /1000),
			modifier => ($id % 1000),
			name => 'UNKNOWN',
			latitude => 0.0,
			longitude => 0.0
		});

		if($data_set_type->name() =~ m/temperature$/) {
			$station->temperature(1);
			$station->update();
		} else {
			$station->precipitation(1);
			$station->update();
		}
	}
}

sub trim {
	my $string = shift;

	$string =~ s/^\s*//;
	$string =~ s/\s*$//;

	return $string;
}
