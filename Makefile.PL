use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'WWW::Scraper::ISBN::LOC_Driver',
    'VERSION_FROM'	=> 'LOC_Driver.pm', # finds $VERSION
    'PREREQ_PM'		=> {
			HTTP::Request::Common => 1.19,
			Template::Extract => 0.35,
			LWP::UserAgent => 2.0,
			WWW::Scraper::ISBN::Driver => 0.15
			}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
       (AUTHOR     => 'Andy Schamp <andy@schamp.net>') : ()),
);
