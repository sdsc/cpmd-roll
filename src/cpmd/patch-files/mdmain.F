C     ==================================================================
      SUBROUTINE MDMAIN(C0,CM,C2,SC0,GAMX,GAMY)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'cnst.inc'
      INCLUDE 'ener.inc'
      INCLUDE 'elct.inc'
      INCLUDE 'tpar.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'soft.inc'
      INCLUDE 'nose.inc'
      INCLUDE 'norm.inc'
      INCLUDE 'ropt.inc'
      INCLUDE 'cppt.inc'
      INCLUDE 'coor.inc'
      INCLUDE 'geq0.inc'
      INCLUDE 'spin.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'nlcc.inc'
      INCLUDE 'cotr.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'store.inc'
      INCLUDE 'kpts.inc'
      INCLUDE 'wann.inc'
      INCLUDE 'cnst_dyn.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'comvel.inc'
      INCLUDE 'bsym.inc'
      INCLUDE 'bsympnt.inc'
      INCLUDE 'fileopen.inc'
#ifdef _BGL_MES
      external apc_init
      external apc_finalize
#endif
!
C     Arguments
      COMPLEX*16 C0(NGW,N,*),CM(NGW,N,*),C2(NGW,N,*),SC0(NGW,N,*)
      REAL*8     GAMX(N*N,*),GAMY(N*N,*)
C     Variables
      DIMENSION  F(*)
      CHARACTER  FILEN*100
      LOGICAL    FERROR,TESTSTORE
      REAL*8     TAUI(3,NAX,NSX),TAUR(3,NAX,NSX)
      REAL*8     EIGV(N,BSFAC),EIGM(N*N,BSFAC) 
      POINTER    (IP_TAUI,TAUI), (IP_TAUR,TAUR),
     *           (IP_EIGV,EIGV),(IP_EIGM,EIGM)
      COMPLEX*16 PSI(NNR1,NLSD)
      REAL*8     RHOE(NNR1,NLSD),SCR(*),TAUIO(3,*)
      POINTER    (IP_PSI,PSI),(IP_RHOE,RHOE),(IP_SCR,SCR),
     &    (IP_TAUIO,TAUIO)
      CHARACTER  TAG*30
      REAL*8     TIME1,TIME2,TIMEF,TEMP1,TEMP2,TCPU,TEMPP,DUMMY,FF,
     &           EKIN1,EKIN2,EKINC,EKINP,EKINCP,DISA,ENOSE,ENOSP,
     &           ECONS,EHAM,EKINH1,EKINH2,VCMIO(4),LMIO(3)
      EXTERNAL   TIMEF
      REAL*8     ETOTBS,ETOTHS,SPD_BS,SPD_HS,SPDA_BS,SPDA_HS,
     &           ENOSBS,ENOSHS,DUM1,DUM2,SCALHS,SCALBS
      INTEGER    IREC(100),I,NSTATE,
     &           IL_RHOE,IL_PSI,LSCR
      INTEGER    MSGLEN, ITEMP,IS,IA
C     META DYNAMICS
      LOGICAL    LQUENCH,LMETARES,RESETCV
      REAL*8     EK_CV
#if defined (__QMECHCOUPL)
C     QM/MM
      LOGICAL qmmech
      REAL*8  MM_EKIN
      REAL*8  MM_TEMP
#endif
C     BROKEN SYMMETRY
      REAL*8 COUPLJ, JWN
C     ==================================================================
      TIME1 = TIMEF()
      CALL MEMORY(IP_TAUP,3*NAX*NSX,'TAUP')
      CALL MEMORY(IP_FION,3*NAX*NSX,'FION')
      CALL MEMORY(IP_TAUI,3*NAX*NSX,'TAUI')
      CALL MEMORY(IP_TAUR,3*NAX*NSX,'TAUR')
      IF(TSUBROT) CALL MEMORY(IP_TAUIO,3*NAT,'TAUIO')
      IF(BSYMM)   CALL MEMORY(IP_FNBS,3*NAX*NSX,'FNBS')
      IF(LCOLVARDYN) THEN
        CALL MEMORY(IP_FHILLS,3*NAX*NSX,'FHILLS')
        CALL AZZERO(FHILLS,3*NAX*NSX)
      ENDIF
c     Initialize logical variable for Metadynamics
      LMETARES=.FALSE.
      NSTATE=N 
      NACC = 22
      MODENS=.FALSE. 
      ENGPRI=.FALSE. 
      CALSTE=TPRES  
      IF(TIVAN) NONORT=.TRUE. 
      IF(NONORT) THEN
        CALL MEMORY(IP_EIGV,NSTATE*BSFAC,'EIGV')
        CALL MEMORY(IP_EIGM,NSTATE*NSTATE*BSFAC,'EIGM')
      ENDIF                              
C     SCALING FACTORS FOR ELEC. KINETIC ENERGIES FOR BROKEN SYMMETRY
      IF(BSYMM)THEN
        SCALHS = -1.0D0*CNSTWGT
        SCALBS =  1.0D0+CNSTWGT
      END IF
C
      IF(THARM.AND.PARENT) THEN
        FF=F(1)
        DO I=1,NSTATE
          IF(FF.NE.F(I)) THEN
            WRITE(*,'(A,A)') ' HARMONIC REFERENCE SYSTEM INTEGRATION',
     *             ' ONLY POSSIBLE WITH EQUAL OCCUPATION NUMBERS'
            CALL STOPGM('MDMAIN','FATAL ERROR')
          ENDIF
        ENDDO
      ENDIF
C     ==--------------------------------------------------------------==
C     SCR ALLOCATION AND PARTITION (SCRATCH ARRAY).
      CALL RHOE_PSI_SIZE(IL_RHOE,IL_PSI)
      CALL MEMORY(IP_RHOE,IL_RHOE,'RHOE')
      CALL MEMORY(IP_PSI,IL_PSI,'PSI')
      CALL GIVE_SCR_MDMAIN(LSCR,TAG)
      CALL MEMORY(IP_SCR,LSCR,'SCR')
C     ==--------------------------------------------------------------==
99999 IF(TSAMPL) THEN
        EXSOFT=.FALSE.
        CALL SAMPLE_WAIT
        IF(NOMORE.LT.0) GOTO 10000
      ENDIF
      NFNOW=1
C     ==--------------------------------------------------------------==
C     TIME STEP FUNCTIONS
      CALL DYNIT(EKINCP,EKIN1,EKIN2,TEMP1,TEMP2,EKINH1,EKINH2)
C     PARAMETERS FOR THE NOSE-HOOVER THERMOSTATS
      IF((TNOSEE.OR.TNOSEP).AND.PARENT) CALL NOSEPA(1,1)
C     Dont symmetrize density 
      TSYMRHO=.FALSE.
C     ==--------------------------------------------------------------==
C     == INITIALIZATION                                               ==
C     ==--------------------------------------------------------------==
C     BROKEN SYMMETRY: INITIALIZE BROKEN SYMM. STATE
 333  FORMAT (/,T2,A,/)
      IF(BSYMM)THEN
          BSCLCS=1   
          IF(PARENT)WRITE(6,333) 'BROKEN SYMMETRY STATE IS INITIALIZING'
      END IF 
      CALL INITRUN(IREC,C0,CM,SC0,RHOE,PSI,EIGV,SCR,LSCR)
C     BROKEN SYMMETRY: INITIALIZE HIGH SPIN STATE
      IF(BSYMM)THEN 
          BSCLCS=2
          IF(PARENT)WRITE(6,333) 'HIGH SPIN STATE IS INITIALIZING'
           CALL SETBSSTATE
           CALL INITRUN(IREC,C0(1,1,2),CM(1,1,2),SC0(1,1,2),RHOE,
     &                  PSI,EIGV(1,2),SCR,LSCR)
          IF(PARENT)WRITE(6,333) 'BROKEN SYMMETRY INIT SUCCESSFUL'
      END IF 
C
      MSGLEN = 3*NAX*NSX * 8
      CALL MY_BCAST(TAUP,MSGLEN,SOURCE,ALLGRP)
      CALL DCOPY(3*NAX*NSX,TAUP,1,TAUI,1)
C
C     NN: BROKEN SYMMETRY: QUENCHING TO BO SURFACE OF BS STATE
      IF(QUENCHB) THEN
        IF(BSYMM)THEN
          BSCLCS=1
          CALL SETBSSTATE
          IF(PARENT) WRITE(6,333) 'QUENCHING BROKEN SYMMETRY STATE'
        ENDIF
        CALL QUENBO(C0,C2,SC0,TAUR,RHOE,PSI,SCR,LSCR) 
        CALL ZHWWF(2,IREC,C0,CM,NSTATE,EIGV,TAU0,VELP,TAUI,NFI)
C       NN: BROKEN SYMMETRY: QUENCHING TO BO SURFACE OF HS STATE
        IF(BSYMM)THEN
          BSCLCS=2
          CALL SETBSSTATE
          IF(PARENT) WRITE(6,333) 'QUENCHING HIGH SPIN STATE'
          CALL QUENBO(C0(1,1,2),C2(1,1,2),SC0(1,1,2),TAUR,
     &               RHOE,PSI,SCR,LSCR)
          CALL ZHWWF(2,IREC,C0(1,1,2),CM(1,1,2),NSTATE,EIGV(1,2),
     &               TAU0,VELP,TAUI,NFI)
        ENDIF
        QUENCHB=.FALSE.
      ENDIF
C
      IF(TIVAN) THEN
        IF(TLSD) THEN 
          BSCLCS=1
          IF(BSYMM)CALL SETBSSTATE
          CALL DEORT(NGW,NSUP,EIGM,EIGV,C0(1,1,1),SC0(1,1,1),SCR,LSCR)
          CALL DEORT(NGW,NSDOWN,EIGM,EIGV,C0(1,NSUP+1,1),
     *               SC0(1,NSUP+1,1),SCR,LSCR)
C       
          IF(BSYMM)THEN 
            BSCLCS=2
            CALL SETBSSTATE
            CALL DEORT(NGW,NSUP,EIGM(1,2),EIGV(1,2),C0(1,1,2),
     &                 SC0(1,1,2),SCR,LSCR)
            CALL DEORT(NGW,NSDOWN,EIGM(1,2),EIGV(1,2),C0(1,NSUP+1,2),
     *                SC0(1,NSUP+1,2),SCR,LSCR)
          ENDIF 
        ELSE
          CALL DEORT(NGW,NSTATE,EIGM,EIGV,C0,SC0,SCR,LSCR)
        ENDIF
      ENDIF
C     INITIALIZE VELOCITIES
      IF(PARENT) CALL DETDOF(TAU0,TAUR) 

C     INITIALIZE METADYNAMICS VARIABLES used also for 
C     SHOOTING from SADDLE POINT with RANDOM VELOCITIES
      IF(PARENT .AND. (LCOLVARDYN .OR. LSADPNT)) THEN        
          CALL COLVAR_STRUCTURE(TAU0,TAUR)
      ENDIF

      IF(IREC(IREC_VEL).EQ.0.AND..NOT.RGEO) THEN
        ECNSTR = 0.0D0
        ERESTR = 0.0D0
        CALL RINVEL(VELP,CM,N)
        IF(PARENT) CALL TAUCL(VELP)
        IF(PARENT)  CALL RATTLE(TAU0,VELP)
        CALL RVSCAL(VELP)
      ELSE
        IF(PARENT) CALL TAUCL(VELP)
        IF(PARENT)  CALL RATTLE(TAU0,VELP)
        IF(TRESCALE) CALL RVSCAL(VELP)
      ENDIF
C       FOR NO RESTART THE VELOCITIES OF THE COEFFICIENTS OF THE 
C       BS_STATE AND HS_STATE ARE SET TO ZERO
      IF(BSYMM.AND.IREC(IREC_VEL).EQ.0) 
     &            CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
      IF(QUENCHP) CALL AZZERO(VELP,3*NAX*NSX)
      IF(QUENCHE) CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
      IF(TREVERS) THEN
C       invert electronic and ionic velocities (useful for path sampling)
        CALL DSCAL(2*NGW*NSTATE*BSFAC,-1.D0,CM,1)
        CALL DSCAL(3*NAX*NSX,-1.D0,VELP,1)
      ENDIF
C     RESET ACCUMULATORS
      IF(PARENT.AND.IREC(IREC_AC).EQ.0)
     &     CALL RESETAC(TAU0,TAUI,NFI)
C..-------------------------------------------------
C..QM/MM coupling by Roethlisberger Group
C..Initailize Molecular Mechanics subsystem:
C..-------------------------------------------------
C..
#if defined (__QMECHCOUPL)
      IF (PARENT) THEN
C       ---------------------------------------------------------
C       CORE QM/MM initilization
C        Please note this is the same routine used to initialize
C        the QMMM functionality during a geometry optimization.
C        MD specific initialization is performed by the routine
C        'mm_cpmd_md_init'.
C       ---------------------------------------------------------
        CALL mm_cpmd_init (TQMMECH,TAU0,NA,NSP,NAX,NAT,RCO,RVEL,TEMPW)
C       -------------
C       set QMMM flag
C       -------------
        IF(TQMMECH) THEN
          CALL mm_run(qmmech)
        ELSE
          qmmech=.false.
        ENDIF
C       -----------------------------------
C       initialize QM/MM Molecular Dynamics
C       -----------------------------------
        if (qmmech) then
          MM_EKIN = 0.0d0
          MM_TEMP = 0.0d0
          CALL mm_cpmd_md_init
          call mm_cpmd_ext_pot_f77
          CALL mm_cpmd_update_links(TAU0, NA, NSP, NAX, NAT)
        end if
      END IF
#endif
C     INITIALIZE FORCES
      IF(PARENT) THEN
        WRITE(*,'(1X,64("="))')
        WRITE(*,'(1X,"==",T25,A,T64,"==")') 'FORCES INITIALIZATION'
        WRITE(*,'(1X,64("="))')
      ENDIF
      IF(TKPNT) THEN
        IF(GEQ0) CALL ZCLEAN_K(C0,NSTATE,NGW)
      ELSE
        IF(GEQ0) CALL ZCLEAN(C0,NSTATE,NGW)
      ENDIF
C     FORCES FOR BROKEN SYMMETRY STATE 
      IF(BSYMM)THEN
         BSCLCS=1
         CALL SETBSSTATE
      END IF
      CALL FORCEDR(C0,C2,SC0,RHOE,PSI,
     .             TAU0,FION,EIGV,SCR,LSCR,NSTATE,1,.FALSE.,.TRUE.)
C     STORE THE SPIN DENSITIES FOR PRINTING
      IF(BSYMM) THEN
        SPD_BS=CSUMS   
        SPDA_BS=CSUMSABS
C     FORCES FOR BROKEN SYMMETRY STATE 
        IF(PARENT)THEN
           ETOTBS=ETOT
C          STORING THE FORCES FOR BROKEN SYMMETRY STATE
           CALL DCOPY(3*NAX*NSX,FION,1,FNBS,1)
        END IF
C       FORCES FOR HIGH SPIN STATE 
        BSCLCS=2
        CALL SETBSSTATE
        CALL FORCEDR(C0(1,1,2),C2(1,1,2),SC0(1,1,2),RHOE,PSI,
     *     TAU0,FION,EIGV(1,2),SCR,LSCR,NSTATE,1,.FALSE.,.TRUE.)
C       STORE THE SPIN DENSITIES FOR PRINTING
        SPD_HS =CSUMS     
        SPDA_HS=CSUMSABS
C       EVALUATE ENERGY AND FORCE FOR LOW SPIN STATE 
        IF(PARENT)THEN
           ETOTHS=ETOT
           ETOT = (1.0D0 + CNSTWGT) * ETOTBS - CNSTWGT * ETOTHS
           CALL LSFORCE(FNBS,FION)
        END IF 
      END IF
C     Initialize Metadynamics contributions
      IF(LCOLVARDYN .AND. LEXTLAGRANGE) THEN
        LQUENCH = .FALSE.
        LMETARES= .FALSE.
        RESETCV = .FALSE.
        IF(TMULTI) THEN
          CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &                LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
        ELSE

          CALL META_EXTLAGR(TAU0,VELP,TAUR,SCR,LSCR,
     &            LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
        ENDIF
      ENDIF

      CALL FREQS(N,.TRUE.)
C     Check orthogonality condition for wavefunction velocities
C     SET UP BROKEN SYMMETRY STATE
      IF(BSYMM)THEN
        BSCLCS=1
        CALL SETBSSTATE
      END IF
      CALL RORTV(C0,CM,C2,SC0,GAMY,NSTATE,SCR,LSCR)
C     SET UP HIGH SPIN STATE
      IF(BSYMM)THEN 
        BSCLCS=2
        CALL SETBSSTATE
        CALL RORTV(C0(1,1,2),CM(1,1,2),C2(1,1,2),SC0(1,1,2),
     &             GAMY(1,2),NSTATE,SCR,LSCR)
      END IF 
C     Initialize thermostats
      IF(PARENT) THEN
        ITEMP=IREC(IREC_NOP1)+IREC(IREC_NOP2)+IREC(IREC_NOP3)
     *        +IREC(IREC_NOP4)
        IF(TNOSEP .AND. ITEMP.EQ.0) CALL NOSPINIT(1)
        IF(TNOSEE .AND. IREC(IREC_NOE) .EQ.0) THEN
C          THERMOSTAT FOR BROKEN SYMMETRY STATE WAVEFUNCTIONS
           CALL NOSEINIT(1)          
C          THERMOSTAT FOR HIGH SPIN STATE WAVEFUNCTIONS
           IF(BSYMM)CALL NOSEINIT(2) 
        END IF 
        CALL WRGEO(TAU0)
        FILEN='ENERGIES'
        CALL FILEOPEN(3,FILEN,FO_APP+FO_VERB,FERROR)
        IF(BSYMM) THEN
C     OPEN OUTPUT DATA FILE FOR BROKEN SYMMETRY
          FILEN='BS_ENERG'
          WRITE(6,'(/,2A)')
     &         '  BROKEN SYMMETRY DATA WILL BE WRITTEN IN ',FILEN
          WRITE(6,'(/,A,/)')
     &         '  DATA IN BS_ENERG:'
          WRITE(6,'(2A,/)')
     &         '  Step #, EKINC_BS, EKINC_HS, ETOT_LS, ETOT_BS,', 
     &         ' ETOT_HS, Spin-density-BS, ..-HS, '
          WRITE(6,'(2A,/)')
     &         '  Absolute-spin-density-BS, ..-HS,',
     &         ' Coupling constant J in a.u., J in cm-1 ' 
C
          CALL FILEOPEN(77,FILEN,FO_APP+FO_VERB,FERROR)
        ENDIF
      ENDIF
      IF(PARENT) THEN
        WRITE(*,'(1X,64("="))')
        WRITE(*,'(1X,"==",T20,A,T64,"==")')
     .                                    'END OF FORCES INITIALIZATION'
        WRITE(*,'(1X,64("="),/)')
      ENDIF
      CALL WRITE_IREC(IREC)
C     EVALUATE KINETIC ENERGY FOR BROKEN SYMMETRY STATE WAVEFUNCTIONS
      IF(BSYMM)THEN
        CALL REKINE(CM,NSTATE,EKINC)
        EKINC_BS=EKINC
C       EVALUATE KINETIC ENERGY FOR HIGH SPIN STATE WAVEFUNCTIONS
        CALL REKINE(CM(1,1,2),NSTATE,EKINC)
        EKINC_HS=EKINC
      END IF
C     ==--------------------------------------------------------------==
C     == END INITIALIZATION                                           ==
C     ==--------------------------------------------------------------==
      IF(TESTSTORE(0).AND.TSAMPL)
     *    CALL ZHWWF(2,IREC,C0,CM,NSTATE,EIGV,TAUP,VELP,TAUI,NFI)
      IF(PARENT) THEN
        TIME2 = TIMEF()
        TCPU = (TIME2 - TIME1)*0.001D0
        WRITE(*,'(A,T50,F8.2,A8)') ' TIME FOR INITIALIZATION:',
     *                        TCPU,' SECONDS'
      ENDIF
C     ==================================================================
C     ==          THE BASIC LOOP FOR MOLECULAR DYNAMICS               ==
C     ==                 USING VELOCITY VERLET                        ==
C     ==================================================================
#ifdef _BGL_MES
      call apc_init()
#endif
      DO INFI=1,NOMORE
        CALL MY_SYNC(ALLGRP)
        TIME1=TIMEF()
        NFI=NFI+1
        PRTEIG=TPRINT.AND.MOD(NFI-1,IPRINT_STEP).EQ.0
        CALDIP=TDIPD.AND.MOD(NFI-1,NPDIP).EQ.0
        SUBCOM=TSUBCOM.AND.MOD(NFI-1,NCOMV).EQ.0
        SUBROT=TSUBROT.AND.MOD(NFI-1,NROTV).EQ.0
        IF(.NOT.PARENT) PRTEIG=.FALSE.
        ENGPRI=TPRINT.AND.MOD(NFI-1,IPRINT_STEP).EQ.0
C       ANNEALING
        BSCLCS=1
        CALL BERENDSEN(VELP,CM(1,1,1),NSTATE,SCR,EKINC,0.0D0)
        CALL ANNEAL(VELP,CM(1,1,1),NSTATE,SCR)
        IF(BSYMM)THEN
          BSCLCS=2
          CALL ANNEAL(VELP,CM(1,1,2),NSTATE,SCR)
          CALL BERENDSEN(VELP,CM(1,1,2),NSTATE,SCR,EKINC,0.0D0)
        END IF
C       SUBTRACT CENTER OF MASS VELOCITY
        IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.TRUE.)
C       SUBTRACT ROTATION AROUND CENTER OF MASS
        IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.TRUE.)
C       UPDATE NOSE THERMOSTATS
C       -FOR BROKEN SYMMETRY
        BSCLCS=1 
        CALL NOSEUP(VELP,CM,NSTATE,1)
C       -FOR HIGH SPIN 
        IF(BSYMM)THEN
          BSCLCS=2 
          CALL NOSEUP(VELP,CM(1,1,2),NSTATE,2)
        END IF
C       UPDATE VELOCITIES
        IF(PARENT) CALL VELUPI(VELP,FION,1)
C       UPDATE BROKEN SYMMETRY WF VELOCITIES
        CALL VELUPA(C0,CM,C2,NSTATE,1)
C       UPDATE HIGH SPIN WF VELOCITIES
        IF(BSYMM)CALL VELUPA(C0(1,1,2),CM(1,1,2),C2(1,1,2),NSTATE,1)
#if defined (__QMECHCOUPL)
        if (PARENT .and. qmmech) then
          CALL mm_cpmd_velup(DELT_IONS)
        end if
#endif
C       UPDATE POSITIONS
        ECNSTR = 0.0D0
        ERESTR = 0.0D0
        IF(PARENT) THEN
          CALL POSUPI(TAU0,TAUP,VELP)
        ENDIF

        IF(PARENT) THEN
          IF(MCNSTR.NE.0) THEN
            CALL CPMDSHAKE(TAU0,TAUP,VELP)
          ENDIF
#if defined (__QMECHCOUPL)
          if (qmmech) then
            CALL mm_cpmd_update_links(TAUP, NA, NSP, NAX, NAT)
            CALL mm_cpmd_posup(DELT_IONS)
          end if
#endif
        ENDIF

        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(TAUP,MSGLEN,SOURCE,ALLGRP)
        CALL PHFAC(TAUP)
        IF(TINLC) CALL COPOT(RHOE,PSI,SCR,LSCR,CALSTE)
C       BROKEN SYMMETRY WF UPDATED USING VELOCITY VERLET
        BSCLCS=1
        IF(BSYMM)CALL SETBSSTATE
        CALL POSUPA(C0,CM,C2,GAMX,NSTATE,SCR,LSCR)
C       HIGH SPIN WF UPDATED USING VELOCITY VERLET
        IF(BSYMM)THEN
          BSCLCS=2
          CALL SETBSSTATE
          CALL POSUPA(C0(1,1,2),CM(1,1,2),C2(1,1,2),GAMX(1,2),
     &                NSTATE,SCR,LSCR)
        END IF
C..Dipole moment
C       !!! NOT ACTIVATED FOR BROKEN SYMMETRY !!!
        IF(CALDIP.AND.(.NOT.BSYMM)) THEN 
          CALL DDIPO(TAUP,C0,CM,C2,SC0,SCR,LSCR,NSTATE)
          CALL WANNIER_PRINT(NFI,C0,TAUP,NSTATE,PSI,SCR,LSCR)
        ENDIF
C       CALCULATE THE FORCES
        CALSTE=TPRES.AND.MOD(NFI-1,NPRES).EQ.0
C       FOR BROKEN SYMMETRY STATE
        BSCLCS=1
        IF(BSYMM)CALL SETBSSTATE
        CALL FORCEDR(C0,C2,SC0,RHOE,PSI,TAUP,FION,EIGV,SCR,LSCR,
     *               NSTATE,1,.FALSE.,.TRUE.)
        IF(BSYMM) THEN
          SPD_BS=CSUMS
          SPDA_BS=CSUMSABS
          IF(PARENT)THEN 
            ETOTBS=ETOT
            CALL DCOPY(3*NAX*NSX,FION,1,FNBS,1)
          END IF
C         FOR HIGH SPIN STATE
          BSCLCS=2
          CALL SETBSSTATE
          CALL FORCEDR(C0(1,1,2),C2(1,1,2),SC0(1,1,2),RHOE,PSI,TAUP,
     &                 FION,EIGV(1,2),SCR,LSCR,NSTATE,1,.FALSE.,.TRUE.)
            SPD_HS=CSUMS
            SPDA_HS=CSUMSABS
C         ENERGY AND FORCES FOR LOW SPIN STATE 
          IF(PARENT)THEN
            ETOTHS=ETOT
            ETOT = (1.0D0 + CNSTWGT) * ETOTBS - CNSTWGT * ETOTHS
            CALL LSFORCE(FNBS,FION)
          END IF
        END IF
C     ==================================================================
C       Damped Dynamics
        CALL DAMPDYN(VELP,FION,CM(1,1,1),C2(1,1,1),NSTATE,
     &      SCR(1),SCR(10))
        IF(BSYMM)THEN
          BSCLCS=2
          CALL DAMPDYN(VELP,FION,CM(1,1,2),C2(1,1,2),NSTATE,
     &        SCR(1),SCR(10))
        END IF
C     ==================================================================
C       Meta Dynamics of Collective Variables

        IF(LCOLVARDYN) THEN 
          LQUENCH = .FALSE.
          LMETARES= .FALSE.

          IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
            IF(TMULTI) THEN
              CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &                LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
            ELSE
              CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &                LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
            ENDIF 
          ELSE
C     Time dipendent potential applied directly on the Collective Variables
            CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &                      LQUENCH,LMETARES,EKINC,EKINP)
          ENDIF

          IF((TOLKIN.GT.0.0D0 .AND. EKINC.GT.TOLKIN)
     &               .OR. LQUENCH) THEN
C     Check for Quench on the BO surface
            BSCLCS=1
            IF(BSYMM)CALL SETBSSTATE
            QUENCHB=.TRUE.
            CALL QUENBO(C0,C2,SC0,TAUR,RHOE,PSI,SCR,LSCR)
            IF(BSYMM)THEN
              BSCLCS=2
              CALL SETBSSTATE
              CALL QUENBO(C0(1,1,2),C2(1,1,2),SC0(1,1,2),TAUR,RHOE,
     &                    PSI,SCR,LSCR)
            END IF
            CALL AZZERO(CM,2*NSTATE*NGWK*BSFAC)           
            RESETCV=.TRUE.
            QUENCHB=.FALSE.
          ENDIF
        ENDIF

C     ==================================================================
C       From saddle point to minima

        IF(LSADPNT) THEN
C    Check on the predefined  known minima 
          CALL TST2MIN(TAUP,TAUR,NFI)
C    If one minimum is found the search is initialized as new (random vel.)
          IF(LMDREINIT) THEN
            RESTART = .TRUE.
            IF(PARENT) CALL FILECLOSE(3)
            GOTO   99999
          ENDIF 

        ENDIF

C     ==================================================================
        IF(LCOLVARDYN .AND. PARENT) THEN 

C     Additional Contribution to FION due to the Metadynamics
C     (from coupling pot.if extended Lagrangian, directly from V(S,t) if not)
          DO IS = 1,NSP
            DO IA = 1,NA(IS)
              FION(1,IA,IS) = FION(1,IA,IS) + FHILLS(1,IA,IS)
              FION(2,IA,IS) = FION(2,IA,IS) + FHILLS(2,IA,IS)
              FION(3,IA,IS) = FION(3,IA,IS) + FHILLS(3,IA,IS)
            ENDDO
          ENDDO
        ENDIF


        IF(CALSTE) CALL TOTSTR
#if defined (__QMECHCOUPL)
C       ----------------------------------------------
C       QMMM electrostatic coupling
C       ----------------------------------------------
        if (qmmech) then
          call mm_cpmd_ext_pot_f77
          call mm_cpmd_elstat(TAUP,NA,NSP,NAX,NAT,C0,SCR)
        end if
#endif
C       FINAL UPDATE FOR VELOCITIES
        ECNSTR = 0.0D0
        ERESTR = 0.0D0
        IF(PARENT) THEN
          CALL VELUPI(VELP,FION,1)
#if defined (__QMECHCOUPL)
          if (qmmech) then
            CALL mm_cpmd_velup(DELT_IONS)
          end if
#endif
          CALL RATTLE(TAUP,VELP)
        ENDIF
C       UPDATE BROKEN_SYMMETRY_WAVEFUNCTION_VELOCITIES
        BSCLCS=1
        IF(BSYMM)CALL SETBSSTATE
        CALL VELUPA(C0,CM,C2,NSTATE,1)
        CALL RORTV(C0,CM,C2,SC0,GAMY,NSTATE,SCR,LSCR)
C       UPDATE HIGH_SPIN_WAVEFUNCTION_VELOCITIES
        IF(BSYMM)THEN
          BSCLCS=2
          CALL SETBSSTATE
          CALL VELUPA(C0(1,1,2),CM(1,1,2),C2(1,1,2),NSTATE,1)
          CALL RORTV(C0(1,1,2),CM(1,1,2),C2(1,1,2),SC0(1,1,2),
     &               GAMY(1,2),NSTATE,SCR,LSCR)
        END IF

        IF(PARENT) CALL GEOFILE(TAUP,VELP,'WRITE')
C       COMPUTE THE IONIC TEMPERATURE TEMPP
        IF(PARENT) THEN
          CALL EKINPP(EKINP,VELP)
          IF(LEXTLAGRANGE.AND. LTCGLOBAL) THEN
            CALL EKINCV_GLOBAL(EK_CV)
            TEMPP=(EK_CV+EKINP)*FACTEM*2.D0/(GLIB+DBLE(NCOLVAR))
          ELSE 
            TEMPP=EKINP*FACTEM*2.D0/GLIB
          ENDIF  
#if defined (__QMECHCOUPL)
C         -------------------------------------------------
C         TEMPERTURE and KINETIC ENERGY of the MM subsystem
C           MM_EKIN + EKINP = KE of whole QM/MM system
C         -------------------------------------------------
          if (qmmech) then
            CALL mm_cpmd_ekin(MM_EKIN,MM_TEMP)
          end if
#endif
        ENDIF
C       IONIC TEMPERATURE CONTROL
        IF(PARENT) CALL RSCVP(TEMP1,TEMP2,TEMPP,VELP)
C       SUBTRACT ROTATION AROUND CENTER OF MASS
        IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.FALSE.)
C       SUBTRACT CENTER OF MASS VELOCITY
        IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.FALSE.)
#if defined (__QMECHCOUPL)
C       ---------------------------------------------------------------
C       MM Temperature control - annealing schedule not yet implemented
C       ---------------------------------------------------------------
        IF (PARENT .and. qmmech) THEN
          call mm_cpmd_temp_control(TEMP1,TEMP2,MM_TEMP,TCP)
          call mm_cpmd_ekin(MM_EKIN,MM_TEMP)
        END IF
#endif
C       UPDATE NOSE THERMOSTATS
        IF(TNOSEE.OR.TC) THEN
           CALL REKINE(CM,NSTATE,EKINC)
           IF(BSYMM)THEN
             EKINC_BS=EKINC
             CALL REKINE(CM(1,1,2),NSTATE,EKINC)
             EKINC_HS=EKINC
           END IF
        END IF
C       UPDATE FOR BROKEN SYMMETRY 
        BSCLCS=1 
        CALL NOSEUP(VELP,CM,NSTATE,1)
        CALL BERENDSEN(VELP,CM(1,1,1),NSTATE,SCR,EKINC,0.0D0)
C       UPDATE FOR HIGH SPIN 
        IF(BSYMM)THEN
          BSCLCS=2  
          CALL NOSEUP(VELP,CM(1,1,2),NSTATE,2)
          CALL BERENDSEN(VELP,CM(1,1,2),NSTATE,SCR,EKINC,0.0D0)
        END IF
C       ANNEALING
C       -FOR BROKEN SYMMETRY
        BSCLCS=1
        CALL ANNEAL(VELP,CM,NSTATE,SCR)
C       FOR HIGH SPIN
        IF(BSYMM)THEN
          BSCLCS=2
          CALL ANNEAL(VELP,CM(1,1,2),NSTATE,SCR)
        END IF
        IF(PARENT) THEN
          CALL EKINPP(EKINP,VELP)
          IF(LEXTLAGRANGE.AND. LTCGLOBAL) THEN
            CALL EKINCV_GLOBAL(EK_CV)
            TEMPP=(EK_CV+EKINP)*FACTEM*2.D0/(GLIB+DBLE(NCOLVAR))
          ELSE 
            TEMPP=EKINP*FACTEM*2.D0/GLIB
          ENDIF 
        ENDIF
C       RESCALE ELECTRONIC VELOCITIES
        IF((.NOT.BSYMM).AND.TC) 
     &       CALL RSCVE(EKIN1,EKIN2,EKINC,EKINW,CM,NSTATE,NGW)
C       RESCALE BROKEN SYMMETRY AND HIGH SPIN ELECTRONIC VELOCITIES
        IF(BSYMM.AND.TC)THEN
            CALL RSCVE(EKIN1,EKIN2,EKINC_BS,EKINW,CM,NSTATE,NGW)
            CALL RSCVE(EKIN1,EKIN2,EKINC_HS,EKINW,CM(1,1,2),NSTATE,NGW)
        END IF
C       MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
        IF(PARENT) CALL DISPP(TAUP,TAUI,DISA)
C       KINETIC ENERGY OF THE ELECTRONS
        CALL REKINE(CM,NSTATE,EKINC)
        IF(BSYMM)THEN 
           EKINC_BS=EKINC
           CALL REKINE(CM(1,1,2),NSTATE,EKINC)
           EKINC_HS=EKINC
C          PROJECTED KINETIC ENERGY OF ELECTRONS
           EKINC=(SCALHS*EKINC_HS)+(SCALBS*EKINC_BS)
        END IF
C       ENERGY OF THE NOSE THERMOSTATS
        IF(PARENT) THEN
          BSCLCS=1
          CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
          IF(BSYMM)THEN
            ENOSBS=ENOSE
            BSCLCS=2
            CALL NOSENG(NFI,VELP,ENOSE,DUM1,DUM2,2)
            ENOSHS=ENOSE
            ENOSE=(SCALBS*ENOSBS)+(SCALHS*ENOSHS) 
          END IF
        END IF
        IF(PARENT) THEN
          ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR+ERESTR+EKINCV+VHARM
C
#if defined (__QMECHCOUPL)
          if (qmmech) then
            ECONS=ECONS + MM_EKIN
            write (6,'(50x, "TEMP: ",f10.0)') MM_TEMP
          end if
#endif
          EHAM=ECONS+EKINC
          EHAM_HILL = EHAM
          TIME2=TIMEF()
          TCPU=(TIME2-TIME1)*0.001D0
C         Printing data of Broken symmetry calculation
          IF(BSYMM) THEN
            COUPLJ = (ETOTHS - ETOTBS) * RTSASB
            JWN=COUPLJ*AUTOCM
            WRITE(77,'(I10,11F16.8)')
     &           NFI,EKINC_BS,EKINC_HS,ETOT,ETOTBS,ETOTHS,SPD_BS,
     &           SPD_HS,SPDA_BS,SPDA_HS,COUPLJ,JWN
          END IF
C         PRINTOUT the evolution of the accumulators every time step
          CALL WRPRINT_MD(EIGV,F,AMU,NSTATE,TAUP,FION,
     &                    EKINC,TEMPP,ETOT,ECONS,EHAM,DISA,
     &                    TCPU,.FALSE.,NFI,INFI)
C         UPDATE ACCUMULATORS
          CALL PACCA(EKINC,TEMPP,ETOT,ECONS,EHAM,ENOSE,ENOSP,ECNSTR,
     *               ERESTR,DISA,TCPU,NFI,1)
C         Store ionic coordinates and velocities for statistics
          MOVIE=MOUT .AND. MOD(NFI-1,IMOVIE).EQ.0
          RPRINT=ROUT .AND. MOD(NFI-1,NTRAJ).EQ.0
          TXYZ=XTOUT .AND. MOD(NFI-1,NTRAJ).EQ.0
          TDCD=DCOUT .AND. MOD(NFI-1,NTRAJ).EQ.0
          CALL PRINTP(TAUR,TAUP,VELP)
          IF(TWRITEFORCETRAJECTORY) CALL PRINTP2(TAUR,TAUP,VELP,FION)
#if defined (__QMECHCOUPL)
C         --------------------------------------------------------
C..       Write to QMMM trajectory.  This trajectory file contains
C         the atoms that make up the "real" system. (no dummies)
C         --------------------------------------------------------
          if (qmmech) then
            if (ROUT .and. MOD(NFI-1,NTRAJ).EQ.0) then
              call mm_cpmd_write_trajectory(NFI)
            end if
          end if
#endif
        ENDIF
        IF(.NOT. EXSOFT) CALL TESTEX(EXSOFT)
        IF(INFI.EQ.NOMORE) THEN
           EXSOFT=.TRUE.
           EXNOMORE=.TRUE.
        ENDIF
C periodic output of density/wavefunction etc.
        IF(RHOOUT.AND.(NRHOOUT.GT.0)) THEN
          IF (MOD(NFI-1,NRHOOUT).EQ.0) THEN
            CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
          ENDIF
        ENDIF
        IF(TESTSTORE(NFI).OR.EXSOFT.OR.LMETARES) THEN 
          CALL ZHWWF(2,IREC,C0,CM,NSTATE,EIGV,TAUP,VELP,TAUI,NFI)
        ENDIF
        IF(EXSOFT .AND.LCOLVARDYN) THEN
          LMETARES= .TRUE.
          IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
            IF(TMULTI) THEN
              CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &                LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
            ELSE
              CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &                LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
            ENDIF 
          ELSE
C     Time dipendent potential applied directly on the Collective Variables
            CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &                      LQUENCH,LMETARES,EKINC,EKINP)
          ENDIF
        ENDIF
#if defined (__QMECHCOUPL)
C       -----------------------
C       Write QMMM restart file
C       -----------------------
        if (PARENT.and.qmmech) then
          if(MOD(NFI,ISTORE).EQ.0.OR.INFI.EQ.NOMORE.OR.EXSOFT) THEN
            call mm_cpmd_write_restart
          end if
        end if
#endif
C     Calculate EPR and EFG properties (not active for broken symmetry).
        IF(.NOT.BSYMM) CALL EPR_EFG (rhoe,scr,lscr,psi,nfi)
C     temperature ramping
        CALL TEMPRAMP(TEMP1,TEMP2)
C       UPDATE IONIC POSITIONS
        CALL DCOPY(3*NAX*NSX,TAUP(1,1,1),1,TAU0(1,1,1),1)
C       STOP THE RUN IF THE USER HAS SET THE SIGNAL 30
        IF(EXSOFT) GOTO 100
C     ==================================================================
C     ==     END OF MAIN LOOP                                         ==
C     ==================================================================
      ENDDO
#ifdef _BGL_MES
      call apc_finalize()
#endif
  100 CONTINUE
      IF(TWANN) THEN
        CALL DDIPO(TAUP,C0,CM,C2,SC0,SCR,LSCR,NSTATE)
        CALL FORCEDR(C0,C2,SC0,RHOE,PSI,TAUP,FION,EIGV,SCR,LSCR,
     *               NSTATE,1,.FALSE.,.TRUE.)
        CALL WC_DOS(C0,C2,SCR,LSCR,NSTATE)
      ENDIF
      IF(RHOOUT.AND.(NRHOOUT.LE.0))THEN
         BSCLCS=1
         CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
         IF(BSYMM)THEN
           BSCLCS=2
           CALL RHOPRI(C0(1,1,2),TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
         END IF
      END IF
C     PRINT ACCUMULATOR
      IF(PARENT) CALL PACCA(EKINC,TEMPP,ETOT,ECONS,EHAM,ENOSE,ENOSP,
     &                      ECNSTR,ERESTR,DISA,TCPU,NFI,2)
      BSCLCS=1
      IF(BSYMM)CALL SETBSSTATE
      CALL PROJA(C0,C2,SC0,SCR,LSCR,NSTATE,IPROJ)
      IF(BSYMM)THEN
         BSCLCS=2
         CALL SETBSSTATE
         CALL PROJA(C0(1,1,2),C2(1,1,2),SC0(1,1,2),SCR,
     &        LSCR,NSTATE,IPROJ)
      END IF
      BSCLCS=1
      IF(BSYMM)CALL SETBSSTATE
      CALL CSIZE(C2,N,GEMAX,CNORM)
      IF(BSYMM)THEN
        BSCLCS=2
        CALL SETBSSTATE
        CALL CSIZE(C2(1,1,2),N,GEMAX,CNORM)
      END IF  
      IF(PARENT) CALL GSIZE(FION,GNMAX,GNORM)
      IF(PARENT) THEN
        IF(.NOT.BSYMM)THEN
          CALL FINALP(TAU0,FION,VELP,EIGV)
        ELSE
          CALL WRGEOF(TAU0,FION)
        END IF
      END IF
C
      IF(TSAMPL) THEN
        CALL SAMPLE_GO
        GOTO 99999
      ENDIF
10000 CONTINUE
C
      IF(NONORT) THEN
        CALL FREEM(IP_EIGV)
        CALL FREEM(IP_EIGM)
      ENDIF
      IF(PARENT) CALL FILECLOSE(3)
      CALL FREEM(IP_RHOE)
      CALL FREEM(IP_PSI)
      CALL FREEM(IP_SCR)
      IF(TSUBROT) CALL FREEM(IP_TAUIO)
      IF(BSYMM) CALL FREEM(IP_FNBS)
C     NN: CLOSING THE FILE BS_ENG
      IF(BSYMM.AND.PARENT) CALL FILECLOSE(77)
C     ==--------------------------------------------------------------==
      RETURN
      END
C
C     ==================================================================
      SUBROUTINE GIVE_SCR_MDMAIN(LMDMAIN,TAG)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !nlcc.inc TRANE QUENCHB
      INCLUDE 'elct.inc'        !N number of states
      INCLUDE 'nlcc.inc'        !TINLC
      INCLUDE 'store.inc'       !RHOOUT
      INCLUDE 'pslo.inc'        !TIVAN
C     Arguments
      INTEGER   LMDMAIN
      CHARACTER TAG*30
C     Variables
      INTEGER   NSTATE,LCOPOT,LORTHO,LQUENBO,LDEORT,LFORCEDR,
     &          LRORTV,LPOSUPA,LRHOPRI,LDDIPO,LINITRUN,LMTD
C     ==--------------------------------------------------------------==
      NSTATE=N
      LINITRUN=0
      LCOPOT=0
      LORTHO=0
      LQUENBO=0
      LDEORT=0
      LRHOPRI=0
      LDDIPO=0
      CALL GIVE_SCR_INITRUN(LINITRUN,TAG)
      IF(TINLC) CALL GIVE_SCR_COPOT(LCOPOT,TAG)
      IF(TRANE) CALL GIVE_SCR_ORTHO(LORTHO,TAG,NSTATE)
      IF(QUENCHB) CALL GIVE_SCR_QUENBO(LQUENBO,TAG)
      IF(TIVAN) CALL GIVE_SCR_DEORT(LDEORT,TAG,NSTATE)
      IF(TDIPD) CALL GIVE_SCR_DDIPO(LDDIPO,TAG)
      CALL GIVE_SCR_FORCEDR(LFORCEDR,TAG,NSTATE,.FALSE.,.TRUE.)
      CALL GIVE_SCR_RORTV(LRORTV,TAG,NSTATE)
      CALL GIVE_SCR_POSUPA(LPOSUPA,TAG,NSTATE)
      IF(RHOOUT) CALL GIVE_SCR_RHOPRI(LRHOPRI,TAG,NSTATE)
      CALL GIVE_SCR_META_EXTLAGR(LMTD,TAG)
      LMDMAIN=MAX(LCOPOT,LORTHO,LQUENBO,LDEORT,LFORCEDR,
     &            LRORTV,LPOSUPA,LRHOPRI,LDDIPO,LINITRUN,LMTD)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
