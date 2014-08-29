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

Intel MKL libraries.  If you're building with the Intel compiler or there is
an mkl modulefile present (the mkl-roll provides this), then the build process
will pick these up automatically.  Otherwise, you'll need to set the MKL_ROOT
environment variable to the library location.

FFTW libraries.  If there is
an fftw modulefile present (the fftw-roll provides this), then the build process
will pick these up automatically.  Otherwise, you'll need to set the FFTWHOME
environment variable to the library location.

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
make ROLLCOMPILER=intel ROLLMPI=mvapich2 ROLLNETWORK=mx 
```

The build process currently supports one or more of the values "intel", "pgi",
and "gnu" for the `ROLLCOMPILER` variable, defaulting to "gnu".
It uses any `ROLLMPI` and `ROLLNETWORK` variable values to load appropriate mpi
modules, assuming that there are modules named `$(ROLLMPI)_$(ROLLNETWORK)`
available (e.g., `openmpi_ib`, `mvapich2_mx`, etc.).  The build process also
uses the ROLLCOMPILER value to load an environment module, and it supports
using the ROLLCOMPILER value to specify a particular compiler version, e.g.,

```shell
% make ROLLCOMPILER=gnu/4.8.1 ROLLMPI=openmpi ROLLNETWORK=ib
```

If the `ROLLCOMPILER`, `ROLLNETWORK` and/or `ROLLMPI` variables are specified,
their values are incorporated into the names of the produced rpms, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2 ROLLNETWORK=ib
```
produces an rpm with a name that begins "`cpmd_intel_mvapich2_ib`".

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
```
