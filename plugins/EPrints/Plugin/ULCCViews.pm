package EPrints::Plugin::ULCCViews;
use strict;
our @ISA = qw/ EPrints::Plugin /;

#override some incongruities in the Views gen code
#specifically to fix the bits that use only the render 
#subs from the *first* menu field. In most cases there 
#is no issue and the value is returned. In *some* cases 
#it is necessary to call the render subs for for each 
#specific field. Loops are added to allow this to happen

package EPrints::Update::Views;

no warnings 'redefine';

sub group_by_n_chars
{
	my( $repo, $menu, $menu_fields, $values, $n ) = @_;

	my $sections = {};
	foreach my $value ( @{$values} )
	{
		#This screws up custom renderng for everything but the first menu_field
#		$v = $repo->xhtml->to_text_dump(
#				$menu_fields->[0]->render_single_value( $repo, $value) );
		my $v;
		for my $field (@{$menu_fields}){
			$v = $repo->xhtml->to_text_dump(
				$field->render_single_value( $repo, $value) );
			last if($v ne $value);
		}
		###########################################################################

		# lose everything not a letter or number
		$v =~ s/\P{Alnum}+//g;
	
		my $start = uc substr( $v, 0, $n );
		$start = "?" if( $start eq "" );	

		push @{$sections->{$start}}, $value;
	}

	return $sections;
}

sub render_menu
{
	my( $repo, $menu, $sizes, $values, $fields, $has_submenu, $view ) = @_;

	if( scalar @{$values} == 0 )
	{
		if( !$repo->get_lang()->has_phrase( "Update/Views:no_items" ) )
		{
			return $repo->make_doc_fragment;
		}
		return $repo->html_phrase( "Update/Views:no_items" );
	}

	my( $cols, $col_len ) = get_cols_for_menu( $menu, scalar @{$values} );
	
	my $add_ul;
	my $col_n = 0;
	my $f = $repo->make_doc_fragment;
	my $tr;

	if( $cols > 1 )
	{
		my $table = $repo->make_element( "table", cellpadding=>"0", cellspacing=>"0", border=>"0", class=>"ep_view_cols ep_view_cols_$cols" );
		$tr = $repo->make_element( "tr" );
		$table->appendChild( $tr );	
		$f->appendChild( $table );
	}
	else
	{
		$add_ul = $repo->make_element( "ul" );
		$f->appendChild( $add_ul );	
	}

	my $ds = $view->dataset;

	for( my $i=0; $i<@{$values}; ++$i )
	{
		if( $cols>1 && $i % $col_len == 0 )
		{
			++$col_n;
			my $td = $repo->make_element( "td", valign=>"top", class=>"ep_view_col ep_view_col_".$col_n );
			$add_ul = $repo->make_element( "ul" );
			$td->appendChild( $add_ul );	
			$tr->appendChild( $td );	
		}
		my $value = $values->[$i];
		my $size = 0;
		my $id = $fields->[0]->get_id_from_value( $repo, $value );
		if( defined $sizes && defined $sizes->{$id} )
		{
			$size = $sizes->{$id};
		}

		next if( $menu->{hideempty} && $size == 0 );

		my $fileid = $fields->[0]->get_id_from_value( $repo, $value );

		my $li = $repo->make_element( "li" );

		#This screws up custom renderng for everything but the first menu_field
#       my $xhtml_value = $fields->[0]->get_value_label( $repo, $value );
		my $xhtml_value;
		for my $field (@{$fields}){
			$xhtml_value = $field->get_value_label( $repo, $value );
			last if(EPrints::XML::to_string($xhtml_value) ne $value);
		}
		###################################################################

		my $null_phrase_id = "viewnull_".$ds->base_id()."_".$view->{id};
		if( !EPrints::Utils::is_set( $value ) && $repo->get_lang()->has_phrase($null_phrase_id) )
		{
			$xhtml_value = $repo->html_phrase( $null_phrase_id );
		}

		if( defined $sizes && (!defined $sizes->{$fileid} || $sizes->{$fileid} == 0 ))
		{
			$li->appendChild( $xhtml_value );
		}
		else
		{
			my $link = EPrints::Utils::escape_filename( $fileid );
			if( $has_submenu ) { $link .= '/'; } else { $link .= '.html'; }
			my $a = $repo->render_link( $link );
			$a->appendChild( $xhtml_value );
			$li->appendChild( $a );
		}

		if( defined $sizes && defined $sizes->{$fileid} )
		{
			$li->appendChild( $repo->make_text( " (".$sizes->{$fileid}.")" ) );
		}
		$add_ul->appendChild( $li );
	}
	while( $cols > 1 && $col_n < $cols )
	{
		++$col_n;
		my $td = $repo->make_element( "td", valign=>"top", class=>"ep_view_col ep_view_col_".$col_n );
		$tr->appendChild( $td );	
	}

	return $f;
}

1;
