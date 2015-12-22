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
{
	name => "orcid",
	type => "id"
}
;

# never timeout browse view cache
for( @{ $c->{browse_views} } )
{
    $_->{max_menu_age} = 9**9**9; # inf
    $_->{max_list_age} = 9**9**9; # inf
}

# always include archive ID in log messages
$c->{log} = sub
{
	my( $repository, $message ) = @_;

	print STDERR "[".$repository->get_id()."] ".$message."\n";
};

# disable multiple confusing feed options
$c->{plugins}->{"Export::RSS"}->{params}->{disable} = 1;
$c->{plugins}->{"Export::Atom"}->{params}->{disable} = 1;
$c->{plugins}->{"Export::RSS2"}->{params}->{name} = "RSS";
