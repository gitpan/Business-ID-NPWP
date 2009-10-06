use inc::Module::Install;

name     'Business-ID-NPWP';
all_from 'lib/Business/ID/NPWP.pm';
author   q{Steven Haryanto <stevenharyanto@gmail.com>};
license  'perl';

build_requires 'Test::More';
requires 'DateTime';

auto_install;

WriteAll;

