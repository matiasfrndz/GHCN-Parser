package GHCN::Data::Schema::Country;
use base qw(DBIx::Class);

use strict;
use warnings;

__PACKAGE__->load_components(qw( +GHCN::Data::Component::Base Core ));
__PACKAGE__->table('country');
__PACKAGE__->add_columns(qw(
	id
	id_region
	name
));
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->belongs_to(
	region => 'GHCN::Data::Schema::Region',
	'id_region'
);
__PACKAGE__->has_many(
	stations => 'GHCN::Data::Schema::Station', 
	'id_country',
	{cascade_delete => 0}
);

1;