#!/usr/bin/perl -w

#### EXTERNAL MODULES
use Test::More  tests => 13;

use FindBin qw($Bin);
use lib "$Bin/../../../../lib";
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


#### INTERNAL MODULES
use Test::Common::Cluster;
use Conf::Yaml;

my $log     = 3;
my $printlog    = 3;
my $logfile = "$Bin/outputs/testuser.cluster.log";

#### SET CONF FILE
my $installdir  =   $ENV{'installdir'} || "/a";
my $configfile  =   "$installdir/conf/config.yml";

#### SET $Bin
$Bin =~ s/^.+t\/bin/$installdir\/t\/bin/;

my $conf = Conf::Yaml->new(
	inputfile	=>	$configfile,
	backup		=>	1,
	separator	=>	"\t",
	spacer		=>	"\\s\+",
    logfile     =>  $logfile,
    log     	=>  2,
    printlog    =>  2
);

#### SET DUMPFILE
#my $dumpfile = "$Bin/../../../../bin/sql/dump/agua.dump";
my $dumpfile    =   "$Bin/../../../../dump/create.dump";

my $tester = new Test::Common::Cluster(
    database    =>  "testuser",
    dumpfile    =>  $dumpfile,
    logfile     =>  $logfile,
    conf        =>  $conf,
    json        =>  {
        username    =>  'syoung'
    },
    username    =>  "testuser",
    project     =>  "Project1",
    workflow    =>  "Workflow1",
    log			=>	$log,
    printlog    =>  $printlog
);

#### STAGE TO BE ADDED/REMOVED    
my $json = {
    username	=>	"syoung",
    description	=>	"Small test cluster",
    availzone	=>	"us-east-1a",
    cluster	    =>	"syoung-testcluster",
    minnodes	=>	"0",
    maxnodes	=>	"5",
    amiid	    =>	"ami-b07985d9",
    instancetype=>	"t1.micro"
};
$tester->testAddRemoveCluster($json);

