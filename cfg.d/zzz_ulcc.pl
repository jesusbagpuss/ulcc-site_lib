# disable registration by default
$c->{allow_web_signup} = 0;
$c->{plugins}->{"Screen::Register"}->{actions}->{register}->{appears}->{key_tools} = undef;

# removing the default order makes simple search revert to 'by relevance'
$c->{search}->{simple}->{default_order} = undef;

# add generic staffid field to user dataset
push @{ $c->{fields}->{user} },
{
	name => "staffid",
	type => "id"
}
;

# never timeout browse view cache
for( @{ $c->{browse_views} } )
{
    $_->{max_menu_age} = 9**9**9; # inf
    $_->{max_list_age} = 9**9**9; # inf
}
