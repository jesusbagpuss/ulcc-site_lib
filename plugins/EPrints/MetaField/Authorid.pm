######################################################################
#
# EPrints::MetaField::Authorid;
#
######################################################################

package EPrints::MetaField::Authorid;

use strict;
use warnings;

use EPrints::MetaField::Text;

BEGIN
{
        our( @ISA );
        @ISA = qw( EPrints::MetaField::Text );
}

sub _get_name
{
        my( $self, $session, $user ) = @_;

        if( $session->dataset( "user" )->has_field( "display_name" ))
        {
                return $user->get_value( "display_name" ) if( $user->is_set( "display_name" ) );
        }
    
        if( $session->dataset( "user" )->has_field( "creators_name" ))
        {
            return $user->get_value( "creators_name" ) if( $user->is_set( "creators_name" ) );
        }

        return $user->get_value( "name" );
}

sub get_value_label
{
        my( $self, $session, $value ) = @_;

        my $user = EPrints::DataObj::User->new( $session, $value );
        if( defined $user )
        {
                return $session->make_text( EPrints::Utils::make_name_string( $self->_get_name( $session, $user ) ) );
        }

        return $session->make_text( $value );
}

sub ordervalue_basic
{
        my( $self, $value, $session, $langid ) = @_;

        my $user = EPrints::DataObj::User->new( $session, $value );
	return $value unless defined $user;

        my $name = $self->_get_name( $session, $user );
        if( EPrints::Utils::is_set( $name ) )
        {
                my @a;
                for( qw( family given lineage honourific ) )
                {
                        if( defined $name->{$_} )
                        {
                                push @a, $name->{$_};
                        }
                        else
                        {
                                push @a, "";
                        }
                }
                my $ov = join( "\t" , @a );
                return $ov;
        }

        return $value;
}

sub render_single_value
{
        my( $self, $session, $value ) = @_;
        return $self->get_value_label( $session, $value );
}

1;

