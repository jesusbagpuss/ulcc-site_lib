######################################################################
#
# EPrints::MetaField::Authoremail;
#
######################################################################

package EPrints::MetaField::Authorstaffid;

use strict;
use warnings;

use EPrints::MetaField::Text;

BEGIN {
    our (@ISA);
    @ISA = qw( EPrints::MetaField::Text );
}

sub _get_name {
    my ( $self, $session, $value ) = @_;
    
   return "" unless ( EPrints::Utils::is_set($value) );
    
   return $value if(!defined $self->{parent_name}); #Authorstafid only really any use as part of a compound

    my $name = $value;
    my $ds = $session->dataset("eprint");
    my $searchexp = $ds->prepare_search();
    my $field = $ds->field($self->get_name);
    $searchexp->add_field(
        fields => [ $field ],
        value  => $value,
        match  => "EQ",
    );

    my $eprint = $searchexp->perform_search->item(0);
    if ( defined $eprint ) {
	my $parent_name = $self->{parent_name};
	my $sub_name = $self->{sub_name};
	for my $item ( @{ $eprint->get_value($parent_name) } ) {
	    if ( defined $item->{$sub_name} ) {
		if ( $item->{$sub_name} eq $value ) {
		    #NB : this assumes that the aprent compound has a sub field called "name"
		    $name = EPrints::Utils::make_name_string( $item->{name} );
		}
	    }
	}
    }
    return $name;
}

sub get_value_label {
    my ( $self, $session, $value ) = @_;
    my $name = $self->_get_name( $session, $value );
    return $session->make_text($name);
}

sub ordervalue_basic {
    my ( $self, $value, $session, $langid ) = @_;
    my $name = $self->_get_name( $session, $value );
    return $name;
}

sub render_single_value {
    my ( $self, $session, $value ) = @_;
    return $self->get_value_label( $session, $value );
}

1;


