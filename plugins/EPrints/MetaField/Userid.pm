# Field contains a user.userid and is rendered/ordered using the corresponding name

package EPrints::MetaField::Userid;

use strict;

use EPrints::MetaField::Text;

BEGIN
{
	our( @ISA );
	@ISA = qw( EPrints::MetaField::Text );
}

sub get_value_label
{
	my( $self, $repo, $value ) = @_;

	my $user = $repo->dataset( "user" )->dataobj( $value );
	if( defined $user )
	{
		return $repo->make_text( EPrints::Utils::make_name_string( $user->value( "name" ) ) );
	}

	return $repo->make_text( $value );
}

sub ordervalue_basic
{
	my( $self, $value, $repo, $langid ) = @_;

	my $user = $repo->dataset( "user" )->dataobj( $value );
	return $value unless defined $user;

	return $repo->dataset( "user" )->field( "name" )->ordervalue_basic( $user->value( "name" ), $repo, $langid );
}

sub render_single_value
{
	my( $self, $repo, $value ) = @_;

	return $self->get_value_label( $repo, $value );
}

1;
