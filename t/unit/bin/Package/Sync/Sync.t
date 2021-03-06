#!/usr/bin/perl -w

use Test::More  tests => 176; # qw(no_plan);

use FindBin qw($Bin);
use lib "$Bin/../../../../../lib";
BEGIN
{
    my $installdir = $ENV{'installdir'} || "/a";
    unshift(@INC, "$installdir/extlib/lib/perl5");
    unshift(@INC, "$installdir/extlib/lib/perl5/x86_64-linux-gnu-thread-multi/");
    unshift(@INC, "$installdir/lib");
    unshift(@INC, "$installdir/lib/external/lib/perl5");
}

#### CREATE OUTPUTS DIR
my $outputsdir = "$Bin/outputs";
`mkdir -p $outputsdir` if not -d $outputsdir;


#### SET DUMPFILE
my $dumpfile    =   "$Bin/../../../../../dump/create.dump";

#### SET CONF FILE
my $installdir  =   $ENV{'installdir'} || "/a";
my $configfile    =   "$installdir/conf/config.yml";

#### SET $Bin
$Bin =~ s/^.+t\/bin/$installdir\/t\/bin/;
	
use Test::Common::Package::Sync;
use Getopt::Long;
use FindBin qw($Bin);
use Conf::Yaml;

#### SET LOG
my $log     =   2;
my $printlog    =   5;
my $logfile = "$Bin/outputs/sync.log";

#### GET OPTIONS
my $login;
my $token;
my $keyfile;
my $help;
GetOptions (
    'log=i'     => \$log,
    'printlog=i'    => \$printlog,
    'login=s'       => \$login,
    'token=s'       => \$token,
    'keyfile=s'     => \$keyfile,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

#### LOAD LOGIN, ETC. FROM ENVIRONMENT VARIABLES
$login = $ENV{'login'} if not defined $login or not $login;
$token = $ENV{'token'} if not defined $token;
$keyfile = $ENV{'keyfile'} if not defined $keyfile;

if ( not defined $login or not defined $token
    or not defined $keyfile ) {
    plan 'skip_all' => "Missing login, token or keyfile. Run this script manually and provide GitHub login and token credentials and SSH private keyfile";
}

#### RUN AS ROOT
my $whoami = `whoami`;
$whoami =~ s/\s+//g;
print "Must run as root\n" and exit if $whoami ne "root";

my $conf = Conf::Yaml->new(
    memory      =>  1,
    inputfile	=>	$configfile,
    log     =>  2,
    printlog    =>  2,
    logfile     =>  $logfile
);

#### GET TEST USER
my $username    =   $conf->getKey("database:TESTUSER");

my $object = new Test::Common::Package::Sync(
    log			=>	$log,
    printlog    =>  $printlog,
    logfile     =>  $logfile,
    dumpfile    =>  $dumpfile,
    conf        =>  $conf,

    login       =>  $login,
    token       =>  $token,
    keyfile     =>  $keyfile,
    username    =>  $username
);

#### START LOG AFRESH
$object->startLog($object->logfile());

#### TEST CREATE APP FILES
$object->testCreateAppFiles();

#### TEST LOAD APPS
$object->testLoadAppFiles();

#### TEST CREATE WORKFLOW FILES
$object->testCreateProjectFiles();

#### TEST LOAD PROJECTS
$object->testLoadProjectFiles();

#### SYNC PUBLIC APPS
$object->testSyncPublicApps();

#### TEST SYNC WORKFLOWS
$object->testSyncPublicWorkflows();

#### SYNC PRIVATE APPS
$object->testSyncPrivateApps();

#### TEST SYNC WORKFLOWS
$object->testSyncPrivateWorkflows();

exit;

#### CLEAN UP
`rm -fr $Bin/outputs/*`

