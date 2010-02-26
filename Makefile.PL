
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Business::ID::NPWP',
                       'DISTNAME' => 'Business-ID-NPWP',
                       'AUTHOR' => 'Steven Haryanto <stevenharyanto@gmail.com>',
                       'ABSTRACT' => 'Validate Indonesian taxpayer registration number (NPWP)',
                       'EXE_FILES' => [],
                       'VERSION' => '0.03',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'DateTime' => '0',
                                        'Pod::Coverage' => '0.18',
                                        'Test::More' => '0',
                                        'Test::Pod::Coverage' => '1.08',
                                        'ExtUtils::MakeMaker' => '6.11'
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



