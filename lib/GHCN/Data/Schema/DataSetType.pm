package GHCN::Data::Schema::DataSetType;
use base qw(DBIx::Class);

use strict;
use warnings;

__PACKAGE__->load_components(qw( +GHCN::Data::Component::Base Core ));
__PACKAGE__->table('data_set_type');
__PACKAGE__->add_columns(qw(
	id
	name
));
__PACKAGE__->set_primary_key(qw(id));

1;