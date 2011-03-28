C     ==================================================================
      SUBROUTINE MM_MDMAIN(C0,CM,C2,SC0,GAMX,GAMY)
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
      INCLUDE 'rmas.inc'
      INCLUDE 'cnst_dyn.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'comvel.inc'
      INCLUDE 'fileopen.inc'
      INCLUDE 'bsym.inc'
c     Qmmm
      real*8 EXTF(*)
      include 'efld.inc'
      include 'mm_dim.inc'
      include 'mm_input.inc'
c     Qmmm locals
      real*8 VCM(3),PMA00
      integer im,is,ia,ix
      INTEGER  IN,OUT

C     Arguments
      COMPLEX*16 C0(NGW,N,*),CM(NGW,N,*),C2(NGW,N,*),SC0(NGW,N,*)
      REAL*8     GAMX(N*N,*),GAMY(N*N,*)
C     Variables
      DIMENSION  F(*)
      CHARACTER  FILEN*100,FILEBS*100
      LOGICAL    FERROR,TESTSTORE
      REAL*8     TAUI(3,NAX,*),TAUR(3,NAX,*),EIGV(N,*),EIGM(N*N,*)
      POINTER    (IP_TAUI,TAUI), (IP_TAUR,TAUR),
     *           (IP_EIGV,EIGV),(IP_EIGM,EIGM)
      COMPLEX*16 PSI(NNR1,*)
      REAL*8     RHOE(NNR1,*),SCR(*),TAUIO(3,*)
      POINTER    (IP_PSI,PSI),(IP_RHOE,RHOE),(IP_SCR,SCR),
     &    (IP_TAUIO,TAUIO)
      CHARACTER  TAG*30
      REAL*8     TIME1,TIME2,TIMEF,TEMP1,TEMP2,TCPU,TEMPP,
     &    EKIN1,EKIN2,EKINC,EKINP,EKINCP,DISA,ENOSE,ENOSP,ECONS,
     &    EHAM,EKINH1,EKINH2,TIMES1,TIMES2,VCMIO(4),LMIO(3),
     &    ETOTBS,ETOTHS,SPD_BS,SPD_HS,SPDA_BS,SPDA_HS,DUMMY,FF,
     &    ENOSBS,ENOSHS,DUM1,DUM2,SCALHS,SCALBS,COUPLJ,JWN
      EXTERNAL TIMEF
      INTEGER    IREC(100),I,NSTATE,
     &           IL_RHOE,IL_PSI,LSCR
      INTEGER    MSGLEN, ITEMP
C     META DYNAMICS
      LOGICAL    LQUENCH,LMETARES,RESETCV
      REAL*8     EK_CV
      INTEGER    K,J
      logical    oldstatus,statusdummy
      real*8     SK1
      character*10 prch
C     ==================================================================
#if defined (__GROMOS)
      TIME1 = TIMEF()
      if (qmnode) then 
        if(TEXTFLD)then
          CALL MEMORY(IP_EXTF,KR1*KR2S*KR3S,'EXTF')
          CALL AZZERO(EXTF,KR1*KR2S*KR3S)
        endif
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
              CALL STOPGM('MM_MDMAIN','FATAL ERROR')
            ENDIF
          ENDDO
        ENDIF
C     ==--------------------------------------------------------------==
C       SCR ALLOCATION AND PARTITION (SCRATCH ARRAY).
        CALL RHOE_PSI_SIZE(IL_RHOE,IL_PSI)
        CALL MEMORY(IP_RHOE,IL_RHOE,'RHOE')
        CALL MEMORY(IP_PSI,IL_PSI,'PSI')
        CALL GIVE_SCR_MM_MDMAIN(LSCR,TAG)
        CALL MEMORY(IP_SCR,LSCR,'SCR')
      endif ! qmnode
C     ==--------------------------------------------------------------==
99999 IF(TSAMPL) THEN
        CALL SAMPLE_WAIT
        IF(NOMORE.LT.0) GOTO 10000
      ENDIF
      NFNOW=1
C     ==--------------------------------------------------------------==
C     == INITIALIZATION                                               ==
C     ==--------------------------------------------------------------==

C     we may be able to save some memory by allocating more carefully
C     on every node a different size. Could be a bad idea.

      call mm_dim(mm_go_mm,oldstatus)
      CALL MEMORY(IP_FION,3*NAX*NSX,'FION')
      CALL MEMORY(IP_TAUI,3*NAX*NSX,'TAUI')
      CALL MEMORY(IP_TAUR,3*NAX*NSX,'TAUR')
      CALL MEMORY(IP_TAUP,3*NAX*NSX,'TAUP')
      CALL MEMORY(IP_TAUIO,3*NAT,'TAUIO')
      IF(LCOLVARDYN) THEN
        CALL MEMORY(IP_FHILLS,3*NAX*NSX,'FHILLS')
        CALL AZZERO(FHILLS,3*NAX*NSX)
      ENDIF
c     Initialize logical variable for Metadynamics
      LMETARES=.FALSE.

      call azzero(FION,3*NAX*NSX)
      call azzero(TAUI,3*NAX*NSX)
      call azzero(TAUP,3*NAX*NSX)

C     show sizes of the individual MPI-threads.
C     use barriers so that the output is not garbled.
      call my_sync(QMMMGRP)
      if(qmmm_verbose) then 
        do k=0,nproc
          if(mmparent) then
            write(prch,'(a10)') ' MMPARENT '
          else
            write(prch,'(a5,i5)')' QM-N',me
          endif
          if(k.eq.me) call prmem(prch)
          call my_sync(QMMMGRP)
        end do
      endif

C     format for for BS messages
 333  FORMAT (/,T2,A,/)
      if (qmnode ) then 
!     if (qmnode .and. .not.classical) then 
        IF(BSYMM)THEN
          BSCLCS=1
          IF(PARENT)WRITE(6,333) 'BROKEN SYMMETRY STATE IS INITIALIZING'
        END IF
        CALL INITRUN(IREC,C0,CM,SC0,RHOE,PSI,EIGV,SCR,LSCR)
        IF(BSYMM)THEN
          BSCLCS=2
          IF(PARENT)WRITE(6,333) 'HIGH SPIN STATE IS INITIALIZING'
          CALL SETBSSTATE
          CALL INITRUN(IREC,C0(1,1,2),CM(1,1,2),SC0(1,1,2),RHOE,
     &         PSI,EIGV(1,2),SCR,LSCR)
          IF(PARENT)WRITE(6,333) 'BROKEN SYMMETRY INIT SUCCESSFUL'
        END IF
      endif
      if (qmnode ) then 
C     ==--------------------------------------------------------------==
C     TIME STEP FUNCTIONS
        CALL DYNIT(EKINCP,EKIN1,EKIN2,TEMP1,TEMP2,EKINH1,EKINH2)
C     PARAMETERS FOR THE NOSE-HOOVER THERMOSTATS
        IF((TNOSEE.OR.TNOSEP).AND.PARENT) CALL NOSEPA(1,1)

C     Dont symmetrize density 
        TSYMRHO=.FALSE.
        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(TAUP,MSGLEN,SOURCE,ALLGRP)
   
        IREC(IREC_WF)=1

        CALL DCOPY(3*NAX*NSX,TAUP,1,TAUI,1) ! cmb-bugfix
      endif
      IF(QUENCHB) THEN
        call mm_dim(mm_go_mm,statusdummy)
        CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
        IF(.not.qmmm_reflex) THEN
          CALL mm_translate_qmmm(TAU0,C0,CM,NSTATE)  
          IF(BSYMM) THEN
            CALL mm_translate_qmmm(TAU0,C0(1,1,2),CM(1,1,2),NSTATE)
          ENDIF
        ENDIF
        call mm_dim(mm_go_qm,statusdummy)

        IF(BSYMM)THEN
          BSCLCS=1
          CALL SETBSSTATE
          IF(PARENT) WRITE(6,333) 'QUENCHING BROKEN SYMMETRY STATE'
        END IF
        CALL QUENBO(C0,C2,SC0,TAUR,RHOE,PSI,SCR,LSCR)
        IF(BSYMM)THEN
          BSCLCS=2
          CALL SETBSSTATE
          IF(PARENT) WRITE(6,333) 'QUENCHING HIGH SPIN STATE'
          CALL QUENBO(C0(1,1,2),C2(1,1,2),SC0(1,1,2),TAUR,
     &               RHOE,PSI,SCR,LSCR)
        END IF
        call mm_dim(mm_go_mm,statusdummy)

        if (qmnode ) then 
          CALL DCOPY(3*NAX*NSX,TAUP,1,TAUI,1)
        endif
#if 0
C     FIXME: AK 2005/06/17. the restart from QUENCH BO is broken.
        if(qmnode)
     c    CALL ZHWWF(2,IREC,C0,CM,NSTATE,EIGV,TAU0,VELP,TAUI,NFI)
#endif
        QUENCHB=.FALSE.
      ENDIF
      if(qmnode)then
        IF(TIVAN) THEN
          call mm_dim(mm_go_qm,statusdummy)
          IF(TLSD) THEN
            BSCLCS=1
            IF(BSYMM)CALL SETBSSTATE
            CALL DEORT(NGW,NSUP,EIGM,EIGV,C0(1,1,1),SC0(1,1,1),SCR,LSCR)
            CALL DEORT(NGW,NSDOWN,EIGM,EIGV,C0(1,NSUP+1,1),
     *                 SC0(1,NSUP+1,1),SCR,LSCR)
            IF(BSYMM)THEN
              BSCLCS=2
              CALL SETBSSTATE
              CALL DEORT(NGW,NSUP,EIGM(1,2),EIGV(1,2),C0(1,1,2),
     &                   SC0(1,1,2),SCR,LSCR)
              CALL DEORT(NGW,NSDOWN,EIGM(1,2),EIGV(1,2),C0(1,NSUP+1,2),
     *                  SC0(1,NSUP+1,2),SCR,LSCR)
            ENDIF
          ELSE
            CALL DEORT(NGW,NSTATE,EIGM,EIGV,C0,SC0,SCR,LSCR)
          ENDIF
        ENDIF
C      INITIALIZE VELOCITIES
        call mm_dim(mm_go_mm,statusdummy)
        IF(PARENT) CALL DETDOF(TAU0,SCR)

C     INITIALIZE METADYNAMICS VARIABLES used also for 
C     SHOOTING from SADDLE POINT with RANDOM VELOCITIES
        IF(PARENT .AND. (LCOLVARDYN .OR. LSADPNT)) THEN
          CALL COLVAR_STRUCTURE(TAU0,TAUR)
        ENDIF

        IF((IREC(IREC_VEL).EQ.0).and.
     &      (.not.rgeo).and.(.not.restart_traj)) THEN
          ECNSTR = 0.0D0
          ERESTR = 0.0D0
          CALL RINVEL(VELP,CM,N)
          IF(BSYMM) CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
          IF(PARENT) then
            CALL TAUCL(VELP)
            call mm_solv_const('RATTL',dt_ions,tau0,velp,tau0)
            CALL RATTLE(TAU0,VELP)
          ENDIF
C         RESCALE VELOCITIES ONLY IF NOT READ FROM GROMOS.G96 FILE
          IF ( NTX_vel.ne.1 ) CALL RVSCAL(VELP)
        ELSE
        IF(PARENT) then
             CALL TAUCL(VELP)
             call mm_solv_const('RATTL',dt_ions,tau0,velp,tau0)
             CALL RATTLE(TAU0,VELP)
         ENDIF
         IF(TRESCALE) CALL RVSCAL(VELP)
        ENDIF
        IF(QUENCHP) CALL AZZERO(VELP,3*NAX*NSX)
        IF(QUENCHE) CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
        IF(classical) CALL AZZERO(CM,2*NGW*NSTATE*BSFAC)
        IF(TREVERS) THEN
C     invert electronic and ionic velocities (useful for path sampling)
          CALL DSCAL(2*NGW*NSTATE*BSFAC,-1.D0,CM,1)
          CALL DSCAL(3*NAX*NSX,-1.D0,VELP,1)
        ENDIF

C      RESET ACCUMULATORS
        IF(PARENT.AND.IREC(IREC_AC).EQ.0)
     &      CALL RESETAC(TAU0,TAUI,NFI)
C      INITIALIZE FORCES
        IF(PARENT) THEN
          WRITE(*,'(1X,64("="))')
          WRITE(*,'(1X,"==",T25,A,T64,"==")') 'FORCES INITIALIZATION'
          WRITE(*,'(1X,64("="))')
        ENDIF
        call mm_dim(mm_go_qm,statusdummy)
        IF(TKPNT) THEN
          IF(GEQ0) CALL ZCLEAN_K(C0,NSTATE,NGW)
        ELSE
          IF(GEQ0) CALL ZCLEAN(C0,NSTATE,NGW)
        ENDIF

C       Initialize Metadynamics contributions
        IF(LCOLVARDYN .AND. LEXTLAGRANGE) THEN
          call mm_dim(mm_go_mm,statusdummy)
          LQUENCH = .FALSE.
          LMETARES= .FALSE.
          RESETCV = .FALSE.
          EKINC=0.D0 
          DISA=0.D0 
          IF(TMULTI) THEN
            CALL META_EXT_MUL(TAU0,VELP,TAUR,SCR,LSCR,
     &               LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
          ELSE

            CALL META_EXTLAGR(TAU0,VELP,TAUR,SCR,LSCR,
     &               LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
          ENDIF
          call mm_dim(mm_revert,statusdummy)
      ENDIF

      endif ! qmnode

      CALL mm_dim(mm_go_mm,statusdummy)
      if ( parent ) then
         call mm_write_gromos_coord('CRD_INI.g96',TAU0,VELP,NAX,NSX)
      endif

      CALL MY_SYNC(QMMMGRP)
      IF(BSYMM)THEN
        CALL mm_qmmm_forcedr_bs(C0,C2,SC0,RHOE,PSI,TAU0,FION,
     *             EIGV,SCR,LSCR,NSTATE,IL_RHOE,.false.,.true.,
     *             SPD_BS,SPD_HS,SPDA_BS,SPDA_HS,ETOTHS,ETOTBS,.false.)
      ELSE
        CALL mm_qmmm_forcedr(C0,C2,SC0,RHOE,PSI,TAU0,FION,
     *             EIGV,SCR,LSCR,NSTATE,IL_RHOE,.false.,.true.,.false.)
      ENDIF

      if (qmnode) then 

C      Check orthogonality condition for wavefunction velocities
       call mm_dim(mm_go_qm,statusdummy)
       CALL FREQS(N,.TRUE.)
       IF(BSYMM)THEN
         BSCLCS=1
         CALL SETBSSTATE
       END IF

       IF (.NOT.classical) THEN
         CALL RORTV(C0,CM,C2,SC0,GAMY,NSTATE,SCR,LSCR)
         IF(BSYMM)THEN
           BSCLCS=2
           CALL SETBSSTATE
           CALL RORTV(C0(1,1,2),CM(1,1,2),C2(1,1,2),SC0(1,1,2),
     &         GAMY(1,2),NSTATE,SCR,LSCR)
         END IF
       ENDIF

       call mm_dim(mm_go_mm,statusdummy)
C      Initialize thermostats
       IF(PARENT) THEN
         ITEMP=IREC(IREC_NOP1)+IREC(IREC_NOP2)+IREC(IREC_NOP3)
     *        +IREC(IREC_NOP4)
         IF(TNOSEP .AND. ITEMP.EQ.0) CALL NOSPINIT(1)
         IF(TNOSEE .AND. IREC(IREC_NOE) .EQ.0) THEN
             CALL NOSEINIT(1)
             IF(BSYMM)CALL NOSEINIT(2)
         END IF
         if( NATm.le.500) CALL WRGEO(TAU0)
         FILEN='ENERGIES'
         CALL FILEOPEN(3,FILEN,FO_APP+FO_VERB,FERROR)
C        OPEN OUTPUT DATA FILE FOR BROKEN SYMMETRY
         IF(BSYMM) THEN
           FILEBS='BS_ENERG'
           WRITE(6,'(/,2A)')
     &          '  BROKEN SYMMETRY DATA WILL BE WRITTEN IN ',FILEN
           WRITE(6,'(/,A,/)')
     &          '  DATA IN BS_ENERG:'
           WRITE(6,'(2A,/)')
     &          '  Step #, EKINC_BS, EKINC_HS, ETOT_LS, ETOT_BS,',
     &          ' ETOT_HS, Spin-density-BS, ..-HS, '
           WRITE(6,'(2A,/)')
     &          '  Absolute-spin-density-BS, ..-HS,',
     &          ' Coupling constant J in a.u., J in cm-1 '
C          
           CALL FILEOPEN(277,FILEBS,FO_APP+FO_VERB,FERROR)
         ENDIF
       ENDIF
       IF(PARENT) THEN
         WRITE(*,'(1X,64("="))')
         WRITE(*,'(1X,"==",T20,A,T64,"==")')
     .                                    'END OF FORCES INITIALIZATION'
         WRITE(*,'(1X,64("="),/)')
       ENDIF
       CALL WRITE_IREC(IREC)
C     ==--------------------------------------------------------------==
C     == END INITIALIZATION                                           ==
C     ==--------------------------------------------------------------==
       IF(TESTSTORE(0).AND.TSAMPL)
     *     CALL ZHWWF(2,IREC,C0,CM,NSTATE,EIGV,TAUP,VELP,TAUI,NFI)
       IF(PARENT) THEN
         TIME2 = TIMEF()
         TCPU = (TIME2 - TIME1)*0.001D0
         WRITE(*,'(A,T50,F8.2,A8)') ' TIME FOR INITIALIZATION:',
     *                         TCPU,' SECONDS'
       ENDIF
      endif ! qmnode
C     ==================================================================
C     ==          THE BASIC LOOP FOR MOLECULAR DYNAMICS               ==
C     ==                 USING VELOCITY VERLET                        ==
C     ==================================================================
      DO INFI=1,NOMORE
        call mm_dim(mm_go_mm,statusdummy)
        CALL MY_SYNC(QMMMGRP)
        if (qmnode) then
         TIME1=TIMEF()
         NFI=NFI+1
         SUBCOM=TSUBCOM.AND.MOD(NFI-1,NCOMV).EQ.0
         SUBROT=TSUBROT.AND.MOD(NFI-1,NROTV).EQ.0
         PRTEIG=TPRINT.AND.MOD(NFI-1,IPRINT_STEP).EQ.0
         CALDIP=TDIPD.AND.MOD(NFI-1,NPDIP).EQ.0
         IF(.NOT.PARENT) PRTEIG=.FALSE.
         ENGPRI=TPRINT.AND.MOD(NFI-1,IPRINT_STEP).EQ.0
C        ANNEALING
         BSCLCS=1
         CALL ANNEAL(VELP,CM(1,1,1),NSTATE,SCR)
         CALL BERENDSEN(VELP,CM(1,1,1),NSTATE,SCR,EKINC,0.0D0)
         IF(BSYMM)THEN
           BSCLCS=2
           CALL ANNEAL(VELP,CM(1,1,2),NSTATE,SCR)
           CALL BERENDSEN(VELP,CM(1,1,2),NSTATE,SCR,EKINC,0.0D0)
         END IF
C     SUBTRACT CENTER OF MASS VELOCITY
         IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.TRUE.)
C     SUBTRACT ROTATION AROUND CENTER OF MASS
         IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.TRUE.)
C        UPDATE NOSE THERMOSTATS
         CALL NOSEUP(VELP,CM,NSTATE,1)
         IF(BSYMM)THEN
           BSCLCS=2
           CALL NOSEUP(VELP,CM(1,1,2),NSTATE,2)
         END IF
C        UPDATE VELOCITIES
         IF(PARENT) CALL VELUPI(VELP,FION,1)
         IF (.NOT.classical) THEN
           CALL VELUPA(C0,CM,C2,NSTATE,1)
           IF(BSYMM)CALL VELUPA(C0(1,1,2),CM(1,1,2),C2(1,1,2),NSTATE,1)
         ENDIF
C        UPDATE POSITIONS
         ECNSTR = 0.0D0
         ERESTR = 0.0D0
         IF(PARENT) THEN
           CALL POSUPI(TAU0,TAUP,VELP)
           call mm_solv_const('SHAKE',dt_ions,taup,velp,tau0)
           IF(MCNSTR.NE.0) THEN
             CALL CPMDSHAKE(TAU0,TAUP,VELP)
           ENDIF
         ENDIF
        endif !qmnode

        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(TAUP,MSGLEN,QMMMSOURCE,QMMMGRP)
        IF(.not.qmmm_reflex) THEN
          CALL mm_translate_qmmm(TAUP,C0,CM,NSTATE)  
          IF(BSYMM) THEN
            CALL mm_translate_qmmm (TAUP,C0(1,1,2),CM(1,1,2),NSTATE)
          ENDIF
        ENDIF
        if(qmnode) then 
          call mm_dim(mm_go_qm,statusdummy)
          CALL PHFAC(TAUP)
          IF(TINLC) CALL COPOT(RHOE,PSI,SCR,LSCR,CALSTE)
          if(.not.classical)then
            CALL POSUPA(C0,CM,C2,GAMX,NSTATE,SCR,LSCR)
          endif
C..Dipole moment
          IF(CALDIP.AND.(.NOT.BSYMM)) THEN
            CALL DDIPO(TAUP,C0,CM,C2,SC0,SCR,LSCR,NSTATE)
            CALL WANNIER_PRINT(NFI,C0,TAUP,NSTATE,PSI,SCR,LSCR)
          ENDIF
          CALSTE=TPRES.AND.MOD(NFI-1,NPRES).EQ.0
          call mm_dim(mm_go_mm,statusdummy)
        endif  ! qmnode

        IF(BSYMM)THEN
           call mm_qmmm_forcedr_bs(C0,C2,SC0,RHOE,PSI,TAUP,FION, 
     *             EIGV,SCR,LSCR,NSTATE,IL_RHOE,.false.,.true.,
     *             SPD_BS,SPD_HS,SPDA_BS,SPDA_HS,ETOTHS,ETOTBS,.true.)
        ELSE
          call mm_qmmm_forcedr(C0,C2,SC0,RHOE,PSI,TAUP,FION,
     *             EIGV,SCR,LSCR,NSTATE,IL_RHOE,.false.,.true.,.true.)
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

        if(qmnode)then
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
     &                 LQUENCH,LMETARES,RESETCV,EKINC,EKINP)
              ENDIF
            ELSE
C     Time dependent potential applied directly on the Collective Variables
              CALL META_COLVAR(TAUP,VELP,FION,TAUR, SCR,LSCR,
     &                 LQUENCH,LMETARES,EKINC,EKINP)
            ENDIF
            IF((TOLKIN.GT.0.0D0 .AND. EKINC.GT.TOLKIN)
     &                 .OR. LQUENCH) THEN
C     Check for Quench on the BO surface
              IF(PARENT) THEN
               WRITE(*,'(''TOLKIN ='',f16.8,''  EKINC ='',f16.8)')
     .              TOLKIN,EKINC
              ENDIF
              CALL mm_dim(mm_go_qm,statusdummy)
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
              CALL mm_dim(mm_go_mm,statusdummy)
              CALL AZZERO(CM,2*NSTATE*NGWK*BSFAC)
              RESETCV = .TRUE.
              QUENCHB=.FALSE.
            ENDIF
            if(parent)then
!$OMP parallel do private(IS,IA)
              DO IS = 1,NSP
                DO IA = 1,NA(IS)
                  FION(1,IA,IS) = FION(1,IA,IS) + FHILLS(1,IA,IS)
                  FION(2,IA,IS) = FION(2,IA,IS) + FHILLS(2,IA,IS)
                  FION(3,IA,IS) = FION(3,IA,IS) + FHILLS(3,IA,IS)
                ENDDO
              ENDDO
            endif
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
        endif

C     ==================================================================

        if(qmnode) then 
          IF(CALSTE) CALL TOTSTR
C         FINAL UPDATE FOR VELOCITIES
          ECNSTR = 0.0D0
          ERESTR = 0.0D0
          IF(PARENT) THEN
            CALL VELUPI(VELP,FION,1)
            IF(qmmm_reflex) CALL mm_qm_boundary(TAUP,VELP) ! cmb
            call mm_solv_const('RATTL',dt_ions,taup,velp,tau0)
            CALL RATTLE(TAUP,VELP)
          ENDIF
          BSCLCS=1
          IF(BSYMM)CALL SETBSSTATE

          IF (.NOT.classical) THEN
            CALL VELUPA(C0,CM,C2,NSTATE,1)
            IF(BSYMM)THEN
              BSCLCS=2
              CALL SETBSSTATE
              CALL VELUPA(C0(1,1,2),CM(1,1,2),C2(1,1,2),NSTATE,1)
            END IF

            call mm_dim(mm_go_qm,statusdummy)
            IF(BSYMM)THEN
              BSCLCS=1
              CALL SETBSSTATE
            END IF
            CALL RORTV(C0,CM,C2,SC0,GAMY,NSTATE,SCR,LSCR)
            IF(BSYMM)THEN
              BSCLCS=2
              CALL SETBSSTATE
              CALL RORTV(C0(1,1,2),CM(1,1,2),C2(1,1,2),SC0(1,1,2),
     &            GAMY(1,2),NSTATE,SCR,LSCR)
            ENDIF
          ENDIF
          call mm_dim(mm_go_mm,statusdummy)
C         COMPUTE THE IONIC TEMPERATURE TEMPP
          IF(PARENT) THEN

            CALL EKINPP(EKINP,VELP)
            IF(LEXTLAGRANGE.AND. LTCGLOBAL) THEN
              CALL EKINCV_GLOBAL(EK_CV)
              TEMPP=(EK_CV+EKINP)*FACTEM*2.D0/(GLIB+DBLE(NCOLVAR))
            ELSE 
              TEMPP=EKINP*FACTEM*2.D0/GLIB
            ENDIF 
cMcB  calculate local TEMP  a f t e r  corrections on VELP()!
          ENDIF
C     IONIC TEMPERATURE CONTROL
          IF(PARENT) CALL RSCVP(TEMP1,TEMP2,TEMPP,VELP)
C     SUBTRACT ROTATION AROUND CENTER OF MASS
          IF(PARENT.AND.SUBROT)CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.FALSE.)
C     SUBTRACT CENTER OF MASS VELOCITY
          IF(PARENT.AND.SUBCOM)CALL COMVEL(VELP,VCMIO,.FALSE.)
C     UPDATE NOSE THERMOSTATS
          IF(TNOSEE.OR.TC) THEN
              CALL REKINE(CM,NSTATE,EKINC)
              IF(BSYMM)THEN
                EKINC_BS=EKINC
                CALL REKINE(CM(1,1,2),NSTATE,EKINC)
                EKINC_HS=EKINC
              END IF
          END IF
          BSCLCS=1
          CALL NOSEUP(VELP,CM,NSTATE,1)
          IF(BSYMM)THEN
            BSCLCS=2
            CALL NOSEUP(VELP,CM(1,1,2),NSTATE,2)
          END IF
C         ANNEALING
          BSCLCS=1
          CALL ANNEAL(VELP,CM(1,1,1),NSTATE,SCR)
          CALL BERENDSEN(VELP,CM(1,1,1),NSTATE,SCR,EKINC,0.0D0)
          IF(BSYMM)THEN
            BSCLCS=2
            CALL ANNEAL(VELP,CM(1,1,2),NSTATE,SCR)
            CALL BERENDSEN(VELP,CM(1,1,2),NSTATE,SCR,EKINC,0.0D0)
          END IF
          IF(PARENT) THEN
            CALL EKINPP(EKINP,VELP)
            IF(LEXTLAGRANGE.AND. LTCGLOBAL) THEN
              CALL EKINCV_GLOBAL(EK_CV)
              TEMPP=(EK_CV+EKINP)*FACTEM*2.D0/(GLIB+DBLE(NCOLVAR))
            ELSE 
              TEMPP=EKINP*FACTEM*2.D0/GLIB
            ENDIF 
cMcB  now the temperatures fit to velocities written to TRAJECTORY!
C calculate local kinetic temperature in QM and MM subsystem
C and write to "QM_TEMP"
            IF(NFI_lt.GT.0) THEN
              CALL MM_LOCALT(VELP,PMA,FACTEM,TEMPP,GLIB,NFI,NFI_lt)
            ENDIF
          ENDIF
C         RESCALE ELECTRONIC VELOCITIES
          IF(TC.AND.(.NOT.BSYMM)) 
     &      CALL RSCVE(EKIN1,EKIN2,EKINC,EKINW,CM,NSTATE,NGW)
          IF(BSYMM.AND.TC)THEN
            CALL RSCVE(EKIN1,EKIN2,EKINC_BS,EKINW,CM,NSTATE,NGW)
            CALL RSCVE(EKIN1,EKIN2,EKINC_HS,EKINW,CM(1,1,2),NSTATE,NGW)
          END IF
C         MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
          IF(PARENT) CALL DISPP(TAUP,TAUI,DISA)
C         KINETIC ENERGY OF THE ELECTRONS
          CALL REKINE(CM,NSTATE,EKINC)
          IF(BSYMM)THEN
            EKINC_BS=EKINC
            CALL REKINE(CM(1,1,2),NSTATE,EKINC)
            EKINC_HS=EKINC
            EKINC=(SCALHS*EKINC_HS)+(SCALBS*EKINC_BS)
          END IF
C         ENERGY OF THE NOSE THERMOSTATS
          IF(PARENT) CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
          IF(PARENT) THEN
            CALL FILECLOSE(3)
            CALL FILEOPEN(3,FILEN,FO_APP,FERROR)
            ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR+ERESTR+EKINCV+VHARM
            EHAM=ECONS+EKINC
            TIME2=TIMEF()
            TCPU=(TIME2-TIME1)*0.001D0
C           Printing data of Broken symmetry calculation
            IF(BSYMM) THEN
              COUPLJ = (ETOTHS - ETOTBS) * RTSASB
              JWN=COUPLJ*AUTOCM
              WRITE(277,'(I10,11F16.8)')
     &           NFI,EKINC_BS,EKINC_HS,ETOT,ETOTBS,ETOTHS,SPD_BS,
     &           SPD_HS,SPDA_BS,SPDA_HS,COUPLJ,JWN
              CALL MY_FLUSH(277)
            END IF
C           PRINTOUT the evolution of the accumulators every time step
            CALL WRPRINT_MD(EIGV,F,AMU,NSTATE,TAUP,FION,
     &                      EKINC,TEMPP,ETOT,ECONS,EHAM,DISA,
     &                      TCPU,.FALSE.,NFI,INFI)
C           UPDATE ACCUMULATORS
            CALL PACCA(EKINC,TEMPP,ETOT,ECONS,EHAM,ENOSE,ENOSP,ECNSTR,
     *                 ERESTR,DISA,TCPU,NFI,1)
C           Store ionic coordinates and velocities for statistics
            MOVIE= MOUT  .AND. MOD(NFI-1,IMOVIE).EQ.0
            RPRINT=ROUT  .AND. MOD(NFI-1,NTRAJ ).EQ.0
            TXYZ=  XTOUT .AND. MOD(NFI-1,NTRAJ ).EQ.0
            TDCD=  DCOUT .AND. MOD(NFI-1,NTRAJ ).EQ.0
            IF(MOD(NFI-1,NTRAJ).EQ.0) THEN
              CALL FILEOPEN(83,'MM_CELL_TRANS',FO_APP,FERROR)
              WRITE(83,'(I10,3F15.10)') NFI,(MM_C_TRANS(K),K=1,3)
              CALL FILECLOSE(83)
            ENDIF
            CALL PRINTP(SCR,TAUP,VELP)
            IF(TWRITEFORCETRAJECTORY) CALL PRINTP2(TAUR,TAUP,VELP,FION)
          ENDIF

          IF(.NOT.EXSOFT) CALL TESTEX(EXSOFT)
          IF(INFI.EQ.NOMORE) THEN
            EXSOFT=.TRUE.
            EXNOMORE=.TRUE.
          ENDIF

        end if ! qmnode

C       STOP THE RUN IF THE USER HAS SET THE SIGNAL 30
        IN=0
        OUT=0
        IF(EXSOFT) IN=1
        MSGLEN = 1 * 8/IRAT
        CALL MY_COMBINE(IN,OUT,MSGLEN,2,QMMMGRP)
        IF(OUT.NE.0) EXSOFT=.TRUE.

        if(qmnode) then 
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
C     Time dependent potential applied directly on the Collective Variables
            CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &                      LQUENCH,LMETARES,EKINC,EKINP)
            ENDIF
          ENDIF
C     temperature ramping
        CALL TEMPRAMP(TEMP1,TEMP2)
        end if ! qmnode

        IF(EXSOFT) GOTO 100

        if (qmnode) then 
C         UPDATE IONIC POSITIONS
          CALL DCOPY(3*NAX*NSX,TAUP(1,1,1),1,TAU0(1,1,1),1)
        end if ! qmnode
C     ==================================================================
C     ==     END OF MAIN LOOP                                         ==
C     ==================================================================
      ENDDO
  100 CONTINUE
      CALL MY_SYNC(QMMMGRP)
      CALL mm_dim(mm_go_mm,statusdummy)
      if ( parent ) then
         call mm_write_gromos_coord('CRD_FIN.g96',TAUP,VELP,NAX,NSX)
      endif
      IF(qmnode) THEN 
        IF(TWANN) THEN
          call mm_dim(mm_go_qm,statusdummy)
          CALL DDIPO(TAUP,C0,CM,C2,SC0,SCR,LSCR,NSTATE)
          CALL FORCEDR(C0,C2,SC0,RHOE,PSI,TAUP,FION,EIGV,SCR,LSCR,
     *        NSTATE,1,.FALSE.,.TRUE.)
          CALL WC_DOS(C0,C2,SCR,LSCR,NSTATE)
          call mm_dim(mm_go_mm,statusdummy)
        ENDIF
        call mm_dim(mm_go_qm,statusdummy)
        if(RHOOUT.AND.(NRHOOUT.LE.0))
     &      CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
        call mm_dim(mm_go_mm,statusdummy)
C      PRINT ACCUMULATOR
        IF(PARENT) CALL PACCA(EKINC,TEMPP,ETOT,ECONS,EHAM,ENOSE,ENOSP,
     &      ECNSTR,ERESTR,DISA,TCPU,NFI,2)
        BSCLCS=1
        IF(BSYMM)CALL SETBSSTATE
        call mm_dim(mm_go_qm,statusdummy)
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
        call mm_dim(mm_go_mm,statusdummy)
        IF(PARENT) CALL FINALP(TAU0,FION,VELP,EIGV)
C
      ENDIF                     ! qmnode
      IF(TSAMPL) THEN
        CALL SAMPLE_GO
        GOTO 99999
      ENDIF
10000 CONTINUE
C
      if (qmnode) then 
        IF(NONORT) THEN
          CALL FREEM(IP_EIGV)
          CALL FREEM(IP_EIGM)
        ENDIF
        IF(PARENT) CALL FILECLOSE(3)
        IF(BSYMM.AND.PARENT) CALL FILECLOSE(277)
        CALL FREEM(IP_RHOE)
        CALL FREEM(IP_PSI)
        CALL FREEM(IP_SCR)
      endif 
C     ==--------------------------------------------------------------==
      call mm_dim(mm_revert,oldstatus)
      CALL MY_SYNC(QMMMGRP)
#endif
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_MM_MDMAIN(LMDMAIN,TAG)
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
      if(tqmmm)lmdmain=max(lmdmain,KR1*KR2S*KR3S)
      if(tqmmm)lmdmain=max(lmdmain,NAX*NSX*3)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE MM_LOCALT(VELP,PMA,FACTEM,TEMPP,GLIB,NFI,NFI_lt)
C     ==--------------------------------------------------------------==
C     Compute kinetic temperature for QM and MM subsystem separately
C     does not rely on CAFES being used and is more accurate!
C     initially written by udo schmitt march 2003
C     revised by mauro boero, axel kohlmeyer march/april 2005
C     updated for separate solvent temperature and constraints, august 2005, AK.
C          
      IMPLICIT NONE
      INCLUDE 'system.h' 
      INCLUDE 'ions.inc' 
      INCLUDE 'cotr.inc'
      INCLUDE 'fileopen.inc'
      INCLUDE 'mm_dim.inc'
      INTEGER IS,IA,IAT,I,NFI_lt,NFI,ATMIDX,NDOF
      REAL*8  EKINQM,EKINMM,EKINCL,TEMPQM,TEMPMM,TEMPCL,TEMPP,PMA(*)
      REAL*8  EKINP,VELP(3,NAX,*)
      REAL*8  FACTEM,GLIB,CONST,QMCNSTR,MMCNSTR,QMDOF,MMDOF
      LOGICAL FERROR
C     ==--------------------------------------------------------------==
#if defined (__GROMOS)
      IF(MOD(NFI-1,NFI_lt).NE.0) RETURN
      
C     compute constraints contributions to DOFs.
      QMCNSTR=0.0d0
      MMCNSTR=0.0d0
      IF(MCNSTR.GT.0) THEN
        DO IS=1,MCNSTR
C     set prefactor depending on constraint type.
          IF(NTCNST(1,IS).EQ.1) THEN
            CONST=0.5d0
          ELSEIF(NTCNST(1,IS).EQ.2) THEN
            CONST=1.0d0/3.0d0
          ELSEIF(NTCNST(1,IS).EQ.3) THEN
            CONST=0.25d0
          ELSEIF(NTCNST(1,IS).EQ.4) THEN
            CONST=0.5d0
          ELSEIF(NTCNST(1,IS).EQ.5) THEN
            CONST=0.25d0
          ELSEIF(NTCNST(1,IS).EQ.6) THEN
            CONST=1.0d0
          ELSEIF(NTCNST(1,IS).EQ.7) THEN
            CONST=1.0d0/3.0d0
          ELSEIF(NTCNST(1,IS).EQ.8) THEN
            CONST=1.0d0
          ENDIF
C     loop over list of atoms in constraint. unused entries are supposed to be 0.
          DO IA=2,6
            ATMIDX=NTCNST(IA,IS)
            IF(ATMIDX.LE.0.OR.ATMIDX.GT.NATm) THEN
              CONST=0.0d0             ! do nothing
            ELSEIF(ATMIDX.LE.NATq) THEN
              QMCNSTR=QMCNSTR + CONST ! atom is quantum
            ELSE IF (ATMIDX.LE.NRPT) THEN
              MMCNSTR=MMCNSTR + CONST ! atom is solute but not quantum
            ENDIF
          ENDDO
        ENDDO
      ENDIF

C  QM atoms in solute
      IAT=0
      NDOF=0
      EKINQM=0.0D0
      DO IS=1,NSPq
        CONST=0.5D0*PMA(IS)
        DO IA=1,NAq(IS)
          IAT=IAT+1
          NDOF=NDOF+LSKCOR(1,IAT)+LSKCOR(2,IAT)+LSKCOR(3,IAT)
          EKINQM=EKINQM+CONST*(VELP(1,IA,IS)*VELP(1,IA,IS)
     .                        +VELP(2,IA,IS)*VELP(2,IA,IS)
     .                        +VELP(3,IA,IS)*VELP(3,IA,IS))
        ENDDO
      ENDDO
      QMDOF=DBLE(NDOF)-QMCNSTR
      IF(QMDOF.GT.0.1d0) THEN
        TEMPQM=EKINQM*FACTEM*2.D0/QMDOF
      ELSE
        TEMPQM=0.0d0
      ENDIF

C  MM atoms in solute not counting the QM atoms
      NDOF=0
      EKINMM=0.0D0
      DO IS=NSPq+1,NSPm
        CONST=0.5D0*PMA(IS)
        DO IA=1,NAm(IS)
          IF(gratom((IS-1)*NAX+IS).le.NRPT) THEN
            IAT=IAT+1
            NDOF=NDOF+LSKCOR(1,IAT)+LSKCOR(2,IAT)+LSKCOR(3,IAT)
            EKINMM=EKINMM+CONST*(VELP(1,IA,IS)*VELP(1,IA,IS)
     .                          +VELP(2,IA,IS)*VELP(2,IA,IS)
     .                          +VELP(3,IA,IS)*VELP(3,IA,IS))
          ENDIF
        ENDDO
      ENDDO
      MMDOF=DBLE(NDOF)-MMCNSTR
C     account for uncounted constraints in case we have no solvent
      IF(GLIB.LT.(QMDOF+MMDOF)) MMDOF=GLIB-QMDOF
      IF(MMDOF.GT.0.1d0) THEN
        TEMPMM=EKINMM*FACTEM*2.D0/MMDOF
      ELSE
        TEMPMM=0.0d0
      ENDIF

      EKINP=TEMPP/FACTEM/2.0D0*GLIB
      EKINCL=EKINP-EKINQM-EKINMM
      IF(GLIB.GT.(QMDOF+MMDOF)) THEN
        TEMPCL=EKINCL*FACTEM*2.D0/(GLIB-QMDOF-MMDOF)  
      ELSE
        TEMPCL=0.0d0
      ENDIF
      IF(TEMPCL.GT.0.0d0) THEN
        WRITE(6,'(/,A,F8.2,A,I4,1X,A,F8.2,A,I7,1X,A,F8.2,/)') 
     &       ' T(QM)=',TEMPQM,' DOF(QM)=',NINT(QMDOF),
     &       ' T(MM)=',TEMPMM,' DOF(MM)=',NINT(MMDOF),
     &       ' T(SOL)=',TEMPCL
      ELSE
        WRITE(6,'(/,A,F8.2,A,I4,1X,A,F8.2,A,I7,/)') 
     &       ' T(QM)=',TEMPQM,' DOF(QM)=',NINT(QMDOF),
     &       ' T(MM)=',TEMPMM,' DOF(MM)=',NINT(MMDOF)
      ENDIF
      CALL FILEOPEN(49,'QM_TEMP',FO_APP,FERROR)
      WRITE(49,'(I6,4F12.4)') NFI,TEMPQM,TEMPMM,TEMPCL,TEMPP
      CALL FILECLOSE(49)
#endif
      RETURN
      END
C     ==================================================================
