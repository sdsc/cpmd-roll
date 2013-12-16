# SDSC "cpmd" roll

## Overview

This roll bundles the CPMD molecular dynamics package.

For more information about CPMD please visit their official web page:

- <a href="http://www.cpmd.org" target="_blank">CPMD</a> is a parallelized plane
wave / pseudopotential implementation of Density Functional Theory, particularly
designed for ab-initio molecular dynamics.

## Requirements

To build/install this roll you must have root access to a Rocks development
machine (e.g., a frontend or development appliance).

If your Rocks development machine does *not* have Internet access you must
download the appropriate cpmd source file(s) using a machine that does
have Internet access and copy them into the `src/<package>` directories on your
Rocks development machine.


## Dependencies

Unknown at this time.


## Building

To build the cpmd-roll, execute these instructions on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make default 2>&1 | tee build.log
% grep "RPM build error" build.log
```

If nothing is returned from the grep command then the roll should have been
created as... `cpmd-*.iso`. If you built the roll on a Rocks frontend then
proceed to the installation step. If you built the roll on a Rocks development
appliance you need to copy the roll to your Rocks frontend before continuing
with installation.

This roll source supports building with different compilers and for different
network fabrics and mpi flavors.  By default, it builds using the gnu compilers
for openmpi ethernet.  To build for a different configuration, use the
`ROLLCOMPILER`, `ROLLMPI` and `ROLLNETWORK` make variables, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mpich2 ROLLNETWORK=mx 
```

The build process currently supports one or more of the values "intel", "pgi",
and "gnu" for the `ROLLCOMPILER` variable, defaulting to "gnu".  It supports
`ROLLMPI` values "openmpi", "mpich2", and "mvapich2", defaulting to "openmpi".
It uses any `ROLLNETWORK` variable value(s) to load appropriate mpi modules,
assuming that there are modules named `$(ROLLMPI)_$(ROLLNETWORK)` available
(e.g., `openmpi_ib`, `mpich2_mx`, etc.).

If the `ROLLCOMPILER`, `ROLLNETWORK` and/or `ROLLMPI` variables are specified,
their values are incorporated into the names of the produced roll and rpms, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2 ROLLNETWORK=ib
```
produces a roll with a name that begins "`cpmd_intel_mvapich2_ib`"; it
contains and installs similarly-named rpms.

For gnu compilers, the roll also supports a `ROLLOPTS` make variable value of
'avx', indicating that the target architecture supports AVX instructions.


## Installation

To install, execute these instructions on a Rocks frontend:

```shell
% rocks add roll *.iso
% rocks enable roll cpmd
% cd /export/rocks/install
% rocks create distro
% rocks run roll cpmd | bash
```

In addition to the software itself, the roll installs cpmd environment
module files in:

```shell
/opt/modulefiles/applications/.(compiler)/cpmd.
```


## Testing

The cpmd-roll includes a test script which can be run to verify proper
installation of the cpmd-roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/cpmd.t 
ok 1 - cpmd is installed
ok 2 - cpmd test run
ok 3 - cpmd module installed
ok 4 - cpmd version module installed
ok 5 - cpmd version module link created
1..5
```
