package EPrints::MetaField::MD5;

use strict;
use warnings;

use EPrints::MetaField::Id;

BEGIN
{
	our( @ISA );
	@ISA = qw( EPrints::MetaField::Id );
}

sub _get_name
{
	my( $self, $repo, $md5 ) = @_;

	# no dataobj :-/
	my $list = $repo->dataset("eprint")->search(	
                filters => [
                        {
                                meta_fields => [qw( users_id )],
                                value => $md5,
                                match => "EX"
                        },
		]
	);

	my $eprint = ($list->get_records( 0, 1 ))[0];
	my @users = defined $eprint ? @{$eprint->value("users")} : [];
	for( @users )
	{
		next unless $_->{id} eq $md5;
		return EPrints::Utils::make_name_string($_->{name});
	}

	return $md5;
}

sub get_value_label
{
	my( $self, $repo, $value ) = @_;

	return $repo->make_text( $self->_get_name( $repo, $value ) );
}

sub ordervalue_basic
{
	my( $self, $value, $repo, $langid ) = @_;

	return $self->_get_name( $repo, $value );
}

sub render_single_value
{
	my( $self, $repo, $value ) = @_;

	return $self->get_value_label( $repo, $value );
}

1;
