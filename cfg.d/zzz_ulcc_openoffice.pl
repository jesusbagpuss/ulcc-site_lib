# overrides for ULCC openoffice deployment
$c->{executables}->{python} = '/usr/bin/python';

$c->{session_init} = sub
{
	my( $repository, $offline ) = @_;

	my $epuser = $repository->config(qw( user ));

	$ENV{USER} = $epuser;
	$ENV{HOME} = (getpwnam $epuser)[7];
};
