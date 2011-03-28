C     ==================================================================
      SUBROUTINE CONTROL_TEST(TSRHO)
C     ==--------------------------------------------------------------==
C     ==  Test of variables read in control routine                   ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'spin.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'struc.inc'
      INCLUDE 'prden.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'benc.inc'
      INCLUDE 'nort.inc'
      INCLUDE 'isos.inc'
      INCLUDE 'nose.inc'
      INCLUDE 'qspl.inc'
      INCLUDE 'andr.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'
      INCLUDE 'atwf.inc'
      INCLUDE 'store.inc'
      INCLUDE 'wann.inc'
      INCLUDE 'kpts.inc'        !TKNOSWAP
      INCLUDE 'lscal.inc'       !NSMAXP
      INCLUDE 'broy.inc'        !TGMIX,TGBROY
      INCLUDE 'mm_input.inc'
      INCLUDE 'comvel.inc'
C     Arguments
      LOGICAl TSRHO
C     Variables
      INTEGER IT
C     ==--------------------------------------------------------------==
C     ==  Test of options                                             ==
C     ==--------------------------------------------------------------==
      IF (TMDFILE.AND.WFOPT) WFOPT=.FALSE.
      IT=0
      IF(MD) THEN
        IT=IT+1
      ENDIF
      IF(WFOPT) THEN
        IT=IT+1
      ENDIF
      IF(GEOPT) THEN
        IT=IT+1
      ENDIF
      IF(VIBRAT) THEN
        IT=IT+1
      ENDIF
      IF(KSENER) THEN
        IT=IT+1
      ENDIF
      IF(PROPER) THEN
        IT=IT+1
      ENDIF
      IF(TINTER) THEN
        IT=IT+1
      ENDIF
      IF(THARD) THEN
        IT=IT+1
      ENDIF
      IF(TSPEC) THEN
        IT=IT+1
      ENDIF
      IF(TDEBFOR) THEN
        IT=IT+1
      ENDIF
      IF(IT.LT.1) THEN
        WRITE(*,'(A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A)') 
     *  ' CHOOSING ONE OF THE FOLLOWING OPTIONS IS COMPULSORY ',
     *  '                                  MOLECULAR DYNAMICS ',
     *  '                               GEOMETRY OPTIMIZATION ',
     *  '                           WAVEFUNCTION OPTIMIZATION ',
     *  '                                  KOHN-SHAM ENERGIES ',
     *  '                                VIBRATIONAL ANALYSIS ',
     *  '                                          PROPERTIES ',
     *  '                                    ORBITAL HARDNESS ',
     *  '                                  ELECTRONIC SPECTRA ',
     *  '                                     LINEAR RESPONSE ',
     *  '                                        DEBUG FORCES ',
     *  '                                 CLASSICAL INTERFACE '
        CALL STOPGM('CONTROL','RUNOPTIONS ')
      ELSEIF(IT.GT.1) THEN
        WRITE(*,'(A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A,/,A)') 
     *  '       THE FOLLOWING OPTIONS ARE MUTUALLY  EXCLUSIVE ',
     *  '                                  MOLECULAR DYNAMICS ',
     *  '                               GEOMETRY OPTIMIZATION ',
     *  '                           WAVEFUNCTION OPTIMIZATION ',
     *  '                                  KOHN-SHAM ENERGIES ',
     *  '                                VIBRATIONAL ANALYSIS ',
     *  '                                          PROPERTIES ',
     *  '                                    ORBITAL HARDNESS ',
     *  '                                  ELECTRONIC SPECTRA ',
     *  '                                        DEBUG FORCES ',
     *  '                                     LINEAR RESPONSE ',
     *  '                                 CLASSICAL INTERFACE '
        CALL STOPGM('CONTROL','RUNOPTIONS ')
      ENDIF
C     ==--------------------------------------------------------------==
C     Path calculations (integral or minimisation)
      IF(TPATH) THEN
        IF(NRESTF.GT.1) THEN
          WRITE(6,'(/,1X,8("WARNING!"),/,A,/,1X,8("WARNING!"))')
     &      ' WARNING! RESETTING RESTFILE TO 1 FOR PATH-INTEGRALS'
          NRESTF=1
        ENDIF
C       Path integral
        IF(TPIMD) THEN
          IF(GEOPT) CALL STOPGM('CONTROL_TEST','GEOMETRY OPTIMIZATION '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(KSENER) CALL STOPGM('CONTROL_TEST','KOHN-SHAM ENERGIES '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(VIBRAT) CALL STOPGM('CONTROL_TEST','VIBRATIONAL ANALYSIS '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(TINTER) CALL STOPGM('CONTROL_TEST','CLASSICAL INTERFACE '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(TMDFILE) CALL STOPGM('CONTROL_TEST','FILE MD '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(TSHOP) CALL STOPGM('CONTROL_TEST','SURFACE HOPPING '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(BSYMM) CALL STOPGM('CONTROL_TEST','BROKEN SYMMETRY '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
          IF(TQMMM) CALL STOPGM('CONTROL_TEST','QM/MM '
     &        // 'WITH PATH INTEGRALS IS NOT SUPPORTED')
        ELSEIF(TPMIN) THEN
C         Path minimisation
          IF(KSENER) CALL STOPGM('CONTROL_TEST','KOHN-SHAM ENERGIES '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(VIBRAT) CALL STOPGM('CONTROL_TEST','VIBRATIONAL ANALYSIS '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(TINTER) CALL STOPGM('CONTROL_TEST','CLASSICAL INTERFACE '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(TMDFILE) CALL STOPGM('CONTROL_TEST','FILE MD '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(TSHOP) CALL STOPGM('CONTROL_TEST','SURFACE HOPPING '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(BSYMM) CALL STOPGM('CONTROL_TEST','BROKEN SYMMETRY '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
          IF(TQMMM) CALL STOPGM('CONTROL_TEST','QM/MM '
     &        // 'WITH PATH MINIMIZATION IS NOT SUPPORTED')
        ELSE
C         It should never be possible to go here.
          CALL STOPGM('CONTROL','ERROR IN PATH OPTIONS')
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      IF(WFOPT)THEN
C       Backward compatibility. Allow use of MAXSTEP instead of MAXITER
C       for regular Wavefunction Optimization
        IF(NOMORE.NE.10000.AND.NOMORE_ITER.EQ.10000) THEN
          NOMORE_ITER=NOMORE
        ENDIF
      ENDIF
C     Kohn-Sham Energies
      IF(KSENER) THEN
C       By default, we use optimisation of wavefunctions with
C       diagonalisation scheme (Lanczos algorithm).
        WFOPT=.TRUE.
        TDIAG=.TRUE.
        IF(.NOT.TDAVI) THEN
          TLANC=.TRUE.
C         All eigenvalues are accuratly calculated.
          TFRAL=.TRUE.
          IF(NTABTROT.NE.1) THEN
            NTABTROT=1
            IF(TTROT) THEN
              B2LIMIT=1.D-12
            ELSE
              B2LIMIT=1.D-8
            ENDIF
          ENDIF
C         No self-consistency (1 iteration), but need an RESTART file.
          NOMORE_ITER=1
          IF(.NOT.RESTART) THEN
            CALL STOPGM('CONTROL',
     &        'KOHN-SHAM ENERGIES OPTION NEEDS TO USE RESTART OPTION')
          ELSE IF(.NOT.(RWF.OR.RPOT.OR.RRHO)) THEN
            WRITE(*,'(A,/,A,/,A)')
     &        ' CONTROL! KOHN-SHAM ENERGIES OPTION:',
     &        ' CONTROL! RESTART OPTION NEEDS ONE OF THE ITEMS',
     &        ' CONTROL! WAVEFUNCTIONS, DENSITY OR POTENTIAL'
            CALL STOPGM('CONTROL', 
     &        'SPECIFY AT LEAST ONE ITEM')
          ELSE IF(RWF.AND.TKNOSWAP) THEN
            WRITE(*,'(A,A,/,A,/,A)')
     &        ' CONTROL! KOHN-SHAM ENERGIES ',
     &        'WITH THE OPTION NOWAVEFUNCTION:',
     &        ' CONTROL! WAVEFUNCTIONS ARE NOT USED',
     &        ' CONTROL! YOU NEED A DENSITY OR A POTENTIAL TO RESTART'
            CALL STOPGM('CONTROL', 
     &        'DO NOT SPECIFY WAVEFUNCTIONS IN RESTART OPTION')
          ENDIF
          IF(TKNOSWAP) THEN
C           The wavefunctions are not stored.
            SWF=.FALSE.
C           The density are not stored.
            SRHO=.FALSE.
            TSRHO=.FALSE.
C           The potential are not stored.
            SPOT=.FALSE.
          ENDIF
C         Set the default for number of Lanczos/Friesner iterations
          IF(N_FRIES.EQ.-1) N_FRIES=200
        ELSE
          TLANC=.FALSE.
C         No self-consistency (1 iteration), but need an RESTART file.
          NOMORE_ITER=1
          IF(.NOT.RESTART .OR. .NOT.RWF) THEN
            CALL STOPGM('CONTROL',
     &           'KOHN-SHAM ENERGIES NEEDS RESTART WAVEUNCTION')
          ENDIF
C         Set the default for number of Davidson iterations
          IF(N_FRIES.EQ.-1) THEN
            N_FRIES=200
          ENDIF
        ENDIF
      ELSEIF(TSPEC) THEN
C       Electronic Spectra
        IF(N_FRIES.EQ.-1) THEN
          N_FRIES=200
        ENDIF
      ELSEIF(TDDFT.AND.TMDBO) THEN
        N_FRIES=500
        B2LIMIT=1.0D-8
        NKRY_MAX=8
      ELSEIF(TDIAGOPT) THEN
        IF(N_FRIES.EQ.-1) THEN
          N_FRIES=50
        ENDIF
      ELSE
        IF(N_FRIES.EQ.-1) THEN
          N_FRIES=1
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      IF(IPRINT_STEP.EQ.0) THEN
        IPRINT_STEP=MAX(NOMORE,10000)+1
      ENDIF
      IF(ISTORE.EQ.0) THEN
        ISTORE =MAX(NOMORE,10000)+1
      ENDIF
      IF(ISCTORE.EQ.0) THEN
          ISCTORE=NOMORE_ITER+1
      ENDIF
      IF(IMOVIE.EQ.0) THEN
        IMOVIE=NOMORE+1
      ENDIF
C     ==--------------------------------------------------------------==
      IF(MD) THEN
C     if we have no restart we needed to zero out electron velocities.
        IF(RNON) QUENCHE=.TRUE.
C        
        IF(TRAMPR.LT.0.0D0) WRITE(*,'(A,A)') ' WARNING! NEGATIVE ',
     &      'TEMPERATURE RAMP RATE SPECIFIED. RAMP IGNORED'
C     
        IF(QMMM.AND.CLASSICAL.AND.TMDBO) NOMORE_ITER=1

        IF(TNOSEE) THEN
          IF(TC) THEN 
            WRITE(*,'(A,A)') ' WARNING! BOTH NOSE ELECTRONS AND ',
     &           'TEMPCONTROL ELECTRONS WERE SPECIFIED'
            WRITE(*,'(A)') ' WARNING! TURNING OFF TEMPCONTROL ELECTRONS'
          ENDIF
          TC=.FALSE.
          IF(TBERE) THEN 
            WRITE(*,'(A,A)') ' WARNING! BOTH NOSE ELECTRONS AND ',
     &           'BERENDSEN ELECTRONS WERE SPECIFIED'
            WRITE(*,'(A)') ' WARNING! TURNING OFF BERENDSEN ELECTRONS'
          ENDIF
          TBERE=.FALSE.
          IF(TMDBO) THEN 
            WRITE(*,'(A,A)') ' WARNING! NOSE ELECTRONS WAS ',
     &           'SPECIFIED WITH BO DYNAMICS'
            WRITE(*,'(A)') ' WARNING! TURNING OFF NOSE ELECTRONS'
          TNOSEE=.FALSE.
          ENDIF
        ENDIF
        IF(TNOSEP) THEN
          IF(TCP) THEN
            WRITE(*,'(A,A)')' WARNING! BOTH NOSE IONS AND ',
     &           'TEMPCONTROL IONS WERE SPECIFIED'
            WRITE(*,'(A)')' WARNING! TURNING OFF TEMPCONTROL IONS'
          ENDIF
          TCP=.FALSE.
          IF(TBERP) THEN 
            WRITE(*,'(A,A)') ' WARNING! BOTH NOSE IONS AND ',
     &           'BERENDSEN IONS WERE SPECIFIED'
            WRITE(*,'(A)') ' WARNING! TURNING OFF BERENDSEN IONS'
          ENDIF
          TBERP=.FALSE.
        ENDIF
        IF(TNOSEC) THEN
          IF(TCC) THEN
            WRITE(*,'(A,A)')' WARNING! BOTH NOSE CELL AND ',
     &           'TEMPCONTROL CELL WERE SPECIFIED'
            WRITE(*,'(A)')' WARNING! TURNING OFF TEMPCONTROL CELL'
          ENDIF
          TCC=.FALSE.
          IF(TBERC) THEN 
            WRITE(*,'(A,A)') ' WARNING! BOTH NOSE CELL AND ',
     &           'BERENDSEN CELL WERE SPECIFIED'
            WRITE(*,'(A)') ' WARNING! TURNING OFF BERENDSEN CELL'
          ENDIF
          TBERC=.FALSE.
        ENDIF
        IF(TDIAG.AND.(.NOT.TMDBO)) THEN
          WRITE(*,'(A)')' WARNING! DIAGONALIZATION REQUESTED.'
          WRITE(*,'(A)')' WARNING! SWITCHING TO BORN-OPPENHEIMER MD'
          TMDBO=.TRUE.
        ENDIF
        IF(TWMOL.AND.(.NOT.TMDBO))
     &    CALL STOPGM('CONTROL_TEST','MOLECULAR ORBITALS NOT '
     &                  // 'NOT COMPATIBLE WITH CP DYNAMICS')
        IF(TSHOCK.AND.(TBERC.OR.TBERP.OR.TBERE))
     &    CALL STOPGM('CONTROL_TEST','BERENDSEN THERMOSTAT NOT '
     &                  // 'NOT COMPATIBLE WITH SHOCK.')
        IF(TSHOCK.AND.(ANNEC.OR.ANNEI.OR.ANNEE))
     &    CALL STOPGM('CONTROL_TEST','ANNEALING NOT '
     &                  // 'NOT COMPATIBLE WITH SHOCK.')
      ELSE
        TSHOP=.FALSE.
      ENDIF
      IF(TNOSEE.OR.TNOSEP.OR.TNOSEC) THEN
C===============================================================
C       T.D. in NOSEPA we use only DELT_ELEC
C       A.K. ... but with BO-dynamics it doesn't matter
C                and the wavefunction optimizers use DT2BYE 
C                to tune the algorithm and the typical values
C                for BO-dynamics may be too large.
        IF((.NOT.TMDBO).AND.(DELT_ELEC.NE.DELT_IONS)) THEN
          WRITE(*,*)
     &         'THE TIMESTEPS FOR IONS AND ELECTRONS HAVE TO BE EQUAL'
          WRITE(*,*)
     &         'WHEN USING NOSE-HOOVER THERMOSTATS'
          CALL STOPGM('CONTROL','TIMESTEPS ARE NOT EQUAL')
        ENDIF
      ENDIF

      IF(TBERE.AND.(TAUBE.LE.0.0d0)) CALL STOPGM('CONTROL',
     &    'BERENDSEN CHARACTERISTIC TIME <=0.0 FOR ELECTRONS')
      IF(TBERP.AND.(TAUBP.LE.0.0d0)) CALL STOPGM('CONTROL',
     &    'BERENDSEN CHARACTERISTIC TIME <=0.0 FOR IONS')
      IF(TBERC.AND.(TAUBC.LE.0.0d0)) CALL STOPGM('CONTROL',
     &    'BERENDSEN CHARACTERISTIC TIME <=0.0 FOR CELL')
      IF(.NOT.TMDBO) THEN
        IF(TEXTRAP) WRITE(*,*) 'WARNING! WAVEFUNCTION EXTRAPOLATION '
     &      // 'ONLY SUPPORTED FOR BO-MD. DISABLING...'
        TEXTRAP=.FALSE.
      ENDIF
C     ==--------------------------------------------------------------==
      IF(WFOPT .OR. GEOPT .OR. VIBRAT .OR. TINTER .OR. TMDBO
     *    .OR. TMDFILE .OR. THARD .OR. TSPEC .OR. TDEBFOR) THEN
        IF(DIIS .AND. .NOT. TFRHO_UPW) THEN
          MDIIS=MIN(MDIIS,MAXDIS)
          PCG=.FALSE.
          TSDE=.FALSE.
          IF(NRESET.GE.0.AND.NRESET.LT.MDIIS) THEN
            NRESET=MDIIS
          ENDIF
        ELSEIF(PCG) THEN
          TSDE=.FALSE.
        ELSEIF(TSDE) THEN
C         Nothing to be done.
        ELSE
          DIIS=.TRUE.
          PREC=.TRUE.
          MDIIS=MIN(MDIIS,MAXDIS)
          IF(NRESET.GE.0.AND.NRESET.LT.MDIIS) THEN
            NRESET=MDIIS
          ENDIF
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      IF(TSPEC) THEN
        TDIAG=.FALSE.
        IF(.NOT.TDAVI .AND. .NOT.TLANC) THEN
          TDAVI=.TRUE.
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
C     Diagonalisation scheme
      IF(TDIAG.AND.WFOPT)THEN
C       MAXSTEP is also used for MAXITER
        IF(NOMORE.NE.10000.AND.NOMORE_ITER.EQ.10000) THEN
          NOMORE_ITER=NOMORE
        ENDIF
      ENDIF
      IF(TDIAG .AND. .NOT.TFRHO_UPW) THEN
        DIIS=.FALSE.
        PCG=.FALSE.
        TSDE=.FALSE.
C       Only Gram-Schmidt works
        TLOWD=.FALSE.
      ELSEIF(TFRHO_UPW) THEN
        MDIIS=MIN(MDIIS_FR,MAXDIS)
        IF(MAXLDIIS .EQ. 0) MAXLDIIS = 20
        IF(MINLDIIS .EQ. 0) MINLDIIS = 4
        IF(TOLRHOFIX .EQ.0.0D0) TOLRHOFIX=1.D-7
        PCG=.FALSE.
        TSDE=.FALSE.
        IF(NRESET.GE.0.AND.NRESET.LT.MDIIS) NRESET=MDIIS
        IF(BETAEL .EQ. 0.0D0) TFINT = .FALSE.
      ELSE
        BETAEL=0.D0
      ENDIF
      IF(.NOT.TDIAG) THEN
C       No density mixing
        TGMIX=.FALSE.
C       No Broyden density mixing
        TGBROY=.FALSE.
      ENDIF
C     ==--------------------------------------------------------------==
C     GEometry OPTimisation
      IF(GEOPT) THEN
        IF(GDIIS) THEN
          RFO=.FALSE.
          BFGS=.FALSE.
          LBFGS=.FALSE.
          TSDP=.FALSE.
          PRFO=.FALSE.
          MGDIIS=MIN(MGDIIS,MXGDIS)
          TINR=.FALSE.
        ELSEIF(RFO) THEN
          BFGS=.FALSE.
          LBFGS=.FALSE.
          TSDP=.FALSE.
          TINR=.FALSE.
          PRFO=.FALSE.
        ELSEIF(BFGS) THEN
          LBFGS=.FALSE.
          TSDP=.FALSE.
          PRFO=.FALSE.
        ELSEIF(PRFO) THEN
          TSDP=.FALSE.
          LBFGS=.FALSE.
          IF(NSMAXP.EQ.-1) NSMAXP=NOMORE
        ELSEIF(LBFGS) THEN
          TSDP=.FALSE.
          TINR=.FALSE.
        ELSEIF(TSDP) THEN
          TINR=.FALSE.
        ELSEIF(TINR) THEN
           GDIIS=.FALSE.
           TDIAG=.FALSE.
           SIMUL=.FALSE.
        ELSE
C AK: QM/MM defaults to LBFGS for performance reasons
          IF(TQMMM) THEN
            LBFGS=.TRUE.
          ELSE
            IF(TDIAG) THEN
              GDIIS=.TRUE.
            ELSE
              GDIIS=.TRUE.
            ENDIF
          ENDIF
        ENDIF
        IF(TSDC) TPRCP=.TRUE.
      ENDIF
C     ==--------------------------------------------------------------==
      IF(TPRCP) THEN
        IF(.NOT.QSPLINE) THEN
          WRITE(*,*) 'NOTE: VARIABLE CELL ENFORCES "SPLINE QFUNCTION"'
          QSPLINE=.TRUE.
        ENDIF
        IF(TSUBROT) THEN
          WRITE(*,*) 'NOTE: NO "SUBTRACT ROTVEL" WITH VARIABLE CELL'
          TSUBROT=.FALSE.
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      NOGRP=MIN(NOGRP,NPROC)
      IF(TFINT) THEN
        TDAVI=.FALSE.
        IF(BETAEL.LT.0.D0) BETAEL=1000.D0
        IF(.NOT.TTROT) TBOGO=.FALSE.
      ELSE
        BETAEL=0.D0
      ENDIF
      IF(TDAVI.AND.TLANC) TLANC=.FALSE.
      IF(TLANC) THEN
        IF(B2LIMIT.LE.0.D0) THEN
          IF(TTROT) THEN
            B2LIMIT=1.D-12
          ELSE
            B2LIMIT=1.D-8
          ENDIF
        ENDIF
      ENDIF
      IF(TOLOG.EQ.0.D0) THEN
        IF(TDIAG) THEN
          TOLOG=1.D-3
        ELSE
          TOLOG=1.D-5
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
C     Store density.
      IF(TSRHO) THEN
        SRHO=.TRUE.
      ELSE IF(.NOT.TDIAG) THEN
        SRHO=.FALSE.
      ENDIF
C     Check for distributed linear algebra
      IF(TDMAL.AND.(NPROC.LE.1)) THEN
        WRITE(*,*) ' YOU HAVE A SINGLE TASK!!!',
     &             ' TURNING OFF DISTRIBUTED LINEAR ALGEBRA'
        TDMAL=.FALSE.
        NSTBLK=1
      ENDIF
C     ==--------------------------------------------------------------==
C     CB Some (probably insufficient) checks for BS
      IF(BSYMM) THEN
#ifdef PARALLEL
        WRITE(*,*) ' !WARNING: PARALLEL BS CODE IS UNDER CONSTRUCTION!'
#endif
        IF(.NOT.(WFOPT.OR.(MD.AND.TMDBO))) THEN
          WRITE(*,*) ' CURRENTLY ONLY WF OPTIMIZATION',
     &               ' AND BO MOLECULAR DYNAMICS',     
     &               ' ARE IMPLEMENTED FOR BROKEN SYMMETRY.'
          CALL STOPGM('CONTROL','BROKEN SYMMETRY & UNSUPPORTED')
        ENDIF  
        IF(TPATH.OR.TLSE.OR.TKPNT.OR.TDIAG) THEN
          WRITE(*,*) ' PI, K-POINTS, LSE, AND KS DIAGONALIZATION',
     &               ' ARE NOT IMPLEMENTED FOR BROKEN SYMMETRY.'
          CALL STOPGM('CONTROL','BROKEN SYMMETRY & UNSUPPORTED')
        ENDIF  
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
