use MooseX::Declare;
use Method::Signatures::Simple;

class Test::Common::Package::Insert with (Test::Common::Package,
	Package::Main,
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

#### DATABASE
method testInsertData {
    my $hash = {
        username    =>  $self->conf()->getKey("database:TESTUSER"),
        owner       =>  $self->conf()->getKey("database:TESTUSER"),
        package 	=>  "apps",
		opsdir		=>	"$Bin/inputs/ops",
		installdir	=>	"$Bin/outputs/target",
        version     =>  "0.3"
    };

	my $table = "package";

	$self->insertData($table, $hash);
}

}

=cut
