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

FFTW libraries.  If there is an fftw modulefile present (the fftw-roll provides
this), then the build process will pick these up automatically.  Otherwise,
you'll need to set the FFTWHOME environment variable to the library location.

## Building

To build the cpmd-roll, execute this on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make 2>&1 | tee build.log
```

A successful build will create the file `cpmd-*.disk1.iso`.  If you built the
roll on a Rocks frontend, proceed to the installation step. If you built the
roll on a Rocks development appliance, you need to copy the roll to your Rocks
frontend before continuing with installation.

This roll source supports building with different compilers and for different
MPI flavors.  The `ROLLCOMPILER` and `ROLLMPI` make variables can be used to
specify the names of compiler and MPI modulefiles to use for building the
software, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2_ib 2>&1 | tee build.log
```

The build process recognizes "gnu", "intel" or "pgi" as the value for the
`ROLLCOMPILER` variable; any MPI modulefile name may be used as the value of
the `ROLLMPI` variable.  The default values are "gnu" and "rocks-openmpi".

The values of the `ROLLCOMPILER` and `ROLLMPI` variables are incorporated into
the names of the produced rpms.  For example,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2_ib 2>&1 | tee build.log
```
produces a roll containing an rpm with a name that begins
`cpmd_intel_mvapich2_ib`.


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
/opt/modulefiles/applications/cpmd.
```


## Testing

The cpmd-roll includes a test script which can be run to verify proper
installation of the cpmd-roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/cpmd.t 
```
