# disable registration by default
$c->{allow_web_signup} = 0;
$c->{plugins}->{"Screen::Register"}->{actions}->{register}->{appears}->{key_tools} = undef;

# removing the default order makes simple search revert to 'by relevance'
$c->{search}->{simple}->{default_order} = undef;

#Need to start check for orcid as everyone is trying to add it  these days ;)
my $orcid_present = 0;
for(@{$c->{fields}->{user}}){
	$orcid_present = 1 if( $_->{name} eq "orcid" );
}
if( !$orcid_present ){
    push @{ $c->{fields}->{user} },
    {
        name => "orcid",
        type => "id"
    };
}


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

# always include archive ID in log messages
$c->{log} = sub
{
	my( $repository, $message ) = @_;

	print STDERR "[".$repository->get_id()."] ".$message."\n";
};

# disable multiple confusing feed options
$c->{plugins}->{"Export::RSS"}->{params}->{disable} = 1;
$c->{plugins}->{"Export::RSS2"}->{params}->{name} = "RSS";

# AH 21/09/2016: re-enabling Export::Atom plugin as SWORD intergration and
# CRUD.pm require it
# $c->{plugins}->{"Export::Atom"}->{params}->{disable} = 1;

#Fix ordering for creators_name
#Sticking familyname and given name together ordering as if a single string results in nonsense eg:

#Lamb, C. (1)
#Lambert, Jodie (1)
#Lambie, John (1)
#Lamb, Tracey J. (1)
#
#which should be 
#
#Lamb, C. (1)
#Lamb, Tracey J. (1)
#Lambert, Jodie (1)
#Lambie, John (1)

#Using this function to order fixes this problem
$c->{name_orderval} = sub
{
    my ($field, $value, $dataset) = @_;
    return $value->{family} . '$$$$$' . $value->{given};
};

for my $field (@{$c->{fields}->{eprint}}){
    if($field->{name} eq "creators"){ #TODO extend to other fields with names eg editors, contributors?
        for my $sub (@{$field->{fields}}){
            if($sub->{sub_name} eq "name"){
                $sub->{make_single_value_orderkey} = 'name_orderval';
            }
        }
    }
}

