package Plugins::HueBridge::Plugin;

use strict;
use base qw(Slim::Plugin::OPMLBased);

use Config;
use File::Spec::Functions;
use XML::Simple;

use Slim::Utils::Log;
use Slim::Utils::Prefs;


my $log = Slim::Utils::Log->addLogCategory({
    'category'     => 'plugin.huebridge',
    'defaultLevel' => 'WARN',
    'description'  => Slim::Utils::Strings::string('PLUGIN_HUEBRIDGE_NAME'),
});

my $prefs = preferences('plugin.huebridge');


$prefs->init({
    autosave => 0,
    binary => undef,
    binaryAutorun => 0,
    debugs => undef,
    loggingEnabled => 0,
    numLinesLogFile => 25,
    showAdvancedHueBridgeOptions => 0,
    xmlConfigFileName => 'huebridge.xml'
});


sub initPlugin {
    my $class = shift;

    $log->debug( "Initialising HueBridge " . $class->_pluginDataFor( 'version' ) . " on " . $Config{'archname'} );

    if ( main::WEBUI ) {

        require Plugins::HueBridge::Settings;
        Plugins::HueBridge::Settings->new;

        Slim::Web::Pages->addPageFunction("plugins/HueBridge/settings/tableHueBridges.html" => \&Plugins::HueBridge::Settings::handler_tableHueBridges);
        
        Slim::Web::Pages->addPageFunction(qr/plugins\/HueBridge\/(\.S\/)|()huebridge-file\.html/ => \&Plugins::HueBridge::Settings::handler_file);
        Slim::Web::Pages->addPageFunction("plugins/HueBridge/huebridgeguide.html" => \&Plugins::HueBridge::Settings::handler_userGuide);
        
        Slim::Web::Pages->addPageFunction("plugins/HueBridge/helper/huebridge-content.html" => \&Plugins::HueBridge::Settings::handler_content);
    }

    require Plugins::HueBridge::HueCom;
    Plugins::HueBridge::HueCom->initCLICommands;

    require Plugins::HueBridge::Squeeze2Hue;
    Plugins::HueBridge::Squeeze2Hue->initCLICommands;
    if ($prefs->get('binaryAutorun')) {

        Plugins::HueBridge::Squeeze2Hue->start;
    }

    return 1;
}

sub shutdownPlugin {
    if ($prefs->get('autorun')) {

        Plugins::HueBridge::Squeeze2Hue->stop;
    }
}

1;
