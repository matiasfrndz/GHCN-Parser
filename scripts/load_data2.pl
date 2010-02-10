#!/opt/local/bin/perl

use strict;
use warnings;

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
			january => ($6 eq '-9999') ? undef : $6 / 10.0,
			february => ($7 eq '-9999') ? undef : $7 / 10.0,
			march => ($8 eq '-9999') ? undef : $8 / 10.0,
			april => ($9 eq '-9999') ? undef : $9 / 10.0,
			may => ($10 eq '-9999') ? undef : $10 / 10.0,
			june => ($11 eq '-9999') ? undef : $11 / 10.0,
			july => ($12 eq '-9999') ? undef : $12 / 10.0,
			august => ($13 eq '-9999') ? undef : $13 / 10.0,
			september => ($14 eq '-9999') ? undef : $14 / 10.0,
			october => ($15 eq '-9999') ? undef : $15 / 10.0,
			november => ($16 eq '-9999') ? undef : $16 / 10.0,
			december => ($17 eq '-9999') ? undef : $17 / 10.0
		});
	}
	print "$num_records records imported\n";
  $fh->close();
}

sub check_country {
	my ($id) = @_;

	my $rs_country = GHCN::Data->schema()->resultset('Country');
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
