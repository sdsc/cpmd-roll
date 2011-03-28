C     ==================================================================
      SUBROUTINE mm_MDDIAG(C0,CM,C1,C2,SC0,VPP,GAMX,GAMY)
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
      INCLUDE 'rmas.inc'
      INCLUDE 'isos.inc'
      INCLUDE 'cnst_dyn.inc'
      INCLUDE 'comvel.inc'
      INCLUDE 'fileopen.inc'
c     Qmmm
      real*8 EXTF(*)
      include 'efld.inc'
      include 'mm_dim.inc'
      include 'mm_input.inc'
c     Qmmm locals
      real*8  VCM(3),PMA00
      integer im,is,ia,ix
      REAL*8  c_trans(3)
      INTEGER IN,OUT
      real*8  EHAM_0

C     Arguments
      COMPLEX*16 C0(NGWK,N,*),C2(NGWK,*),C1(*),CM(*),SC0(NGW,*)
      REAL*8     VPP(*),GAMX(*),GAMY(*)
C     Variables
      DIMENSION  F(N,*),RIN0(*),RK(3,*),WK(*)
      REAL*8     TAUI(3,NAX,*),TAUR(3,NAX,*),EIGV(N,*),
     &           RM1(*),RINP(*)
      POINTER    (IP_TAUI,TAUI),(IP_TAUR,TAUR),(IP_EIGV,EIGV),
     &           (IP_RM1,RM1),(IP_RINP,RINP)
      COMPLEX*16 PSI(NNR1,*)
      REAL*8     RHOE(NNR1,*),SCR(*),TAUIO(3,*)
      POINTER    (IP_PSI,PSI),(IP_RHOE,RHOE),(IP_SCR,SCR),
     &    (IP_TAUIO,TAUIO)
      CHARACTER  TAG*30
      REAL*8     TIMEF,TIME1,TIME2,DUMMY,LMIO(3),VCMIO(4),RMEM,
     &           ECONS,EKINP,EKINCP,DISA,ENOSE,ENOSP,EKIN1,EKIN2,
     &           TEMP1,TEMP2,TEMPP,TCPU,EKINH1,EKINH2,EKINC
      EXTERNAL   TIMEF
      INTEGER    IREC(100),IFCALC,NX,IK,NNX,NMIN,LENEXT,
     &           LSCR,IL_RHOE,IL_PSI
      CHARACTER FILEN*100
      LOGICAL    FERROR,TESTSTORE
      INTEGER    MSGLEN,ITEMP,NMM
C     META DYNAMICS
      LOGICAL    LMETARES
      REAL*8     EK_CV
      INTEGER    K,J
      INTEGER    SAVE_NFI,LOOPNFI,NFIMIN,NFIMAX
      logical    oldstatus,statusdummy
      integer    nstate
      real*8     sk1
      character*10 prch
C
      INCLUDE 'mm_extrap.inc'
C     ==================================================================
      IF(TDDFT.AND.TRESPONSE) CALL STOPGM("MDDIAG",
     &                        "TDDFT.AND.TRESPONSE NOT POSSIBLE")
C     ==--------------------------------------------------------------==
#if defined (__GROMOS)
      TIME1 = TIMEF()
      call mm_dim(mm_go_mm,oldstatus)
C
      NSTATE=N
      IF (QMNODE) THEN
        if(TEXTFLD)then
          CALL MEMORY(IP_EXTF,KR1*KR2S*KR3S,'EXTF')
          CALL AZZERO(EXTF,KR1*KR2S*KR3S)
        endif
C       Memory for densities
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
        NACC = 22
        NFI  = 0
        MODENS=.FALSE.
        ENGPRI=.FALSE.
        CALSTE=TPRES

        IF(TQMMM.AND.TIVAN) THEN
          CALL STOPGM('MM_MDDIAG','QMMM WITH VANDERBILT UNSUPPORTED')
        ENDIF

        CALL MEMORY(IP_EIGV,NLSD*N*NKPTS,'EIGV')
C       ==------------------------------------------------------------==
C     Extrapolation
        IF(TEXTRAP) THEN
          LENEXT=2*NGWK*NSTATE*NKPTS*MEXTRA
          RMEM = 16.D0*LENEXT*1.D-6
          CALL MEMORY(IP_COLD,LENEXT,'COLD')
          IF(PARENT) WRITE(6,'(A,T51,F8.3,A)') ' MM_MDDIAG| '
     *     // 'EXTRAPOLATION WAVEFUNCTION HISTORY TAKES ',RMEM,' MBYTES'
        ENDIF
C     ==--------------------------------------------------------------==
C       SCR ALLOCATION AND PARTITION (SCRATCH ARRAY).
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
        if (qmmm) then
         CALL GIVE_SCR_MM_MDDIAG(LSCR,TAG)
        else
         CALL GIVE_SCR_MDDIAG(LSCR,TAG)
        endif
        CALL MEMORY(IP_SCR,LSCR,'SCR')
      ELSE
        NMIN=10
        CALL MEMORY(IP_EIGV,NMIN,'EIGV')
        CALL GIVE_SCR_MDDIAG(LSCR,TAG)
        CALL MEMORY(IP_SCR,LSCR,'SCR')
      ENDIF ! qmnode
C     ==--------------------------------------------------------------==
99999 IF(TSAMPL) THEN
        CALL SAMPLE_WAIT
        IF(NOMORE.LT.0) GOTO 10000
      ENDIF
      NFNOW=1
C     ==--------------------------------------------------------------==
      call mm_dim(mm_go_mm,statusdummy)
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

      if (parent.and.n_cg.ge.1)
     &     CALL FILEOPEN(40,'restrain.out',FO_APP,FERROR)
      if (parent.and.tqmmm.and.tddft)  
     &     CALL FILEOPEN(41,'ENERGIES_EX',FO_APP,FERROR)
C     ==--------------------------------------------------------------==
      call mm_dim(mm_go_mm,statusdummy)
      if (qmnode ) then
        IF(IPRINT_STEP.EQ.0) IPRINT_STEP=NOMORE+1
        IF(IPRINT(IPRINT_EIGEN).EQ.0) IPRINT(IPRINT_EIGEN) = -1
        IF(IPRINT(IPRINT_COOR) .EQ.0) IPRINT(IPRINT_COOR)  =  1
        IF(IPRINT(IPRINT_FORCE).EQ.0) IPRINT(IPRINT_FORCE) =  1
C       ==--------------------------------------------------------------==
C       Set IREC to restart file.
        CALL READ_IREC(IREC)
C       INITIALIZATION OF WAVEFUNCTION AND COORDINATES
        CALL INITRUN(IREC,C0,C2,SC0,RHOE,PSI,EIGV,SCR,LSCR)
cmb-bug
        IF(parent) CALL dcopy(3*nax*nsx,taup,1,taui,1)
cmb-bug
C     ==--------------------------------------------------------------==
C       TIME STEP FUNCTIONS
        CALL DYNIT(EKINCP,EKIN1,EKIN2,TEMP1,TEMP2,EKINH1,EKINH2)
C       PARAMETERS FOR THE NOSE-HOOVER THERMOSTATS
        IF(TNOSEP.AND.PARENT) CALL NOSEPA(1,1)
C       Dont symmetrize density
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
C 28/3/03 added
        call mm_dim(mm_go_qm,statusdummy)
        call phfac(TAU0)
        if(tinlc) call copot(rhoe,psi,scr,lscr,calste)
        call mm_dim(mm_go_mm,statusdummy)
        CALL AZZERO(CM,2*NGW*NSTATE)
        IF(.not.qmmm_reflex) THEN
          CALL mm_translate_qmmm(TAU0,C0,CM,NSTATE)
        ENDIF
C 28/3/03


C       INITIALIZE VELOCITIES
        call mm_dim(mm_go_mm,statusdummy)
        IF(PARENT) CALL DETDOF(TAU0,TAUR)

C     INITIALIZE METADYNAMICS VARIABLES used also for 
C     SHOOTING from SADDLE POINT with RANDOM VELOCITIES
        IF(PARENT .AND. (LCOLVARDYN .OR. LSADPNT)) THEN
          CALL COLVAR_STRUCTURE(TAU0,TAUR)
        ENDIF

        IF((IREC(IREC_VEL).EQ.0).and.
     &      (.not.rgeo).and.(.not.restart_traj)) THEN
          ECNSTR = 0.0D0
          ERESTR = 0.0D0
          CALL RINVEL(VELP,C2,N)
          IF(PARENT) THEN
            CALL TAUCL(VELP)
            call mm_solv_const('RATTL',dt_ions,tau0,velp,tau0)
            CALL RATTLE(TAU0,VELP)
          ENDIF
C         RESCALE VELOCITIES ONLY IF NOT READ FROM GROMOS.G96 FILE
          IF ( NTX_vel.ne.1 ) CALL RVSCAL(VELP)
        ELSE
          IF(PARENT) THEN
            CALL TAUCL(VELP)
            call mm_solv_const('RATTL',dt_ions,tau0,velp,tau0)
            CALL RATTLE(TAU0,VELP)
          ENDIF
          IF(TRESCALE) CALL RVSCAL(VELP)
        ENDIF
        IF(QUENCHP) CALL AZZERO(VELP,3*NAX*NSX)
        IF(classical) CALL AZZERO(CM,2*NGW*NSTATE)
C       COMPUTE THE IONIC TEMPERATURE TEMPP
        IF(PARENT) THEN
          CALL EKINPP(EKINP,VELP)
          TEMPP=EKINP*FACTEM*2.D0/GLIB
        ENDIF
        IF(TREVERS) THEN
C         invert velocities (useful for path sampling)
          CALL DSCAL(3*NAX*NSX,-1.D0,VELP,1)
        ENDIF
C       RESET ACCUMULATORS
        IF(PARENT.AND.IREC(IREC_AC).EQ.0)
     &       CALL RESETAC(TAU0,TAUI,NFI)
C
        CALL WRITE_IREC(IREC)
C       INITIALIZE FORCES
        call mm_dim(mm_go_qm,statusdummy)
        IF(TDIAG) THEN
          IF(TLANC) NX=1
          IF(TDAVI) NX=NGWK*NDAVV*NKPNT+1
          IF(DIIS)  NX=((NGWK*N+8)*MDIIS*NKPNT)/4
        ELSEIF(TSDE) THEN
            NX=1
        ELSEIF(DIIS) THEN
            NX=(NGWK*N+8)*MDIIS/2+4
        ELSEIF(PCG) THEN
            NX=1
        ENDIF
        IF(PARENT) THEN
          WRITE(*,'(1X,64("="))')
          WRITE(*,'(1X,"==",T25,A,T64,"==")')
     &         'FORCES INITIALIZATION'
          WRITE(*,'(1X,64("="))')
        ENDIF
        IFCALC=0

C       Initialize Metadynamics contributions
        IF(LCOLVARDYN .AND. LEXTLAGRANGE) THEN
          call mm_dim(mm_go_mm,statusdummy)
          LMETARES= .FALSE.
          DISA=0.D0 
          IF(TMULTI) THEN
            CALL META_EXT_MUL(TAU0,VELP,TAUR,SCR,LSCR,
     &               .FALSE.,LMETARES,.FALSE.,0.D0,EKINP)
          ELSE
            
            CALL META_EXTLAGR(TAU0,VELP,TAUR,SCR,LSCR,
     &           .FALSE.,LMETARES,.FALSE.,0.D0,EKINP)
          ENDIF
          call mm_dim(mm_revert,statusdummy)
        ENDIF
      endif ! (qmnode)

      CALL mm_dim(mm_go_mm,statusdummy)
      IF ( parent ) THEN
         CALL mm_write_gromos_coord('CRD_INI.g96',TAU0,VELP,NAX,NSX)
      ENDIF

      CALL MY_SYNC(QMMMGRP)
      CALL mm_forces_diag(N,C0,C1,C2,CM,SC0,CM(NX),VPP,EIGV,
     &                 RHOE,PSI,SCR,LSCR,
     &                 TAU0,VELP,TAUI,FION,IFCALC,
     &                 IREC,.TRUE.,.TRUE.)
C
      if (qmnode) then
C       switch on info printing for the lin resp part
        IF (TRESPONSE) INTER_PT_FIRSTCALL = .TRUE.

        call mm_dim(mm_go_mm,statusdummy)
        CALL DCOPY(NNX,RIN0(1),1,RM1(1),1)
C       INITIALIZE THERMOSTATS
        IF(PARENT) THEN
          ITEMP=IREC(IREC_NOP1)+IREC(IREC_NOP2)+IREC(IREC_NOP3)
     *        +IREC(IREC_NOP4)
          IF(TNOSEP .AND. ITEMP.EQ.0) CALL NOSPINIT(1)
          FILEN='ENERGIES'
          CALL FILEOPEN(3,FILEN,FO_APP+FO_VERB,FERROR)
        ENDIF
        IF(PARENT) THEN
          WRITE(*,'(1X,64("="))')
          WRITE(*,'(1X,"==",T20,A,T64,"==")')
     &         'END OF FORCES INITIALIZATION'
          WRITE(*,'(1X,64("="),/)')
        ENDIF
        CALL WRITE_IREC(IREC)
C     ==--------------------------------------------------------------==
C     == END INITIALIZATION                                           ==
C     ==--------------------------------------------------------------==
        call mm_dim(mm_go_mm,statusdummy)
        IF(TESTSTORE(0).AND.TSAMPL)
     *     CALL ZHWWF(2,IREC,C0,C2,N,EIGV,TAU0,VELP,TAUI,NFI)
        IF(PARENT) THEN
C         MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
          IF(PARENT) CALL DISPP(TAU0,TAUI,DISA)
C         ENERGY OF THE NOSE THERMOSTATS
          CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
          ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR+ERESTR
          TIME2 = TIMEF()
          TCPU = (TIME2 - TIME1)*0.001D0
          WRITE(6,'(A,T50,F8.2,A8)') ' TIME FOR INITIALIZATION:',
     &       TCPU,' SECONDS'
          WRITE(6,'(//,1X,64("="))')
          WRITE(6,'(1X,"=",T20,A,T65,"=")')
     &         'MOLECULAR DYNAMICS SIMULATION'
          WRITE(6,'(1X,64("="))')
C         CALL WRPRINT_MD(EIGV,F,AMU,N,TAU0,FION,
C    &                  0.D0,TEMPP,ETOT,ECONS,0.D0,DISA,
C    &                  TCPU,.FALSE.,NFI,0)
        ENDIF
      endif ! (qmnode)
C     ==================================================================
C     ==          THE BASIC LOOP FOR MOLECULAR DYNAMICS               ==
C     ==                 USING VELOCITY VERLET                        ==
C     ==================================================================
      INFI=0
      NFIMIN=NFI+1
      NFIMAX=NFI+NOMORE
      DO LOOPNFI=NFIMIN,NFIMAX
        call mm_dim(mm_go_mm,statusdummy)
        CALL MY_SYNC(QMMMGRP)
C       CALL MY_SYNC(ALLGRP)
        INFI=INFI+1
        NFI=LOOPNFI
        if (qmnode) then
         TIME1=TIMEF()
         SUBCOM=TSUBCOM.AND.MOD(NFI-1,NCOMV).EQ.0
         SUBROT=TSUBROT.AND.MOD(NFI-1,NROTV).EQ.0
C        ANNEALING
         CALL ANNEAL(VELP,C2,N,SCR)
         CALL BERENDSEN(VELP,C2,NSTATE,SCR,0.0D0,0.0D0)
C     SUBTRACT CENTER OF MASS VELOCITY
         IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.TRUE.)
C     SUBTRACT ROTATION AROUND CENTER OF MASS
         IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.TRUE.)
C     UPDATE NOSE THERMOSTATS
         CALL NOSEUP(VELP,C2,N,1)
C     UPDATE VELOCITIES
         IF(PARENT) CALL VELUPI(VELP,FION,1)
C     UPDATE POSITIONS
         ECNSTR = 0.0D0
         ERESTR = 0.0D0
         IF(PARENT) THEN
           CALL POSUPI(TAU0,TAUP,VELP)
           call mm_solv_const('SHAKE',dt_ions,taup,velp,tau0)
           IF(MCNSTR.NE.0) THEN
             CALL CPMDSHAKE(TAU0,TAUP,VELP)
           ENDIF
         ENDIF
        endif ! (qmnode)
C
        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(TAUP,MSGLEN,SOURCE,QMMMGRP)
        call azzero(cm,2*ngwk*nstate)

        IF(.not.qmmm_reflex) THEN
          CALL mm_translate_qmmm(TAUP,C0,CM,NSTATE)
        ENDIF

        if(qmnode) then
         call mm_dim(mm_go_qm,statusdummy)
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
C        CALCULATE THE FORCES
         CALSTE=TPRES.AND.MOD(INFI,NPRES).EQ.0
         IF(TEXTRAP) THEN
C     Extrapolate wavefunctions
           CALL EXTRAPWF(INFI,C0,SCR,COLD,N,MEXTRA)
         ENDIF
         call mm_dim(mm_go_mm,statusdummy)
        endif ! (qmnode)
C
        call my_flush(6)
        IF(TLANC) NX=1
        IF(TDAVI) NX=NDAVV*NKPNT+1
        CALL MY_SYNC(QMMMGRP)

C RESPONSE calculation
        IF (TRESPONSE) THEN
C          save the MD step number
           save_NFI=NFI
C          localisation at first iteration + PT
           CALL mddiag_interaction_p(N,C0,C2,CM,SC0,
     $          CM(NX),VPP,EIGV,RHOE,PSI,SCR,LSCR,
     $          TAUP,VELP,TAUI,FION,IFCALC,IREC,.TRUE.,.FALSE.)
C          sets the number of iteration and recover MD step number
           IFCALC=NFI
           NFI=save_NFI

C          switch off the info printing
           INTER_PT_FIRSTCALL=.FALSE.
        ELSE

          CALL mm_forces_diag(N,C0,C1,C2,CM,SC0,CM(NX),VPP,EIGV,
     &                    RHOE,PSI,SCR,LSCR,
     &                    TAUP,VELP,TAUI,FION,IFCALC,
     &                    IREC,.TRUE.,.FALSE.)

        ENDIF
        CALL mm_dim(mm_go_mm,statusdummy)
          
C     ==================================================================
C       Meta Dynamics of Collective Variables

        if(qmnode)then
          IF(LCOLVARDYN) THEN
            LMETARES= .FALSE.

            IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
              IF(TMULTI) THEN
              CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &                .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
              ELSE    
                CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &                 .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
              ENDIF
            ELSE
C     Time dipendent potential applied directly on the Collective Variables
              CALL META_COLVAR(TAUP,VELP,FION,TAUR, SCR,LSCR,
     &                 .FALSE.,LMETARES,0.0D0,EKINP)
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
C        FINAL UPDATE FOR VELOCITIES
         ECNSTR = 0.0D0
         ERESTR = 0.0D0
         IF(PARENT) THEN
           CALL VELUPI(VELP,FION,1)
           IF(qmmm_reflex) CALL mm_qm_boundary(TAUP,VELP) ! cmb
           call mm_solv_const('RATTL',dt_ions,taup,velp,tau0)
           CALL RATTLE(TAUP,VELP)
         ENDIF
         IF(PARENT) CALL GEOFILE(TAUP,VELP,'WRITE')
C        COMPUTE THE IONIC TEMPERATURE TEMPP
         IF(PARENT) THEN
C     calculate local kinetic temperature in QM and MM subsystem
C     and write to "QM_TEMP"
           CALL EKINPP(EKINP,VELP)
           TEMPP=EKINP*FACTEM*2.D0/GLIB
           IF(NFI_lt.GT.0) THEN
             CALL MM_LOCALT(VELP,PMA,FACTEM,TEMPP,GLIB,NFI,NFI_lt)
           ENDIF
         ENDIF
C     IONIC TEMPERATURE CONTROL
         IF(PARENT) CALL RSCVP(TEMP1,TEMP2,TEMPP,VELP)
C     SUBTRACT ROTATION AROUND CENTER OF MASS
         IF(PARENT.AND.SUBROT) CALL ROTVEL(TAU0,VELP,LMIO,TAUIO,.FALSE.)
C     SUBTRACT CENTER OF MASS VELOCITY
         IF(PARENT.AND.SUBCOM) CALL COMVEL(VELP,VCMIO,.FALSE.)
C     UPDATE NOSE THERMOSTATS
         CALL NOSEUP(VELP,C2,N,1)
         CALL BERENDSEN(VELP,C2,NSTATE,SCR,0.0D0,0.0D0)
C     ANNEALING
         CALL ANNEAL(VELP,C2,N,SCR)
         IF(PARENT) THEN
           CALL EKINPP(EKINP,VELP)
           TEMPP=EKINP*FACTEM*2.D0/GLIB
         ENDIF
C        MEAN SQUARE DISPLACEMENT OF DIFFERENT IONIC SPECIES
         IF(PARENT) CALL DISPP(TAUP,TAUI,DISA)
C        ENERGY OF THE NOSE THERMOSTATS
         IF(PARENT) CALL NOSENG(NFI,VELP,ENOSE,ENOSP,DUMMY,1)
C        CALCULATE PROPERTIES DURING SIMULATION.
         CALDIP=TDIPD.AND.MOD(NFI-1,NPDIP).EQ.0
         call mm_dim(mm_go_qm,statusdummy)
         CALL PROPCAL(C0,C2,CM,SC0,TAUP,EIGV,F,AMU,
     &                RHOE,PSI,SCR,LSCR,N,NKPNT,NFI,INFI)
         call mm_dim(mm_go_mm,statusdummy)
C        PRINTOUT the evolution of the accumulators every time step
         IF(PARENT) THEN
           CALL FILECLOSE(3)
           CALL FILEOPEN(3,FILEN,FO_APP,FERROR)
           ECONS=EKINP+ETOT+ENOSE+ENOSP+ECNSTR+ERESTR
           TIME2=TIMEF()
           TCPU=(TIME2-TIME1)*0.001D0
           CALL WRPRINT_MD(EIGV,F,AMU,N,TAUP,FION,
     &                     0.D0,TEMPP,ETOT,ECONS,0.D0,DISA,
     &                     TCPU,.FALSE.,NFI,INFI)
C          UPDATE ACCUMULATORS
           CALL PACCC(TEMPP,ETOT,ECONS,ENOSE,ENOSP,ECNSTR,ERESTR,
     *                EBOGO,DISA,TCPU,NFI,1)
C          STORE IONIC COORDINATES AND VELOCITIES FOR STATISTICS
           MOVIE=MOUT .AND. MOD(NFI-1,IMOVIE).EQ.0
           RPRINT=ROUT .AND. MOD(NFI-1,NTRAJ).EQ.0
           TXYZ=XTOUT .AND. MOD(NFI-1,NTRAJ).EQ.0
           TDCD=DCOUT .AND. MOD(NFI-1,NTRAJ).EQ.0
           IF(MOD(NFI-1,NTRAJ).EQ.0) THEN
           CALL FILEOPEN(83,'MM_CELL_TRANS',FO_APP,FERROR)
                WRITE(83,'(I10,3F15.10)') NFI,(MM_C_TRANS(K),K=1,3)
           CALL FILECLOSE(83)
           ENDIF
           CALL PRINTP(TAUR,TAUP,VELP)
           IF(TWRITEFORCETRAJECTORY) CALL PRINTP2(TAUR,TAUP,VELP,FION)
           TIME2=TIMEF()
           TCPU=(TIME2-TIME1)*0.001D0
         ENDIF
         IF(.NOT.EXSOFT) CALL TESTEX(EXSOFT)
         IF(NFI.EQ.NFIMAX) THEN
           EXSOFT=.TRUE.
           EXNOMORE=.TRUE.
         ENDIF
         call mm_dim(mm_go_mm,statusdummy)
       endif  ! qmnode

C      STOP THE RUN IF THE USER HAS SET THE SIGNAL 30
       IN=0
       OUT=0
       IF(EXSOFT) IN=1
       MSGLEN = 1 * 8/IRAT
       CALL MY_COMBINE(IN,OUT,MSGLEN,2,QMMMGRP)
       IF(OUT.NE.0) EXSOFT=.TRUE.

       if (qmnode) then
C     periodic output of density/wavefunction etc.
         IF(RHOOUT.AND.(NRHOOUT.GT.0)) THEN
           IF (MOD(NFI-1,NRHOOUT).EQ.0) THEN
             CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,NSTATE,NKPNT)
           ENDIF
         ENDIF
         IF(TESTSTORE(NFI).OR.EXSOFT)
     &       CALL ZHWWF(2,IREC,C0,C2,N,EIGV,TAUP,VELP,TAUI,NFI)

         IF(EXSOFT .AND.LCOLVARDYN) THEN
           LMETARES= .TRUE.
           IF(LEXTLAGRANGE) THEN
C     Metadynamics with Extended Lagrangian
             IF(TMULTI) THEN
               CALL META_EXT_MUL(TAUP,VELP,TAUR,SCR,LSCR,
     &             .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
             ELSE
               CALL META_EXTLAGR(TAUP,VELP,TAUR,SCR,LSCR,
     &             .FALSE.,LMETARES,.FALSE.,0.0D0,EKINP)
             ENDIF 
           ELSE
C     Time dependent potential applied directly on the Collective Variables
             CALL META_COLVAR(TAUP,VELP,FION,TAUR,SCR,LSCR,
     &           .FALSE.,LMETARES,0.0D0,EKINP)
           ENDIF
         ENDIF
C     temperature ramping
         CALL TEMPRAMP(TEMP1,TEMP2)
       endif                    ! qmnode

       if (qmnode) then
C        UPDATE IONIC POSITIONS
         CALL DCOPY(3*NAX*NSX,TAUP(1,1,1),1,TAU0(1,1,1),1)
C        UPDATE DENSITY
         CALL EXTRAP(NNX,ALXMIX,RM1,RIN0,RINP)
         CALL DCOPY(NNX,RIN0(1),1,RM1(1),1)
         CALL DCOPY(NNX,RINP(1),1,RIN0(1),1)
       endif ! (qmnode)
       IF(EXSOFT) GOTO 100

C     ==================================================================
C     ==     END OF MAIN LOOP                                         ==
C     ==================================================================
      ENDDO
      if (qmnode) then
        IF(PARENT) THEN
          WRITE(*,'(1X,64("="))')
          WRITE(*,'(1X,"=",T17,A,T65,"=")')
     &         'END OF MOLECULAR DYNAMICS SIMULATION'
          WRITE(*,'(1X,64("="),/,/)')
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
  100 CONTINUE
      CALL mm_dim(mm_go_mm,statusdummy)
      IF ( parent ) THEN
         CALL mm_write_gromos_coord('CRD_FIN.g96',TAUP,VELP,NAX,NSX)
      ENDIF
      IF(qmnode) THEN
       call mm_dim(mm_go_qm,statusdummy)
       IF(RHOOUT.AND.(NRHOOUT.LE.0))
     &     CALL RHOPRI(C0,TAU0,RHOE,PSI,SCR,LSCR,N,NKPNT)
       call mm_dim(mm_go_mm,statusdummy)
C      Print accumulators.
       IF(PARENT) CALL PACCC(TEMPP,ETOT,ECONS,ENOSE,ENOSP,ECNSTR,
     *                      ERESTR,EBOGO,DISA,TCPU,NFI,0)
       IF(PARENT) CALL GSIZE(FION,GNMAX,GNORM)
       IF(PARENT) CALL FINALP(TAU0,FION,VELP,EIGV)
      ENDIF ! (qmnode)
      IF(TSAMPL) THEN
        CALL SAMPLE_GO
        GOTO 99999
      ENDIF
10000 CONTINUE
C     ==--------------------------------------------------------------==
      if (qmnode) then
       CALL FREEM(IP_EIGV)
       IF(PARENT) CALL FILECLOSE(3)
       CALL FREEM(IP_RHOE)
       CALL FREEM(IP_PSI)
       CALL FREEM(IP_SCR)
       if (textfld) call freem(ip_extf)
       IF(TEXTRAP) CALL FREEM(IP_COLD)
       IF(TSUBROT) CALL FREEM(IP_TAUIO)
C     ==--------------------------------------------------------------==
      else
       CALL FREEM(IP_EIGV)
      endif ! (qmnode)
C     ==--------------------------------------------------------------==
      call mm_dim(mm_revert,oldstatus)
      if (parent.and.n_cg.gt.1) CALL FILECLOSE(40)
      if (parent.and.tqmmm.and.tddft) CALL FILEclose(41)
      CALL MY_SYNC(QMMMGRP)
#endif
      RETURN
      END
C     ==================================================================
      SUBROUTINE give_scr_mm_mddiag(LMDDIAG,TAG)
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
C     REAL*8    ALM(*),AFNL(*),BILN(*)
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
      if (tqmmm) lmddiag=max(lmddiag,kr1*kr2s*kr3s)
      if (tqmmm) lmddiag=max(lmddiag,nax*nsx*3)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
