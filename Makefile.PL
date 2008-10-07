use strict;
use warnings;
use ExtUtils::MakeMaker;

my $BUILD_REQUIRES = {
 'Cwd'                   => 0,
 'ExtUtils::MakeMaker'   => 0,
 'File::Spec::Functions' => 0,
 'File::Temp'            => 0,
 'Test::More'            => 0,
};  
    
sub build_req {      
 my $tometa = ' >> $(DISTVNAME)/META.yml;';
 my $build_req = 'echo "build_requires:" ' . $tometa;
 foreach my $mod ( sort { lc $a cmp lc $b } keys %$BUILD_REQUIRES ) {
  my $ver = $BUILD_REQUIRES->{$mod};
  $build_req .= sprintf 'echo "    %-30s %s" %s', "$mod:", $ver, $tometa;
 }
 return $build_req;
}

WriteMakefile(
    NAME          => 'rgit',
    AUTHOR        => 'Vincent Pit <perl@profvince.com>',
    LICENSE       => 'perl',
    VERSION_FROM  => 'lib/App/Rgit.pm',
    ABSTRACT      => 'Recursively execute a command on all the git repositories in a directory tree.',
    PL_FILES      => { },
    EXE_FILES     => [ 'bin/rgit' ],
    PREREQ_PM     => {
        'Carp'                  => 0,
        'Config'                => 0,
        'Cwd'                   => 0,
        'Exporter'              => 0,
        'File::Find'            => 0,
        'File::Spec::Functions' => 0,
        'Object::Tiny'          => 0,
        'POSIX'                 => 0,
    },
    dist          => { 
        PREOP      => 'pod2text bin/rgit > $(DISTVNAME)/README; '
                      . build_req,
        COMPRESS   => 'gzip -9f', SUFFIX => 'gz'
    },
    clean         => { FILES => 'rgit-* *.gcov *.gcda *.gcno cover_db Debian_CPANTS.txt' }
);
