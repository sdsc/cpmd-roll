C     ==================================================================
      SUBROUTINE MDDIAG(C0,CM,C1,C2,SC0,VPP,GAMX,GAMY)
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
      INCLUDE 'andr.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'
      INCLUDE 'poin.inc'
      INCLUDE 'kpts.inc'
      INCLUDE 'kpnt.inc'
      INCLUDE 'atwf.inc'
      INCLUDE 'store.inc'
      INCLUDE 'linres.inc'
      INCLUDE 'response_p.inc'
      INCLUDE 'comvel.inc'
      include 'bsym.inc'
      INCLUDE 'cnst_dyn.inc'
      INCLUDE 'fileopen.inc'
      INCLUDE 'mm_extrap.inc'
C     Arguments
C CB: BS case needs two wf (BSFAC=2)
      COMPLEX*16 C0(NGWK,N,*),C2(NGWK,*),C1(*),
     &           CM(*),SC0(NGW,*)
      REAL*8     VPP(*),GAMX(*),GAMY(*)
C     Variables
      DIMENSION  F(N,*),RIN0(*),RK(3,NKPTS),WK(NKPTS)
      REAL*8     TAUI(3,NAX,*),TAUR(3,NAX,*),EIGV(N,*),
     &           RM1(*),RINP(*)
      POINTER    (IP_TAUI,TAUI),(IP_TAUR,TAUR),(IP_EIGV,EIGV),
     &           (IP_RM1,RM1),(IP_RINP,RINP)
      COMPLEX*16 PSI(NNR1,*)
      REAL*8     RHOE(NNR1,*),SCR(*),TAUIO(3,*)
      POINTER    (IP_PSI,PSI),(IP_RHOE,RHOE),(IP_SCR,SCR),
     &    (IP_TAUIO,TAUIO)
      CHARACTER  TAG*30
      REAL*8     TIMEF,TIME1,TIME2,DUMMY,RMEM,
     &           ECONS,EKINP,EKINCP,DISA,ENOSE,ENOSP,EKIN1,EKIN2,
     &           TEMP1,TEMP2,TEMPP,TCPU,EKINH1,EKINH2,VCMIO(4),LMIO(3)
      EXTERNAL   TIMEF
      INTEGER    IREC(100),IFCALC,NX,IK,NNX,
     &           LSCR,IL_RHOE,IL_PSI
      CHARACTER  FILEN*100
      LOGICAL    FERROR,TESTSTORE
      INTEGER    MSGLEN,ITEMP,IS,IA,NMM,LENEXT
      INTEGER    SAVE_NFI,LOOPNFI,NFIMIN,NFIMAX,NSTATE
C     META DYNAMICS
      LOGICAL    LMETARES
      REAL*8     EK_CV
C     QM/MM
      LOGICAL qmmech
      REAL*8  MM_EKIN
      REAL*8  MM_TEMP
C     ==================================================================
      IF(TDDFT.AND.TRESPONSE) CALL STOPGM("MDDIAG",
     &                        "TDDFT.AND.TRESPONSE NOT POSSIBLE")
C     ==--------------------------------------------------------------==
      TIME1 = TIMEF()
      CALL MEMORY(IP_TAUP,3*NAX*NSX,'TAUP')
      CALL MEMORY(IP_FION,3*NAX*NSX,'FION')
      CALL MEMORY(IP_TAUI,3*NAX*NSX,'TAUI')
      CALL MEMORY(IP_TAUR,3*NAX*NSX,'TAUR')
      IF(TSUBROT) CALL MEMORY(IP_TAUIO,3*NAT,'TAUIO')
C     Memory for densities
      if(.not.BSYMM) then
        NNX=NNR1*NLSD
        CALL MEMORY(IP_RIN0,NNX,'RIN0')
        CALL MEMORY(IP_ROUT0,NNX,'ROUT0')
        CALL MEMORY(IP_RMIX,NNX,'RMIX')
        CALL MEMORY(IP_RM1,NNX,'RM1')
        CALL MEMORY(IP_RINP,NNX,'RINP')
        IP_RHOO=IP_RIN0
        CALL AZZERO(RIN0,NNX)
        CALL AZZERO(ROUT0,NNX)
        CALL AZZERO(RMIX,NNX)
      endif  
      IF(LCOLVARDYN) THEN
        CALL MEMORY(IP_FHILLS,3*NAX*NSX,'FHILLS')
        CALL AZZERO(FHILLS,3*NAX*NSX)
      ENDIF
c     Initialize logical variable for Metadynamics
      LMETARES=.FALSE.
      NSTATE=N
      NACC = 22
      NFI  = 0
      MODENS=.FALSE.
      ENGPRI=.FALSE.
      CALSTE=TPRES
      CALL MEMORY(IP_EIGV,NLSD*NSTATE*NKPTS*BSFAC,'EIGV')
C     ==--------------------------------------------------------------==
C     Extrapolation
      IF(TEXTRAP) THEN
        LENEXT=2*NGWK*NSTATE*NKPTS*MEXTRA
        RMEM = 16.D0*LENEXT*1.D-6
        CALL MEMORY(IP_COLD,LENEXT,'COLD')
        IF(PARENT) WRITE(6,'(A,T51,F8.3,A)') ' MDDIAG| '
     *    // 'EXTRAPOLATION WAVEFUNCTION HISTORY TAKES ',RMEM,' MBYTES'
      ENDIF
C     ==--------------------------------------------------------------==
C     SCR ALLOCATION AND PARTITION (SCRATCH ARRAY).
      CALL RHOE_PSI_SIZE(IL_RHOE,IL_PSI)
      CALL MEMORY(IP_RHOE,IL_RHOE,'RHOE')
      NMM=1
      IF(TDDFT) THEN
        CALL MEMORY(IP_RHOO,IL_RHOE,'RHOO')
        CALL MEMORY(IP_POTR,IL_RHOE,'POTR')
        IF(NS_TRI.GT.0) NMM=2
      ENDIF
      NMM=NMM*IL_PSI
      CALL MEMORY(IP_PSI,NMM,'PSI')
      CALL GIVE_SCR_MDDIAG(LSCR,TAG)
      CALL MEMORY(IP_SCR,LSCR,'SCR')
C     ==--------------------------------------------------------------==
99999 IF(TSAMPL) THEN
        CALL SAMPLE_WAIT
        IF(NOMORE.LT.0) GOTO 10000
      ENDIF
      NFNOW=1
C     ==--------------------------------------------------------------==
C     TIME STEP FUNCTIONS
      CALL DYNIT(EKINCP,EKIN1,EKIN2,TEMP1,TEMP2,EKINH1,EKINH2)
C     PARAMETERS FOR THE NOSE-HOOVER THERMOSTATS
      IF(TNOSEP.AND.PARENT) CALL NOSEPA(1,1)
C     Dont symmetrize density 
      TSYMRHO=.FALSE.
C..Make sure TKFULL=.TRUE
      IF(TKPNT.AND.(.NOT.TKFULL)) THEN 
        WRITE(6,*) 
     & ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        WRITE(6,*) 
     & ' WARNING!  USE KPOINTS FULL  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        WRITE(6,*) 
     & ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      ENDIF
C     ==--------------------------------------------------------------==
C     == INITIALISATION                                               ==
C     ==--------------------------------------------------------------==
      if(BSYMM.and.PARENT) then
        write(6,*)
        write (6,*) 'BSYMM: BS WAVEFUNCTION INITIALIZATION'
      endif
      CALL INITRUN(IREC,C0,C2,SC0,RHOE,PSI,EIGV,SCR,LSCR)
      if(BSYMM) then
        if(PARENT) write (6,*) 'BSYMM: HS WAVEFUNCTION INITIALIZATION'
        BSCLCS=2
        call SETBSSTATE
        CALL INITRUN(IREC,C0(1,1,2),C2,SC0,RHOE,PSI,EIGV(1,2),SCR,LSCR)
      endif
C
      MSGLEN = 3*NAX*NSX * 8
      CALL MY_BCAST(TAUP,MSGLEN,SOURCE,ALLGRP)
      IF(PARENT) CALL DCOPY(3*NAX*NSX,TAUP,1,TAUI,1)
C     ==--------------------------------------------------------------==
      IF(IPRINT_STEP.EQ.0) IPRINT_STEP=NOMORE+1
      IF(IPRINT(IPRINT_EIGEN).EQ.0) IPRINT(IPRINT_EIGEN) = -1
      IF(IPRINT(IPRINT_COOR) .EQ.0) IPRINT(IPRINT_COOR)  =  1
      IF(IPRINT(IPRINT_FORCE).EQ.0) IPRINT(IPRINT_FORCE) =  1
C     ==--------------------------------------------------------------==
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
        CALL RINVEL(VELP,C2,NSTATE)
        IF(PARENT) CALL TAUCL(VELP)
        IF(PARENT) CALL RATTLE(TAU0,VELP)
        CALL RVSCAL(VELP)
      ELSE
        IF(PARENT) CALL TAUCL(VELP)
        IF(PARENT) CALL RATTLE(TAU0,VELP)
        IF(TRESCALE) CALL RVSCAL(VELP)
      ENDIF
      IF(QUENCHP) CALL AZZERO(VELP,3*NAX*NSX)
      IF(TREVERS) THEN
C       invert ionic velocities (useful for path sampling)
        CALL DSCAL(3*NAX*NSX,-1.D0,VELP,1)
      ENDIF
C     COMPUTE THE IONIC TEMPERATURE TEMPP
      IF(PARENT) THEN
        CALL EKINPP(EKINP,VELP)
        TEMPP=EKINP*FACTEM*2.D0/GLIB
      ENDIF
C     RESET ACCUMULATORS
      IF(PARENT)THEN
        IF(IREC(IREC_AC).EQ.0)CALL RESETAC(TAU0,TAUI,NFI)
C   
        ITEMP=IREC(IREC_NOP1)+IREC(IREC_NOP2)+IREC(IREC_NOP3)
     *        +IREC(IREC_NOP4)
        IF(TNOSEP .AND. ITEMP.EQ.0) CALL NOSPINIT(1)
      END IF
C
      CALL WRITE_IREC(IREC)
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
      IF(TDIAG) THEN
        IF(TLANC) NX=1
        IF(TDAVI) NX=NGWK*NDAVV*NKPNT+1
        IF(DIIS)  NX=((NGWK*NSTATE+8)*MDIIS*NKPNT)/4
      ELSEIF(TSDE) THEN
          NX=1
      ELSEIF(DIIS) THEN
          NX=(NGWK*NSTATE+8)*MDIIS*NKPNT/2+4
      ELSEIF(PCG) THEN
          NX=1
      ENDIF
      IF(PARENT) THEN
        WRITE(*,'(1X,64("="))')
        WRITE(*,'(1X,"==",T25,A,T64,"==")')
     &       'FORCES INITIALIZATION'
        WRITE(*,'(1X,64("="))')
      ENDIF
      IFCALC=0
      if(bsymm) then
        CALL BS_FORCES_DIAG(NSTATE,C0,C2,CM,SC0,CM(NX),VPP,EIGV,
     &                   RHOE,PSI,SCR,LSCR,
     &                   TAU0,VELP,TAUI,FION,IFCALC,
     &                   IREC,.TRUE.,.TRUE.)
      else
        CALL FORCES_DIAG(NSTATE,C0,C2,CM,SC0,CM(NX),VPP,EIGV,
     &                   RHOE,PSI,SCR,LSCR,
     &                   TAU0,VELP,TAUI,FION,IFCALC,
     &                   IREC,.TRUE.,.TRUE.)
      endif
      IF(TDDFT) THEN
         CALL LR_TDDFT(C0,C1,C2,SC0,RHOE,PSI,TAU0,FION,EIGV,
     &                 SCR,LSCR,NSTATE,.TRUE.,IOUTPUT)
      ENDIF
C     switch on info printing for the lin resp part
      IF (TRESPONSE) INTER_PT_FIRSTCALL = .TRUE.

C     Initialize Metadynamics contributions
      IF(LCOLVARDYN .AND. LEXTLAGRANGE) THEN
        LMETARES= .FALSE.
C     Metadynamics with Extended Lagrangian
         IF(TMULTI) THEN
           CALL META_EXT_MUL(TAU0,VELP,TAUR,SCR,LSCR,
     &              .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
         ELSE
           CALL META_EXTLAGR(TAU0,VELP,TAUR,SCR,LSCR,
     &              .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
         ENDIF
      ENDIF

      if(.not.BSYMM) CALL DCOPY(NNX,RIN0(1),1,RM1(1),1)
C     INITIALIZE THERMOSTATS
      IF(PARENT) THEN
        CALL WRGEOF(TAU0,FION)
        FILEN='ENERGIES'
        CALL FILEOPEN(3,FILEN,FO_APP+FO_VERB,FERROR)
      ENDIF
      IF(PARENT) THEN
        WRITE(*,'(1X,64("="))')
        WRITE(*,'(1X,"==",T20,A,T64,"==")')
     &       'END OF FORCES INITIALIZATION'
        WRITE(*,'(1X,64("="),/)')
      ENDIF
      CALL WRITE_IREC(IREC)
C     ==--------------------------------------------------------------==
C     == END INITIALIZATION                                           ==
C     ==--------------------------------------------------------------==
      IF(TESTSTORE(0).AND.TSAMPL)
     *    CALL ZHWWF(2,IREC,C0,C2,NSTATE,EIGV,TAU0,VELP,TAUI,NFI)
      IF(PARENT) THEN
C       MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
        IF(PARENT) CALL DISPP(TAU0,TAUI,DISA)
C       ENERGY OF THE NOSE THERMOSTATS
        CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
        ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR
        TIME2 = TIMEF()
        TCPU = (TIME2 - TIME1)*0.001D0
        WRITE(6,'(A,T50,F8.2,A8)') ' TIME FOR INITIALIZATION:',
     &       TCPU,' SECONDS'
        WRITE(6,'(//,1X,64("="))')
        WRITE(6,'(1X,"=",T20,A,T65,"=")')
     &       'MOLECULAR DYNAMICS SIMULATION'
        WRITE(6,'(1X,64("="))')
C       CALL WRPRINT_MD(EIGV,F,AMU,NSTATE,TAU0,FION,
C    &                  0.D0,TEMPP,ETOT,ECONS,0.D0,DISA,
C    &                  TCPU,.FALSE.,NFI,0)
      ENDIF
C     ==================================================================
C     ==          THE BASIC LOOP FOR MOLECULAR DYNAMICS               ==
C     ==                 USING VELOCITY VERLET                        ==
C     ==================================================================
      INFI=0
      NFIMIN=NFI+1
      NFIMAX=NFI+NOMORE
      DO LOOPNFI=NFIMIN,NFIMAX
        TIME1=TIMEF()
        CALL MY_SYNC(ALLGRP)
        INFI=INFI+1
        NFI=LOOPNFI
        SUBCOM=TSUBCOM.AND.MOD(NFI-1,NCOMV).EQ.0
        SUBROT=TSUBROT.AND.MOD(NFI-1,NROTV).EQ.0
C       ANNEALING
        CALL ANNEAL(VELP,C2,NSTATE,SCR)
        CALL BERENDSEN(VELP,C2,NSTATE,SCR,0.0D0,0.0D0)
C       UPDATE NOSE THERMOSTATS
        CALL NOSEUP(VELP,C2,NSTATE,1)
C       SUBTRACT CENTER OF MASS VELOCITY
        IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.TRUE.)
C       SUBTRACT ROTATION AROUND CENTER OF MASS
        IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.TRUE.)
C       UPDATE VELOCITIES
        IF(PARENT) CALL VELUPI(VELP,FION,1)
#if defined (__QMECHCOUPL)
        if (PARENT .and. qmmech) then
          CALL mm_cpmd_velup(DELT_IONS)
        end if
#endif
C       UPDATE POSITIONS
        ECNSTR = 0.0D0
        IF(PARENT) THEN
          CALL POSUPI(TAU0,TAUP,VELP)
          IF(MCNSTR.NE.0) CALL CPMDSHAKE(TAU0,TAUP,VELP)
#if defined (__QMECHCOUPL)
          if (qmmech) then
            CALL mm_cpmd_update_links(TAUP, NA, NSP, NAX, NAT)
            CALL mm_cpmd_posup(DELT_IONS)
          end if
#endif
        ENDIF
        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(TAUP,MSGLEN,SOURCE,ALLGRP)
C       Reset swap file to update (option BLOCK and ALL)
        IF(TKBLOCK) CALL RESKPT_SWAP
        CALL PHFAC(TAUP)
        IF(TINLC) CALL COPOT(RHOE,PSI,SCR,LSCR,CALSTE)
        IF(TMOVR) THEN
          CALL DCOPY(NNX,RIN0(1),1,RHOE(1,1),1)
          CALL MOVERHO(RHOE,PSI,SCR,LSCR)
          CALL DCOPY(NNX,RHOE(1,1),1,RIN0(1),1)
        ENDIF
        IF(TTROT) THEN
          CALL CALC_ALM(SCR,LSCR)
        ENDIF
C       CALCULATE THE FORCES
        CALSTE=TPRES.AND.MOD(NFI,NPRES).EQ.0
        IF(TEXTRAP) THEN
C         Extrapolate wavefunctions
          CALL EXTRAPWF(INFI,C0,SCR,COLD,NSTATE,MEXTRA)
        ENDIF
        IF(TLANC) NX=1
        IF(TDAVI) NX=NDAVV*NKPNT+1
C RESPONSE calculation
        IF (TRESPONSE) THEN
C     save the MD step number
          save_NFI=NFI
C     localisation at first iteration + PT
          CALL mddiag_interaction_p(NSTATE,C0,C2,CM,SC0,
     $        CM(NX),VPP,EIGV,RHOE,PSI,SCR,LSCR,
     $        TAUP,VELP,TAUI,FION,IFCALC,IREC,.TRUE.,.FALSE.)
C          sets the number of iteration and recover MD step number
          IFCALC=NFI
          NFI=save_NFI

C          switch off the info printing
          INTER_PT_FIRSTCALL=.FALSE.
        ELSE
          IF(BSYMM) THEN
            CALL BS_FORCES_DIAG(NSTATE,C0,C2,CM,SC0,CM(NX),VPP,EIGV,
     &          RHOE,PSI,SCR,LSCR,
     &          TAUP,VELP,TAUI,FION,IFCALC,
     &          IREC,.TRUE.,.FALSE.)
          ELSE
            CALL FORCES_DIAG(NSTATE,C0,C2,CM,SC0,CM(NX),VPP,EIGV,
     &          RHOE,PSI,SCR,LSCR,
     &          TAUP,VELP,TAUI,FION,IFCALC,
     &          IREC,.TRUE.,.FALSE.)
          ENDIF
          IF(TDDFT) THEN
            CALL LR_TDDFT(C0,C1,C2,SC0,RHOE,PSI,TAUP,FION,EIGV,
     &          SCR,LSCR,NSTATE,.TRUE.,IOUTPUT)
          ENDIF
        ENDIF
C     ==================================================================
C       Damped Dynamics
        CALL DAMPDYN(VELP,FION,CM,C2,NSTATE,SCR(1),SCR(10))
C     ==================================================================
C       Meta Dynamics of Collective Variables

        IF(LCOLVARDYN) THEN 
          LMETARES= .FALSE.

          IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
            IF(TMULTI) THEN
              CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &            .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
            ELSE
              CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &            .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
            ENDIF 
          ELSE
C     Time dipendent potential applied directly on the Collective Variables
            CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &          .FALSE.,LMETARES,0.0D0,EKINP)
          ENDIF

          IF(PARENT) THEN 
C     Additional Contribution to FION due to the Metadynamics
C     (from coupling pot.if extended Lagrangian, directly from V(S,t) if not)
!$OMP parallel do private(IS,IA)
            DO IS = 1,NSP
              DO IA = 1,NA(IS)
                FION(1,IA,IS) = FION(1,IA,IS) + FHILLS(1,IA,IS)
                FION(2,IA,IS) = FION(2,IA,IS) + FHILLS(2,IA,IS)
                FION(3,IA,IS) = FION(3,IA,IS) + FHILLS(3,IA,IS)
              ENDDO
            ENDDO
          ENDIF
        ENDIF
C     ==================================================================

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
        IF(PARENT) THEN
          CALL VELUPI(VELP,FION,1)
#if defined (__QMECHCOUPL)
          if (qmmech) then
            CALL mm_cpmd_velup(DELT_IONS)
          end if
#endif
          CALL RATTLE(TAUP,VELP)
        ENDIF
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
#if defined (__QMECHCOUPL)
C       ---------------------------------------------------------------
C       MM Temperature control - annealing schedule not yet implemented
C       ---------------------------------------------------------------
        IF (PARENT .and. qmmech) THEN
          call mm_cpmd_temp_control(TEMP1,TEMP2,MM_TEMP,TCP)
          call mm_cpmd_ekin(MM_EKIN,MM_TEMP)
        END IF
#endif
C       IONIC TEMPERATURE CONTROL
        IF(PARENT) CALL RSCVP(TEMP1,TEMP2,TEMPP,VELP)
C       SUBTRACT ROTATION AROUND CENTER OF MASS
        IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.FALSE.)
C       SUBTRACT CENTER OF MASS VELOCITY
        IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.FALSE.)
C       UPDATE NOSE THERMOSTATS
        CALL NOSEUP(VELP,C2,NSTATE,1)
        CALL BERENDSEN(VELP,C2,NSTATE,SCR,0.0D0,0.0D0)
C       ANNEALING
        CALL ANNEAL(VELP,C2,NSTATE,SCR)
        IF(PARENT) THEN
          CALL EKINPP(EKINP,VELP)
          IF(LEXTLAGRANGE.AND. LTCGLOBAL) THEN
            CALL EKINCV_GLOBAL(EK_CV)
            TEMPP=(EK_CV+EKINP)*FACTEM*2.D0/(GLIB+DBLE(NCOLVAR))
          ELSE 
            TEMPP=EKINP*FACTEM*2.D0/GLIB
          ENDIF 
        ENDIF
C       MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
        IF(PARENT) CALL DISPP(TAUP,TAUI,DISA)
C       ENERGY OF THE NOSE THERMOSTATS
        IF(PARENT) CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
C       CALCULATE PROPERTIES DURING SIMULATION.
        CALDIP=TDIPD.AND.MOD(NFI-1,NPDIP).EQ.0
        if(.not.BSYMM)
     &    CALL PROPCAL(C0,C2,CM,SC0,TAUP,EIGV,F,AMU,
     &                RHOE,PSI,SCR,LSCR,NSTATE,NKPNT,NFI,INFI)
C       PRINTOUT the evolution of the accumulators every time step
        IF(PARENT) THEN
          ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR+EKINCV+VHARM
#if defined (__QMECHCOUPL)
          if (qmmech) then
            ECONS=ECONS + MM_EKIN
            write (6,'(50x, "TEMP: ",f10.0)') MM_TEMP
          end if
#endif
          TIME2=TIMEF()
          TCPU=(TIME2-TIME1)*0.001D0
          CALL WRPRINT_MD(EIGV,F,AMU,NSTATE,TAUP,FION,
     &                    0.D0,TEMPP,ETOT,ECONS,0.D0,DISA,
     &                    TCPU,.FALSE.,NFI,INFI)
C         UPDATE ACCUMULATORS
          CALL PACCC(TEMPP,ETOT,ECONS,ENOSE,ENOSP,ECNSTR,ERESTR,
     *               EBOGO,DISA,TCPU,NFI,1)
C         STORE IONIC COORDINATES AND VELOCITIES FOR STATISTICS
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
          TIME2=TIMEF()
          TCPU=(TIME2-TIME1)*0.001D0
        ENDIF
        IF(.NOT.EXSOFT) CALL TESTEX(EXSOFT)
        IF(NFI.EQ.NFIMAX) THEN
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
          CALL ZHWWF(2,IREC,C0,C2,NSTATE,EIGV,TAUP,VELP,TAUI,NFI)
        ENDIF

        IF(EXSOFT .AND.LCOLVARDYN) THEN
          LMETARES= .TRUE.
          IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
            IF(TMULTI) THEN
              CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &            .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
            ELSE
              CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &            .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
            ENDIF 
          ELSE
C     Time dependent potential applied directly on the Collective Variables
            CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &          .FALSE.,LMETARES,0.0D0,EKINP)
          ENDIF
        ENDIF
#if defined (__QMECHCOUPL)
C       -----------------------
C       Write QMMM restart file
C       -----------------------
        if (PARENT.and.qmmech) then
          if(MOD(NFI,ISTORE).EQ.0.OR.NFI.EQ.NFIMAX.OR.EXSOFT) THEN
            call mm_cpmd_write_restart
          end if
        end if
#endif
C     temperature ramping
        CALL TEMPRAMP(TEMP1,TEMP2)
C       UPDATE IONIC POSITIONS
        CALL DCOPY(3*NAX*NSX,TAUP(1,1,1),1,TAU0(1,1,1),1)
C       UPDATE DENSITY
        IF(.NOT.BSYMM) THEN
          CALL EXTRAP(NNX,ALXMIX,RM1,RIN0,RINP)
          CALL DCOPY(NNX,RIN0(1),1,RM1(1),1)
          CALL DCOPY(NNX,RINP(1),1,RIN0(1),1)
        ENDIF
C       STOP THE RUN IF THE USER HAS SET THE SIGNAL 30
        IF(EXSOFT) GOTO 100
C     ==================================================================
C     ==     END OF MAIN LOOP                                         ==
C     ==================================================================
      ENDDO
      IF(PARENT) THEN
        WRITE(*,'(1X,64("="))')
        WRITE(*,'(1X,"=",T17,A,T65,"=")')
     &       'END OF MOLECULAR DYNAMICS SIMULATION'
        WRITE(*,'(1X,64("="),/,/)')
      ENDIF
C     ==--------------------------------------------------------------==
  100 CONTINUE
      IF(RHOOUT.AND.(NRHOOUT.LE.0)) THEN
         CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
         IF(BSYMM) THEN
           BSCLCS=2
           CALL RHOPRI(C0(1,1,2),TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
           BSCLCS=1
         ENDIF
      ENDIF
C     Print accumulators.
      IF(PARENT) CALL PACCC(TEMPP,ETOT,ECONS,ENOSE,ENOSP,ECNSTR,ERESTR,
     *                      EBOGO,DISA,TCPU,NFI,0)
      IF(PARENT) CALL GSIZE(FION,GNMAX,GNORM)
      IF(PARENT) THEN
        IF(.NOT.BSYMM) THEN
          CALL FINALP(TAU0,FION,VELP,EIGV)
        ELSE
          CALL WRGEOF(TAU0,FION)
          WRITE(*,'(A)') ' NUCLEAR GRADIENT: '
          WRITE(*,'(2(A,1PE15.5))') '    MAX. COMPONENT =',
     &          GNMAX,'         NORM =',GNORM
        ENDIF
      ENDIF
      IF(TSAMPL) THEN
        CALL SAMPLE_GO
        GOTO 99999
      ENDIF
10000 CONTINUE
C     ==--------------------------------------------------------------==
      CALL FREEM(IP_EIGV)
      IF(PARENT) CALL FILECLOSE(3)
      CALL FREEM(IP_RHOE)
      CALL FREEM(IP_PSI)
      CALL FREEM(IP_SCR)
      IF(TEXTRAP) CALL FREEM(IP_COLD)
      IF(TSUBROT) CALL FREEM(IP_TAUIO)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_MDDIAG(LMDDIAG,TAG)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !pslo.inc
      INCLUDE 'elct.inc'        !N number of states
      INCLUDE 'nlcc.inc'        !TINLC
      INCLUDE 'store.inc'       !RHOOUT
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'        !TTROT
      INCLUDE 'pslo.inc'        !TIVAN
      INCLUDE 'atwf.inc'        !TMOVR
C     Arguments
      INTEGER   LMDDIAG
      CHARACTER TAG*30
C     Variables
      INTEGER   NSTATE,LRINITWF,LRNLSM,LRHOOFR,LCOPOT,LTDDFT,LINITRUN,
     &          LFORCES_DIAG,LCALC_ALM,LRHOPRI,LPROPCAL,LMOVERHO,LMTD
C     ==--------------------------------------------------------------==
      NSTATE=N
      LRNLSM=0
      LCALC_ALM=0
      LCOPOT=0
      LRHOPRI=0
      LMOVERHO=0
      LTDDFT=0
      LINITRUN=0
      CALL GIVE_SCR_INITRUN(LINITRUN,TAG)
      CALL GIVE_SCR_RINITWF(LRINITWF,TAG,NSTATE)
      IF(TIVAN) CALL GIVE_SCR_RNLSM(LRNLSM,TAG,NSTATE,.FALSE.)
      CALL GIVE_SCR_RHOOFR(LRHOOFR,TAG)
      IF(TTROT) CALL GIVE_SCR_CALC_ALM(LCALC_ALM,TAG)
      CALL GIVE_SCR_FORCES_DIAG(LFORCES_DIAG,TAG,NSTATE,.TRUE.)
      IF(TINLC) CALL GIVE_SCR_COPOT(LCOPOT,TAG)
      IF(RHOOUT) CALL GIVE_SCR_RHOPRI(LRHOPRI,TAG,NSTATE)
      CALL GIVE_SCR_PROPCAL(LPROPCAL,TAG,NSTATE)
      IF(TMOVR) CALL GIVE_SCR_MOVERHO(LMOVERHO,TAG)
      IF(TDDFT) CALL GIVE_SCR_LR_TDDFT(LTDDFT,.TRUE.,TAG)
      CALL GIVE_SCR_META_EXTLAGR(LMTD,TAG)
      LMDDIAG=MAX(LRINITWF,LRNLSM,LRHOOFR,LFORCES_DIAG,LTDDFT,LINITRUN,
     &            LCOPOT,LCALC_ALM,LRHOPRI,LPROPCAL,LMOVERHO,LMTD)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE EXTRAPWF(INFI,C0,GAM,CHIST,NSTATE,M)
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'kpts.inc'
      INCLUDE 'kpnt.inc'
      INCLUDE 'spin.inc'
      INCLUDE 'elct.inc'
      INCLUDE 'pslo.inc' ! for TIVAN
      INCLUDE 'mm_extrap.inc'
C     Arguments
      INTEGER    NSTATE,M,INFI
      COMPLEX*16 C0(NGWK,NSTATE,*),CHIST(*)
      REAL*8     GAM(NSTATE,*)
C     Variables
      DIMENSION  F(*),WK(*)
      INTEGER MA,I,N1,NM,ISUB,IK
      REAL*8  FA,RSUM,SCALEF,D_BINOM,DOTP,DDOT
      EXTERNAL D_BINOM,DOTP,DDOT

C     ==--------------------------------------------------------------==
      IF(TIVAN) CALL STOPGM('EXTRAPWF','EXTRAPOLATION NOT (YET) ' //
     &    'SUPPORTED FOR VANDERBILT PSEUDOPOTENTIALS')
      CALL TISET('  EXTRAPWF',ISUB)
      NNOW=NNOW+1
      NNOW=MOD(NNOW-1,M)+1
      CALL DCOPY(2*NGWK*NSTATE*NKPNT,C0,1,COLD(1,1,1,NNOW),1)
      NUMCOLD=MIN(NUMCOLD+1,M)
      MA=NUMCOLD
      IF(MA.GT.1) THEN
        CALL ZAZZERO(C0,NGWK*NSTATE*NKPNT)
        N1=NNOW
        FA=-1.0d0
        DO I=1,MA
          NM=NNOW-I+1
          IF(NM.LE.0) NM=NM+M
C construct extrapolation polynomial coefficient.
          IF(TASPC) THEN
            FA=(-1.d0)**(I+1)*DBLE(I)*D_BINOM(2*MA,MA-I)
     &          /D_BINOM(2*MA-2,MA-1)
          ELSE
            FA=-1.d0*FA*DBLE(MA-I+1)/DBLE(I)
          ENDIF
          IF(TKPNT) THEN
            DO IK=1,NKPNT
              CALL OVLAP_C(NSTATE,GAM,COLD(1,1,IK,NM),COLD(1,1,IK,N1))
              CALL GLOSUM(2*NSTATE*NSTATE,GAM)
              CALL ROTATE_C(DCMPLX(FA,0.D0),COLD(1,1,IK,NM),
     &            DCMPLX(1.D0,0.D0),C0(1,1,IK),GAM,NSTATE)
            END DO
          ELSE
            CALL OVLAP(NSTATE,GAM,COLD(1,1,1,NM),COLD(1,1,1,N1))
            CALL GLOSUM(NSTATE*NSTATE,GAM)
            CALL ROTATE(FA,COLD(1,1,1,NM),1.D0,C0,GAM,NSTATE,2*NGWK,
     &          TLSD,NSUP,NSDOWN)
          ENDIF
        ENDDO
C..COUNT NUMBER OF ELECTRONS IN EXTRAPOLATED WFN AND RENORMALIZE
        RSUM=0.D0
        IF(TKPNT) THEN
          DO IK=1,NKPNT
            DO I=1,NSTATE
              IF(F(I+NSTATE*(IK-1)).NE.0.D0) THEN
                RSUM=RSUM+F(I+NSTATE*(IK-1))*WK(IK)
     &              *DDOT(NGWK*2,C0(1,I,IK),1,C0(1,I,IK),1)
              ENDIF
            ENDDO
          ENDDO
        ELSE
          DO I=1,NSTATE
            IF(F(I).NE.0.D0) THEN
              RSUM=RSUM+F(I)*DOTP(NGW,C0(1,I,1),C0(1,I,1))
            ENDIF
          ENDDO
        ENDIF
        CALL GLOSUM(1,RSUM)
        SCALEF=NEL/RSUM
        CALL DSCAL(2*NGWK*NSTATE*NKPNT,SCALEF,C0,1)
      ENDIF
      CALL TIHALT('  EXTRAPWF',ISUB)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
