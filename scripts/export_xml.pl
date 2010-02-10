#!/opt/local/bin/perl

use strict;
use warnings;

use lib qw(
	../lib/
);

use GHCN::Data;
use XML::LibXSLT;
use XML::LibXML;

$| = 1;

my $db_config = {
  driver => 'mysql',
  db_name => 'ghcn',
  host => 'localhost',
  username => 'ghcn',
  password => 'ghcnpwd'
}

my $schema = GHCN::Data->get_schema($db_config);
my $rs_station = $schema->resultset('Station');
my $rs_data_set = $schema->resultset('DataSet');
my $rs_data_set_type = $schema->resultset('DataSetType');

my $document = XML::LibXML->createDocument("1.0", "UTF-8");
my $root = $document->createElement('ghcn');
$document->setDocumentElement($root);

my $counter = 0;
my $station;
while($station = $rs_station->next()) {
	my $station_element = $station->to_dom();
	++$counter;
#	last if ($counter == 200);
	print "exporting stations as xml ... ($counter)\r";
	foreach($rs_data_set_type->all()) {
		my $rs = $station->data_sets()->search({
				id_data_set_type => $_->id()
			}, {
				select => [ { avg => 'january' }, { avg => 'february' }, { avg => 'march' }, { avg => 'april' }, { avg => 'may' }, { avg => 'june' }, { avg => 'july' }, { avg => 'august' }, { avg => 'september' }, { avg => 'october' }, { avg => 'november' }, { avg => 'december' } ],
				as     => [ 'january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december' ]
		});
		my $avg = $rs->first()->to_dom();
		$avg->setAttribute('type', $_->name());
		$station_element->appendChild($avg);
	}

	$root->appendChild($station_element);
}
print "exporting stations as xml ... ($counter) done.\n";

print "writing xml to file ... ";
$document->toFile("stations.xml",1);
print "done.\n";

my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();

my $style_doc = $parser->parse_file('kml.xsl');

my $stylesheet = $xslt->parse_stylesheet($style_doc);

print "transforming xml to kml ... ";
my $results = $stylesheet->transform($root);
print "done.\n";

print "writing kml to file ... ";
print $stylesheet->output_file($results, 'stations.kml');
print "done.\n";
