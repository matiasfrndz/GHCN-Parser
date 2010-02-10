package GHCN::Data::Schema::Station;
use base qw(DBIx::Class);

use strict;
use warnings;

__PACKAGE__->load_components(qw( +GHCN::Data::Component::Base Core ));
__PACKAGE__->table('station');
__PACKAGE__->add_columns(qw(
	id
	id_country
	wmo_number
	modifier
	name
	latitude
	longitude
	elevation1
	elevation2
	population_assessment
	population
	topography
	vegetatation
	location
	coast_distance
	airport
	town_distance
	temperature
	precipitation
));
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
	country => 'GHCN::Data::Schema::Country',
	'id'
);
__PACKAGE__->has_many(
	data_sets => 'GHCN::Data::Schema::DataSet', 
	'id_station',
	{cascade_delete => 0}
);
__PACKAGE__->add_unique_constraint(
	idx_station_wmo_number_modifier => [ qw/ wmo_number modifier / ],
);

1;