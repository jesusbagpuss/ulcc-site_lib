# for search results, and counts, it's better to hide documents here.
package EPrints::Plugin::HiddenDocs;

use strict;

our @ISA = qw/ EPrints::Plugin /;

package EPrints::Script::Compiled;

sub run_documents_not_hidden
{
        my( $self, $state, $eprint ) = @_;

        if( ! $eprint->[0]->isa( "EPrints::DataObj::EPrint") )
        {
                $self->runtime_error( "documents_not_hidden() must be called on an eprint object." );
        }
        return [ [$eprint->[0]->get_all_documents_not_hidden()],  "ARRAY" ];
}

package EPrints::DataObj::EPrint;

sub get_all_documents_not_hidden
{
	my( $self ) = @_;

	my @docs;

	# Filter out any documents that are volatile versions
	foreach my $doc (@{($self->value( "documents" ))})
	{
		next if $doc->has_relation( undef, "isVolatileVersionOf" );
		next if $doc->get_value( "security" ) eq "hidden";
		push @docs, $doc;
	}
 
	my @sdocs = sort { ($a->get_value( "placement" )||0) <=> ($b->get_value( "placement" )||0) || $a->id <=> $b->id } @docs;
	return @sdocs;

}

1;
