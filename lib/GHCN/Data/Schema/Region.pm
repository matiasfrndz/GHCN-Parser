package GHCN::Data::Schema::Region;
use base qw(DBIx::Class);

use strict;
use warnings;

__PACKAGE__->load_components(qw( +GHCN::Data::Component::Base Core ));
__PACKAGE__->table('region');
__PACKAGE__->add_columns(qw(
	id
	name
));
__PACKAGE__->set_primary_key(qw(id));
__PACKAGE__->has_many(
	countries => 'GHCN::Data::Schema::Country', 
	'id_region',
	{cascade_delete => 0}
);
1;