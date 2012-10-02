#!/usr/bin/perl -w
# cpmd roll installation test.  Usage:
# cpmd.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my $isInstalled = -d '/opt/cpmd';
my $output;

my $TESTFILE = 'tmpcpmd';

open(OUT, ">$TESTFILE.cpmd");
print OUT <<END;
 &CPMD
    OPTIMIZE WAVEFUNCTION
 &END
 &SYSTEM
   SYMMETRY
    1
   CELL
    10.2612  1.0    1.0   0.0 0.0 0.0
   CUTOFF
   13.
 &END
 &ATOMS
*${TESTFILE}SI_SGS  KLEINMAN-BYLANDER
  LMAX=P
   8
           .00000      .00000      .00000    1
           .00000     5.13000     5.13000    1
          5.13000      .00000     5.13000    1
          5.13000     5.13000      .00000    1
          2.56500     2.56500     2.56500    1
          2.56500     7.69500     7.69500    1
          7.69500     2.56500     7.69500    1
          7.69500     7.69500     2.56500    1
 &END
END

open(OUT, ">$TESTFILE.sh");
print OUT <<END;
#!/bin/bash
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK cpmd
fi
/bin/cp /opt/cpmd/lib/SI_SGS ./${TESTFILE}SI_SGS
mpirun -np 2 /opt/cpmd/bin/cpmd.x $TESTFILE.cpmd
/bin/rm -f GEOMETRY* LATEST RESTART.1
END
close(OUT);

# cpmd-common.xml
if($appliance =~ /$installedOnAppliancesPattern/) {
  ok($isInstalled, 'cpmd installed');
} else {
  ok(! $isInstalled, 'cpmd not installed');
}
SKIP: {

  skip 'cpmd not installed', 4 if ! $isInstalled;
  $output = `/bin/bash $TESTFILE.sh 2>&1`;
  ok($output =~ /TOTAL ENERGY.*-31.21877326 A.U./, 'cpmd test run');

  skip 'modules not installed', 3 if ! -f '/etc/profile.d/modules.sh';
  `/bin/ls /opt/modulefiles/applications/cpmd/[0-9]* 2>&1`;
  ok($? == 0, 'cpmd module installed');
  `/bin/ls /opt/modulefiles/applications/cpmd/.version.[0-9]* 2>&1`;
  ok($? == 0, 'cpmd version module installed');
  ok(-l '/opt/modulefiles/applications/cpmd/.version',
     'cpmd version module link created');

}

`rm -f $TESTFILE*`;