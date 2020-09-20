package EPrints::Plugin::InputForm::Surround::WRNone;

use strict;
our @ISA = qw/EPrints::Plugin/;

package EPrints::Plugin::InputForm::Surround::None;

use strict;
no warnings 'redefine';

sub render
{
	my( $self, $component ) = @_;

	my $surround = $self->{session}->make_element( "div", class => "ep_sr_none", id => $component->{prefix} );
	$surround->appendChild( $self->{session}->make_element( "a", name=>$component->{prefix} ) );
	foreach my $field_id ( $component->get_fields_handled )
	{
		$surround->appendChild( $self->{session}->make_element( "a", name=>$field_id ) );
	}

	$surround->appendChild( $component->render_content( $self ) );

	return $surround;
}

1;
