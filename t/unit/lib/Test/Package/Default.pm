use MooseX::Declare;
use Method::Signatures::Simple;

class Test::Package::Default with (Test::Common::Package,
	Test::Table,
	Test::Common,
	Table::Main,
	Util::Logger,
	Table::Project,
	Table::Workflow,
	Web::Group::Privileges,
	Table::Stage,
	Table::App,
	Table::Parameter,
	Table::Common,
	Util::Main) extends Ops::Main {

use Data::Dumper;
use Test::More;
use Test::DatabaseRow;
use DBase::Factory;
use Ops::Main;
use Engine::Instance;
use Conf::Yaml;
use FindBin qw($Bin);

method BUILD ($hash) {
	$self->logDebug("");
	
	if ( defined $self->logfile() ) {
		$self->head()->ops()->logfile($self->logfile());
		$self->head()->ops()->keyfile($self->keyfile());
		$self->head()->ops()->log($self->log());
		$self->head()->ops()->printlog($self->printlog());
	}
}

#### DEFAULT PACKAGES
method testDefaultPackages {
	diag("Test defaultPackages");

	#### START LOG AFRESH
	$self->startLog($self->logfile());
	
	#### LOAD DATABASE
	$self->setUpTestDatabase();
	
	#### SET TEST DATABASEROW
	$self->setTestDatabaseRow();

	my $username = $self->conf()->getKey("database:TESTUSER");
	$self->username($username);
	$self->owner($username);
	$self->logDebug("username", $self->username());	
	$self->logDebug("owner", $self->owner());	

	#### SET ADMINUSER IN CONF FILE TO username 
	$self->conf()->setKey("agua", "ADMINUSER", $username);
	my $adminuser = $self->conf()->getKey("core:ADMINUSER");
	$self->logDebug("CHANGED ADMINUSER TO ENABLE SET DEFAULT bioapps AND agua", $adminuser);

	#### CLEAN OUT PREVIOUS ENTRIES
	my $query = "DELETE FROM package WHERE owner='$username' AND username='$username'";
	$self->logDebug("query", $query);
	$self->table()->db()->do($query);

	#### SET DATA
	my $data 	=	{};
	$data->{owner} 		= 	$username;
	$data->{username} 	= 	$username;
	$data->{version} 	= 	"0.1.0";
	$data->{status}		=	"ready";

	#### SET APPS
	$self->testSetPrivateApps($data);
	$self->testSetPublicApps($data);
	
	#### SET WORKFLOWS
	$self->testSetPrivateWorkflows($data);
	$self->testSetPublicWorkflows($data);
	
	#### SET BIOAPPS
	$self->testSetBioApps($data);	
	
	#### SET AGUA
	$self->testSetAgua($data);	
}

method testSetAgua ($data) {
	#### SET OPSDIR
	$self->opsdir("$Bin/outputs/biorepository");
	$self->logDebug("self->opsdir", $self->opsdir());
	
	#### SET INSTALLDIR
	my $installdir = $self->installdir("$Bin/outputs/agua");
	$self->logDebug("installdir", $installdir);

	#my $author = $self->conf()->getKey("agua:AUTHOR");
	my $username = $self->username();
	$data->{package} 	=	"agua";
	$data->{owner} 		= 	$username;
	$data->{version} 	= 	$self->conf()->getKey("agua:VERSION");	
	$data->{opsdir} 	= 	$self->setOpsDir($username, "biorepository", "public", "agua");
	$data->{installdir} = 	$installdir;
	$self->logDebug("data", $data);

	#### REMOVE CONFLICTING INSTALLATION (SAME PACKAGE AND INSTALLDIR)
	my $query = "DELETE FROM package WHERE package='agua'";
	$self->logDebug("query", $query);
	$self->table()->db()->do($query);

	$self->setAgua($data);

	$self->verifyPackageData($data);
}

method testSetBioApps ($data) {
	#### SET OPSDIR
	$self->opsdir("$Bin/outputs/biorepository");
	$self->logDebug("self->opsdir", $self->opsdir());
	
	#### SET INSTALLDIR
	$self->installdir("$Bin/outputs/bioapps");
	$self->logDebug("self->installdir", $self->installdir());
	my $username = $self->username();
	#my $author = $self->conf()->getKey("bioapps:AUTHOR");
	$data->{package} 	=	"bioapps";
	$data->{owner} 		= 	$username;
	$data->{opsdir} 	= 	$self->opsdir();
	$data->{version} 	= 	$self->conf()->getKey("bioapps:VERSION") || "0.0.1";	
	$data->{installdir} = 	$self->installdir();
	$self->logDebug("data", $data);
	
	$self->_setBioApps($data);

	$self->verifyPackageData($data);
}

method testSetPrivateWorkflows ($data) {
	return $self->testSetWorkflows ($data, "private");
}

method testSetPublicWorkflows ($data) {
	return $self->testSetWorkflows ($data, "public");
}
method testSetWorkflows ($data, $privacy) {
### SET OPSDIR FOR PUBLIC BIOREPO
	$self->logError("type is not public or private") and exit if $privacy !~ /^(public|private)$/;

	$self->opsdir("$Bin/outputs/biorepository");
	$self->logDebug("self->opsdir", $self->opsdir());
	
	#### SET PRIVATE INSTALLDIR
	$self->installdir("$Bin/outputs/$privacy/workflows/syoung");
	$self->logDebug("self->installdir", $self->installdir());

	#### SET PRIVATE workflows
	my $username = $data->{username};
	$data = $self->setPackageData($data, $username, $username, "workflows", $privacy);
	$self->setPrivateWorkflows($data);
	
	#### VERIFY DATA
	$self->verifyPackageData($data);
}

method testSetPrivateApps ($data) {
	return $self->testSetApps ($data, "private");
}

method testSetPublicApps ($data) {
	return $self->testSetApps ($data, "public");
}

method testSetApps ($data, $privacy) {
### SET OPSDIR FOR PUBLIC BIOREPO
	$self->logError("type is not public or private") and exit if $privacy !~ /^(public|private)$/;

	$self->opsdir("$Bin/outputs/biorepository");
	$self->logDebug("self->opsdir", $self->opsdir());
	
	#### SET PRIVATE INSTALLDIR
	$self->installdir("$Bin/outputs/$privacy/apps/syoung");
	$self->logDebug("self->installdir", $self->installdir());

	#### SET PRIVATE apps
	my $username = $data->{username};
	$data = $self->setPackageData($data, $username, $username, "apps", $privacy);
	$self->setPrivateApps($data);
	
	#### VERIFY DATA
	$self->verifyPackageData($data);
}

method testSetPrivateApps ($data) {
	return $self->testSetApps ($data, "private");
}

method testSetPublicApps ($data) {
	return $self->testSetApps ($data, "public");
}

method testSetApps ($data, $privacy) {
### SET OPSDIR FOR PUBLIC BIOREPO
	$self->logError("type is not public or private") and exit if $privacy !~ /^(public|private)$/;

	$self->opsdir("$Bin/outputs/biorepository");
	$self->logDebug("self->opsdir", $self->opsdir());
	
	#### SET PRIVATE INSTALLDIR
	$self->installdir("$Bin/outputs/$privacy/apps/syoung");
	$self->logDebug("self->installdir", $self->installdir());

	#### SET PRIVATE apps
	my $username = $data->{username};
	$data = $self->setPackageData($data, $username, $username, "apps", $privacy);
	$self->setPrivateApps($data);
	
	#### VERIFY DATA
	$self->verifyPackageData($data);
}

method verifyPackageData ($data) {
	$self->logDebug("data", $data);
	my $table = "package";
	my $requiredkeys = ['username', 'owner', 'package', 'version', 'installdir'];
    my $where = $self->where($data, $requiredkeys);
    $self->logDebug("where", $where);

	#### TEST INSERTED FIELD VALUES
	$self->verifyRows($table, $where, "correct package information for package: '$data->{package}'");
}

method setOpsInfo ($opsfile) {
	$self->logDebug("");
	my $opsinfo = Ops::Info->new({
		inputfile	=>	$opsfile,
		logfile		=>	$self->logfile(),
		log		=>	$self->log(),
		printlog	=>	$self->printlog()
	});
	$self->opsinfo($opsinfo);
	#$self->logDebug("opsinfo", $opsinfo);

	return $opsinfo;
}

method setOpsDir ($username, $repository, $privacy, $package) {
#### example: /agua/repos/public/biorepository/syoung/bioapps
	$self->logNote("username", $username);
	$self->logNote("repository", $repository);
	$self->logNote("type", $privacy);
	$self->logNote("package", $package);

	#### ADDED FOR TESTING
	return $self->opsdir() if defined $self->opsdir();
	
	$self->logError("type is not public or private") and exit if $privacy !~ /^(public|private)$/;
	my $installdir = $self->conf()->getKey("core:INSTALLDIR");
	my $opsdir = "$installdir/repos/$privacy/$repository/$username/$package";
	File::Path::mkpath($opsdir);
	$self->logError("can't create opsdir: $opsdir") if not -d $opsdir;
	
	return $opsdir;
}

method setInstallDir ($username, $owner, $package, $privacy) {
#### RETURN LOCATION OF APPLICATION FILES - OVERRIDEN FOR TESTING
	$self->logNote("username", $username);
	$self->logNote("owner", $owner);
	$self->logNote("package", $package);
	$self->logNote("type", $privacy);

	return $self->installdir() if defined $self->installdir();
	
	my $userdir = $self->conf()->getKey("core:USERDIR");

	return "$userdir/$username/repos/$privacy/$package/$owner";
}

method fakeTermination {
	#### DO NOTHING
}



}

=cut
