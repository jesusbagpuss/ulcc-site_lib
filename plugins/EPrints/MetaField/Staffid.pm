# Field contains a staff identifier of some sort (as specified in $c->{staffid_field})

package EPrints::MetaField::Staffid;

use strict;

use EPrints::MetaField::Id;

BEGIN
{
	our( @ISA );
	@ISA = qw( EPrints::MetaField::Id );
}

sub get_value_label
{
	my( $self, $repo, $value ) = @_;

	my $user = $self->_get_user( $repo, $value );
	if( defined $user )
	{
		return $repo->make_text( EPrints::Utils::make_name_string( $user->value( "name" ) ) );
	}

	return $repo->make_text( $value );
}

sub ordervalue_basic
{
	my( $self, $value, $repo, $langid ) = @_;

	my $user = $self->_get_user( $repo, $value );
	return $value unless defined $user;

	return $repo->dataset( "user" )->field( "name" )->ordervalue_basic( $user->value( "name" ), $repo, $langid );
}

sub render_single_value
{
	my( $self, $repo, $value ) = @_;

	return $self->get_value_label( $repo, $value );
}

sub _get_user
{
	my( $self, $repo, $id ) = @_;

	return undef unless EPrints::Utils::is_set( $id );

	my $id_fieldname = $repo->config( "staffid_field" ) || "staffid";

	my $list = $repo->dataset( "user" )->search(
		filters => [
			{ meta_fields => [ $id_fieldname ], value => $id, match => "EX" },
		],
	);

	if( $list->count > 0 )
	{
		return ($list->get_records( 0,1 ))[0];
	}

	return undef;
}

1;
