package GHCN::Data::Schema::DataSet;
use base qw(DBIx::Class);

use strict;
use warnings;

__PACKAGE__->load_components(qw( +GHCN::Data::Component::Base Core ));
__PACKAGE__->table('data_set');
__PACKAGE__->add_columns(qw(
	id
	id_station
	id_data_set_type
	year
	duplicate
	january
	february
	march
	april
	may
	june
	july
	august
	september
	october
	november
	december
));
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
	station => 'GHCN::Data::Schema::Station',
	'id_station'
);
__PACKAGE__->belongs_to(
	data_set_type => 'GHCN::Data::Schema::DataSetType', 
	'id_data_set_type',
);
__PACKAGE__->add_unique_constraint(
	idx_data_set_id_station_id_data_set_type_year_duplicate => [ 
		qw/ id_station id_data_set_type year duplicate /
	]
);

1;