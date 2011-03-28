C     ==================================================================
      SUBROUTINE UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                  RHOE,PSI,SCR,LSCR,
     &                  NSTATE,TFOR,TINFO,TSTRESS,NFR,THL,NHPSI)
C     ==--------------------------------------------------------------==
C     ==               UPDATES THE DENSITY                            ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'andr.inc'
      INCLUDE 'broy.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'norm.inc'
      INCLUDE 'ropt.inc'
      INCLUDE 'soft.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'sfac.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'ener.inc'        !ETOT,EHT,EEIG,EXC,VXC
      INCLUDE 'elct.inc'        !NEL
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'
      INCLUDE 'spin.inc'
      INCLUDE 'kpts.inc'
      INCLUDE 'kpnt.inc'
      INCLUDE 'store.inc'
      INCLUDE 'elct2.inc'
      INCLUDE 'kdp.inc'
      INCLUDE 'kdpc.inc'
      INCLUDE 'conv.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'vdwc.inc'
      INCLUDE 'tauf.inc'
      INCLUDE 'func.inc'
C     Arguments
      INTEGER    NSTATE,NFR,NHPSI,LSCR
      COMPLEX*16 C0(NGWK,NSTATE,NKPNT),C2(NGWK,NSTATE),
     &           CR(*),SC0(*),CSCR(*),PSI(NNR1)
      REAL*8     VPP(*),TAU0(3,NAX,NSX),FION(3,NAX,NSX),
     &           EIGV(NSTATE,NKPTS),RHOE(NNR1,NLSD),SCR(LSCR),THL(2)
      LOGICAL    TFOR,TINFO,TSTRESS
C     Variables
      REAL*8     TOLLPAR,BETAELMAX,EHFX,VHFX
      PARAMETER  (TOLLPAR=1.D-6,BETAELMAX=1.D33)
      DIMENSION  WK(NKPTS),F(NSTATE,NKPTS),
     &           RIN0(NNR1,NLSD),ROUT0(NNR1,NLSD),RMIX(NNR1,NLSD),
     &           EMK2(*)
      REAL*8     FNL(*),DFNL(*)
      REAL*8     DGIVE,DASUM,EDAV(*),DDRHO,TAU(*),VTAU(*),
     &           EEIG1,EEIG2,EBAND1,EBAND2,ENTROPY1,ENTROPY2
      EXTERNAL   DGIVE,DASUM
      CHARACTER  TAG*30
      LOGICAL    TREFINE,TADJMU
      INTEGER    IDAMAX,NNX,NNXS,KBEG,KEND,KINC,IKPT,NKPOINT,
     &           IKIND,IG,IKK,IB,I,IK,IMAX,NCONV,LUPDRHO,IBEG,IFIRST
      COMPLEX*16 CGS(NGWK,NSTATE)
      POINTER    (IP_CGS,CGS), (IP_EDAV,EDAV)
C
C     k.p arrays and variables (jk)
      integer    noccup,ikdp,istat
      DIMENSION  wkdp(nkdp),xkdp(3,nkdp),pkdp(3,nstate,nstate)
      DIMENSION  ekdp(nstate,nkdp),fkdp(nstate,nkdp),rauxdiag(3*nstate)
      DIMENSION  auxdiag(2*nstate),xlambda0(nstate,nstate)
      DIMENSION  ckdp(ngwk,nstate),akdp(nstate,nstate,nkdp)
      DIMENSION  bkdp(nstate,nstate,nkdp),brkdp(nstate,nstate)
      DIMENSION  xlambda(nstate,nstate),akdp2(nstate,nstate)
      DATA IFIRST/0/
      SAVE IFIRST,DDRHO 
C     ==--------------------------------------------------------------==
      IF(.NOT.TLANC .AND. TLSD .OR. MHFX.NE.0) THEN
        CALL MEMORY(IP_CGS,2*NGW*NSTATE,'CGS')
      ENDIF
C     ==--------------------------------------------------------------==
      IF(IFIRST.eq.0) THEN
        DDRHO = 1.0D0
        IFIRST = 1
      ENDIF
      CALL GIVE_SCR_UPDRHO(LUPDRHO,TAG,NSTATE,TFOR,TSTRESS)
      CALL TEST_SCR('UPDRHO',TAG,LSCR,LUPDRHO)
C     ==--------------------------------------------------------------==
C     == ALLOCATE ARRAYS FOR KDP ROUTINES                             ==
C     ==--------------------------------------------------------------==
      IF(TKDP.AND.IFIRST.EQ.0) THEN 
        IFIRST=1
        CALL MEMORY(IP_PKDP,3*NSTATE*NSTATE,'PKDP')
        CALL MEMORY(IP_EKDP,NSTATE*NKDP,'EKDP')
        CALL MEMORY(IP_FKDP,NSTATE*NKDP,'FKDP')
        CALL MEMORY(IP_XLAMBDA0,2*NSTATE*NSTATE,'XLAMBDA0')
        CALL MEMORY(IP_CKDP,2*NGWK*NSTATE,'CKDP')
        CALL MEMORY(IP_AKDP,2*NSTATE*NSTATE*NKDP,'AKDP')
        CALL MEMORY(IP_BKDP,2*NSTATE*NSTATE*NKDP,'BKDP')
        CALL MEMORY(IP_BRKDP,2*NSTATE*NSTATE,'BRKDP')
        CALL MEMORY(IP_XLAMBDA,2*NSTATE*NSTATE,'XLAMBDA')
        CALL MEMORY(IP_AKDP2,2*NSTATE*NSTATE,'AKDP2')
        CALL MEMORY(IP_AUXDIAG,2*2*NSTATE,'AUXDIAG')
        CALL MEMORY(IP_RAUXDIAG,3*NSTATE,'RAUXDIAG')
      ENDIF 
      NNX=NNR1*NLSD
C     Copy density to scratch space used in VOFRHO
      CALL DCOPY(NNX,RIN0(1,1),1,RHOE(1,1),1)
      CALL AZZERO(FION,3*NAX*NSX)
      CALL RPIIINT(ESR,TAU0,FION,IESR,TFOR)
C     ==--------------------------------------------------------------==
      IF(.NOT.TLANC) CALL MEMORY(IP_EDAV,NDAVV,'EDAV')
      IF(TKPNT.AND. TDAVI) CALL STOPGM("UPDRHO",
     &         "DAVIDSON AND K-POINTS NOT IMPLEMENTED")
C     ==--------------------------------------------------------------==
C     == Calculate the Stress Tensor                                  ==
C     ==--------------------------------------------------------------==
      IF(TSTRESS) CALL STRESS(C0,TAU0,F,PSI,SCR,LSCR,NSTATE)
C     Calculate Potential
      IF(TFOR) CALL EBACK(0)
      CALL VOFRHO(TAU0,FION,RHOE,PSI,SCR,LSCR,TFOR,TSTRESS)
      IF(TFOR) CALL EBACK(1)
C     ==--------------------------------------------------------------==
C     == Force on the ions from nonlocal pseudopotential              ==
C     ==--------------------------------------------------------------==
      IF(TFOR) THEN
        CALL INQ_SWAP(KBEG,KEND,KINC)
        DO IKPT=KBEG,KEND,KINC
          NKPOINT=NKPBL(IKPT)
          IF(TKBLOCK) CALL RKPT_SWAP(C0,NSTATE,IKPT,
     &         'HGKP HGKM MASKGW EIGKR TWNL C0')
          DO IKIND=1,NKPOINT
            CALL RNLSM(C0(1,1,IKIND),NSTATE,PSI,SCR,LSCR,
     &             IKPT,IKIND,.TRUE.)
            IF(.NOT.TBOGO) THEN
              CALL HPSI(C0(1,1,IKIND),C2,SC0,
     &             RHOE,PSI,SCR,LSCR,NSTATE,IKIND,NLSD)
C             ,.TRUE.,TSTRESS
            ENDIF
          ENDDO
C         ENL: Non-local PP energy
          CALL RNLRH(ENL,NSTATE,NKPTS)
          CALL RNLFOR(FION,F(1,KPBEG(IKPT)+1),WK(KPBEG(IKPT)+1),
     &         NSTATE,NKPOINT)
        ENDDO
#ifdef PARALLEL
        CALL GLOSUM(3*NAX*NSX,FION)
#endif
      ENDIF
C     ==--------------------------------------------------------------==
C     == Energy and force on the ions from van der Waals interaction  ==
C     ==--------------------------------------------------------------==
      EVDW=0.D0
      IF(VDWC) CALL VDW(TAU0,NVDW,IDVDW,IVDW,JVDW,VDWST,VDWRM,VDWBE,
     &                  VDWEPS,NXVDW,NYVDW,NZVDW,EVDW,FION,DEVDW)
C       Symmetrize forces (if needed).
C       With special k-points (and point group specified)
C       we symmetrize RHO.
      IF(TSYMRHO) CALL SYMVEC(FION,SCR,LSCR)
C     ==--------------------------------------------------------------==
      IF(CONVWF.AND..NOT.TDIAGOPT) RETURN
C     ==--------------------------------------------------------------==
      IF(TTROT) THEN
        CALL EPOT(RHOE) 
        IF(TDAVI) THEN
          CALL KSDIAG(VPP)
!$OMP parallel do private(IG)
          DO IG=1,NGW
            VPP(IG)=DEXP(BETAP*VPP(IG))
          ENDDO
        ENDIF
      ELSE
        IF(TFINT) CALL DCOPY(NSTATE*NKPTS,1.D0,0,F(1,1),1)
        IF(TDAVI) CALL KSDIAG(VPP)
      ENDIF
      EEIG=0.D0
C     ==--------------------------------------------------------------==
C     == Loop over k points                                           ==
C     ==--------------------------------------------------------------==
      IF(DIIS.AND..NOT.TDIAGOPT) THEN
          CALL K_DIIS_RHOFIX(C0,C2,SC0,TAU0,FION,
     &         CSCR,CR,VPP,EIGV,RHOE,PSI,SCR,LSCR,
     &         NSTATE,TFOR,DDRHO)
      ELSE
        CALL INQ_SWAP(KBEG,KEND,KINC)
        DO IKPT=KBEG,KEND,KINC
          NKPOINT=NKPBL(IKPT)
          IF(TKBLOCK) THEN
            IF(TTROT) THEN
              CALL RKPT_SWAP(C0,NSTATE,IKPT,
     &             'HGKP HGKM MASKGW TWNL EMK2 EIGKR ALM C0')
            ELSE
              CALL RKPT_SWAP(C0,NSTATE,IKPT,
     &           'HGKP HGKM MASKGW TWNL EIGKR C0')
            ENDIF
          ENDIF
          DO IKIND = 1, NKPOINT
            IKK=KPBEG(IKPT)+IKIND
            IF(TTROT) CALL VBETA(RHOE,PSI,IKIND)
            IF(TLSD) THEN
              IF(TLANC) THEN
                IF(TKPNT) THEN 
                  CALL FRIESNER_C(NSUP,DBLE(NSUP),NCONV,NHPSI,
     &                C0(1,1,IKIND),C2,SC0,CSCR,
     &               RHOE(1,1),PSI,EIGV(1,IKK),SCR,LSCR,
     &               1,IKIND,IKK,TREFINE,TINFO)
                ELSE
                  IF(MHFX.NE.0) CALL DCOPY(2*NGW*NSTATE,C0,1,CGS,1)
                  IF (TDMAL) THEN
                     CALL DIST_FRIESNER(NSUP,DBLE(NSUP),
     &               NCONV,NHPSI,NSUP,
     &               C0,C2,SC0,CSCR,CGS,F,
     &               RHOE(1,1),PSI,EIGV,SCR,LSCR,
     &               1,TREFINE,TINFO)
                  ELSE
                     CALL FRIESNER(NSUP,DBLE(NSUP),
     &               NCONV,NHPSI,NSUP,
     &               C0,C2,SC0,CSCR,CGS,F,
     &               RHOE(1,1),PSI,EIGV,SCR,LSCR,
     &               1,TREFINE,TINFO)
                  ENDIF
                  NAC=NCONV
                ENDIF
              ELSEIF(TDAVI)THEN
                CALL DCOPY(2*NGW*NSTATE,C0,1,CGS,1)
                CALL DAVIDSON(NSUP,NDAVV,C0,C2,CR,SC0,CSCR,
     &             RHOE(1,1),CGS,F,NSUP,PSI,EDAV,VPP,SCR,LSCR)
                CALL DCOPY(2*NGW*NSUP,C0,1,CGS,1)
                CALL DCOPY(NSUP,EDAV,1,EIGV(1,IKK),1)
              ENDIF
              IB = NSUP+1
              ITAUR=2
              IF(TLANC) THEN
                IF(TKPNT) THEN
                  CALL FRIESNER_C(NSDOWN,DBLE(NSDOWN),NCONV,NHPSI,
     &               C0(1,IB,IKIND),C2(1,IB),SC0,CSCR,
     &               RHOE(1,2),PSI,EIGV(IB,IKK),SCR,LSCR,
     &               2,IKIND,IKK,TREFINE,TINFO)
                ELSE
                  IF (TDMAL) THEN 
                     CALL DIST_FRIESNER(NSDOWN,
     &                       DBLE(NSDOWN),NCONV,NHPSI,NSDOWN,
     &                       C0(1,IB,1),C2(1,IB),SC0,CSCR,
     &                       CGS(1,IB),F(IB,1),
     &                       RHOE(1,2),PSI,EIGV(IB,1),SCR,
     &                       LSCR,2,TREFINE,TINFO)
                  ELSE
                     CALL FRIESNER(NSDOWN,
     &                       DBLE(NSDOWN),NCONV,NHPSI,NSDOWN,
     &                       C0(1,IB,1),C2(1,IB),SC0,CSCR,
     &                       CGS(1,IB),F(IB,1),
     &                       RHOE(1,2),PSI,EIGV(IB,1),SCR,
     &                       LSCR,2,TREFINE,TINFO)
                  ENDIF
                  NBC=NCONV
                ENDIF
              ELSEIF(TDAVI)THEN
                CALL DCOPY(2*NGW*NSDOWN,CGS(1,IB),1,C0,1)
                CALL DAVIDSON(NSDOWN,NDAVV,C0,C2,CR,SC0,CSCR,RHOE(1,2),
     &             CGS(1,IB),F(IB,1),NSDOWN,PSI,EDAV,VPP,SCR,LSCR)
                CALL DCOPY(2*NGW*NSDOWN,C0,1,CGS(1,IB),1)
                CALL DCOPY(NSDOWN,EDAV,1,EIGV(IB,IKK),1)
                CALL DCOPY(2*NGW*NSTATE,CGS,1,C0,1)
              ENDIF
              ITAUR=1
            ELSE
              IF(TLANC) THEN
                IF(TKPNT) THEN 
                  IF(.NOT.TFRSBLK) THEN
                    IF(TONLYDIAG) THEN
                      CALL FRIE_C_p(NSTATE,NEL,NCONV,NHPSI,
     &                 C0(1,1,IKIND),C2,SC0,CSCR,RHOE,PSI,
     &                 EIGV(1,IKK),SCR,LSCR,
     &                 0,IKIND,IKK,TREFINE,TINFO) 
                    ELSE
                      CALL FRIESNER_C(NSTATE,NEL,NCONV,NHPSI,
     &                 C0(1,1,IKIND),C2,SC0,CSCR,RHOE,PSI,
     &                 EIGV(1,IKK),SCR,LSCR,
     &                 0,IKIND,IKK,TREFINE,TINFO)
                    ENDIF
                  ELSE
                    CALL FRSBLK_C(NSTATE,NEL,NCONV,NHPSI,
     &                 C0(1,1,IKIND),C2,SC0,CSCR,RHOE,PSI,
     &                 EIGV(1,IKK),SCR,LSCR,
     &                 0,IKIND,IKK,TREFINE,TINFO)
                  ENDIF
                ELSE
                  IF(.NOT.TFRSBLK) THEN
                    IF(MHFX.NE.0) CALL DCOPY(2*NGW*NSTATE,C0,1,CGS,1)
                    IF (TDMAL) THEN 
                       CALL DIST_FRIESNER(NSTATE,NEL,NCONV,NHPSI,NSTATE,
     &                   C0,C2,SC0,CSCR,CGS,F,RHOE,PSI,EIGV,SCR,LSCR,
     &                   0,TREFINE,TINFO)
                    ELSE
                       CALL FRIESNER(NSTATE,NEL,NCONV,NHPSI,NSTATE,
     &                   C0,C2,SC0,CSCR,CGS,F,RHOE,PSI,EIGV,SCR,LSCR,
     &                   0,TREFINE,TINFO)
                    ENDIF
                  ELSE
                    CALL FRSBLK(NSTATE,NEL,NCONV,NHPSI,
     &                 C0,C2,SC0,CSCR,RHOE,PSI,EIGV,SCR,LSCR,
     &                 0,TREFINE,TINFO)
                  ENDIF
                  NAC=NCONV
                ENDIF
              ELSE
C CGS is only needed for HF
                IF(MHFX.NE.0) CALL DCOPY(2*NGW*NSTATE,C0,1,CGS,1)
                CALL DAVIDSON(NSTATE,NDAVV,C0,C2,CR,SC0,CSCR,RHOE,
     &             CGS,F,NSTATE,PSI,EIGV,VPP,SCR,LSCR)
              ENDIF
            ENDIF
C           Check memory
            CALL MEMORY_CHECK()
          ENDDO                   !  LOOP OVER IKIND
          IF(TKBLOCK) THEN
            CALL WKPT_SWAP(C0,NSTATE,IKPT,'C0')
          ENDIF
        ENDDO                     ! LOOP OVER IKPT
      ENDIF
C     ==--------------------------------------------------------------==
C     == End loop over kpoints                                        ==
C     ==--------------------------------------------------------------==
C     ==--------------------------------------------------------------==
C     == Solve K.P eigenvalue equations                               ==
C     ==--------------------------------------------------------------==
      if(tkdp.and..not.tlsd) then
c
c     1) Compute < c_i | p | c_j > and <c_i| H |c_j> matrix elements
        call kdp_prep(nkdp,c0,nstate,pkdp,xlambda0,ckdp,rhoe,psi,
     c                scr,lscr,betap,eigv)

c     2) Solve the eigenvalue equations: eigenvalues in ekdp and
c        eigenvectors in akdp.
        call kdp_diag(nstate,pkdp,xlambda0,xkdp,nkdp,ekdp,akdp,
     c                noccup,auxdiag,rauxdiag)

c     3) Adjust chemical potential and find occupation numbers.
        CALL ADJMU(NSTATE,NKDP,NEL,BETAEL,EKDP,WKDP,TLSD,AMU,TADJMU)
        CALL OCCUP(EKDP,WKDP,AMU,BETAEL,FKDP,NSTATE,NKDP,NEL,TLSD)
c
c     4) Calculate the band energy
        CALL ENERT(EKDP,WKDP,AMU,FKDP,BETAEL,
     &             NSTATE,NSTATE,NKDP,NEL,TLSD,
     &             EEIG,EBAND,ENTROPY)
c
c     5) Calculate output density
        call kdp_rho(nkdp,c0,ckdp,rhoe,psi,scr,lscr,nstate,
     .               akdp,noccup,bmix,fkdp,wkdp,bkdp)
c
        goto 1111
      endif
C     ==--------------------------------------------------------------==
C     ==--------------------------------------------------------------==
C     Calculate occupation numbers
      IF(TTROT) THEN
        DO IKIND=1,NKPTS
          DO I=1,NSTATE
            EIGV(I,IKIND)=-DLOG(EIGV(I,IKIND))/BETAP
          ENDDO
        ENDDO
      ENDIF
      TADJMU=.FALSE.
      IF(TFIXO) THEN
        AMU=EIGV(NSTATE,1)
      ELSEIF(TLSD.AND.TFXSP) THEN
C..for fixed spin, get amu and f of each spin species
C..prepare eigenvalues in scr array
C..alpha spin
        DO IK=1,NKPTS
          CALL DCOPY(NSUP,EIGV(1,IK),1,SCR((IK-1)*NSUP+1),1)
        ENDDO
        CALL ADJMU(NSUP,NKPTS,DBLE(NUPEL),BETAEL,SCR,WK,
     &             TLSD,AMUUP,TADJMU)
        CALL OCCUP(SCR,WK,AMUUP,BETAEL,SCR(NSUP*NKPTS+1),NSUP,NKPTS,
     &       DBLE(NUPEL),TLSD)
        IBEG=NSUP*NKPTS+1
        DO IK=1,NKPTS
          CALL DCOPY(NSUP,SCR(IBEG+(IK-1)*NSUP),1,F(1,IK),1)
        ENDDO
C..beta spin
        DO IK=1,NKPTS
          CALL DCOPY(NSDOWN,EIGV(1+NSUP,IK),1,SCR((IK-1)*NSDOWN+1),1)
        ENDDO
        CALL ADJMU(NSDOWN,NKPTS,DBLE(NDOEL),BETAEL,SCR,WK,
     &             TLSD,AMUDO,TADJMU)
        CALL OCCUP(SCR,WK,AMUDO,BETAEL,SCR(NSDOWN*NKPTS+1),
     &       NSDOWN,NKPTS,DBLE(NDOEL),TLSD)
        IBEG=NSDOWN*NKPTS+1
        DO IK=1,NKPTS
          CALL DCOPY(NSDOWN,SCR(IBEG+(IK-1)*NSDOWN),1,F(NSUP+1,IK),1)
        ENDDO
      ELSE
        CALL ADJMU(NSTATE,NKPTS,NEL,BETAEL,EIGV,WK,TLSD,AMU,TADJMU)
        CALL OCCUP(EIGV,WK,AMU,BETAEL,F,NSTATE,NKPTS,NEL,TLSD)
      ENDIF

C     Check if the number of states is sufficient.
      IF(PARENT.AND.TFINT.AND.BETAEL.LT.BETAELMAX) THEN
        DO IKIND=1,NKPTS
          IF(TLSD) THEN
            IF(F(NSUP,IKIND).GT.TOLLPAR) THEN
              WRITE(6,'(1X,64("!"))')
              WRITE(6,'(" !!",A,T64,"!!")')
     &             ' UPDRHO| THE NUMBER OF ALPHA STATES IS TOO SMALL'
              WRITE(6,'(" !!",A,I4,A,I3,A,1PE15.5,T64,"!!")')
     &             '         F(',NSUP,',',IKIND,') =',F(NSUP,IKIND)
              WRITE(6,'(1X,64("!"))')
            ENDIF
            IF(F(NSTATE,IKIND).GT.TOLLPAR) THEN
              WRITE(6,'(1X,64("!"))')
              WRITE(6,'(" !!",A,T64,"!!")')
     &             ' UPDRHO| THE NUMBER OF BETA STATES IS TOO SMALL'
              WRITE(6,'(" !!",A,I4,A,I3,A,1PE15.5,T64,"!!")')
     &             '         F(',NSDOWN,',',IKIND,') =',
     &             F(NSTATE,IKIND)
              WRITE(6,'(1X,64("!"))')
            ENDIF
          ELSE
            IF(F(NSTATE,IKIND).GT.TOLLPAR) THEN
              WRITE(6,'(1X,64("!"))')
              WRITE(6,'(" !!",A,T64,"!!")')
     &             ' UPDRHO| THE NUMBER OF STATES IS TOO SMALL'
              WRITE(6,'(" !!",A,I4,A,I3,A,1PE15.5,T64,"!!")')
     &             '         F(',NSTATE,',',IKIND,') =',
     &             F(NSTATE,IKIND)
              WRITE(6,'(1X,64("!"))')
            ENDIF
          ENDIF
        ENDDO
      ENDIF
C     Calculate free electron energy, band energy and kt*entropy.
      IF(TLSD.AND.TFXSP) THEN
        CALL ENERT(EIGV,WK,F,AMUUP,BETAEL,
     &             NSUP,NSTATE,NKPTS,DBLE(NUPEL),.TRUE.,
     &             EEIG1,EBAND1,ENTROPY1)
        CALL ENERT(EIGV(1+NSUP,1),WK,F(1+NSUP,1),AMUDO,BETAEL,
     &             NSDOWN,NSTATE,NKPTS,DBLE(NDOEL),.TRUE.,
     &             EEIG2,EBAND2,ENTROPY2)
        EEIG=EEIG1+EEIG2
        EBAND=EBAND1+EBAND2
        ENTROPY=ENTROPY1+ENTROPY2
      ELSE
C       Calculate free band energy.
        CALL ENERT(EIGV,WK,F,AMU,BETAEL,NSTATE,NSTATE,NKPTS,NEL,TLSD,
     &             EEIG,EBAND,ENTROPY)
C       IF Fixed occupation numbers EEIG is not correct.
        IF(TFIXO) EEIG = EBAND
      ENDIF
C     Calculate output density
      IF(TIVAN) THEN
        CALL RNLSM(C0,NSTATE,PSI,SCR,LSCR,1,1,.FALSE.)      
      ENDIF
      IF(TKPNT) THEN
        CALL RHOOFR_C(C0,RHOE,PSI,SCR,LSCR,NSTATE)
      ELSE
        CALL RHOOFR(C0,RHOE,PSI,SCR,LSCR,NSTATE)
      ENDIF
c
c From k.p
1111  continue
      CALL DCOPY(NNX,RHOE(1,1),1,ROUT0(1,1),1)
c
C     Total Energy summation
#ifdef PARALLEL
C     Sum over EKIN (cal. in RHOOFR), EPSEU, ENL (unused)
C     EHT, EHEI, EHEE, EHEP, EXC, VXC, EGC )
      CALL GLOSUM(10,EKIN)
#endif
C     Hartree-Fock contribution to energy
      CALL HFX(C0,C2,F,PSI,NSTATE,EHFX,VHFX)
      EXC=EXC-EHFX
C     If you want to have non-local pp contribution
C     CALL RNLRH(ENL,NSTATE,NKPTS)
      ETOT=EEIG+(EXC-VXC)+EHT
     .    +EVDW ! Empirical van der Waals correction
C     Check for convergence
      CALL DCOPY(NNX,ROUT0(1,1),1,RMIX(1,1),1)
      CALL DAXPY(NNX,-1.0D0,RIN0(1,1),1,RMIX(1,1),1)
      IMAX=IDAMAX(NNX,RMIX(1,1),1)
      GEMAX=ABS(DGIVE(RMIX(1,1),IMAX))
      CNORM=DASUM(NNX,RMIX(1,1),1)
#ifdef PARALLEL
      CALL GLOSUM(1,CNORM)
      CALL GLOMAX(1,GEMAX)
      NNXS=KR1S*KR2S*KR3S
#else
      NNXS=NNX
#endif
      GEMAX=DSQRT(OMEGA*GEMAX/NNXS)
      CNORM=OMEGA*CNORM/NNXS
      DDRHO=GEMAX
C     Check if soft exit
      IF(.NOT.EXSOFT) CALL TESTEX(EXSOFT)
      IF(GEMAX.LT.TOLOG .OR. EXSOFT .OR. KSENER) THEN
        CONVWF=.TRUE.
C       Check if B2MAX is not too small (T.D.)
        IF(TLANC) THEN
          IF(NFR.EQ.1.AND.NTABTROT.GT.1.AND.B2LIMIT.GT.1.D-8) THEN
            IF(.NOT.EXSOFT) THEN
              IF(PARENT) THEN
                 WRITE(6,'(1X,64("!"))')
                 WRITE(6,'(" !!",A,T64,"!!")')
     &                  ' UPDRHO| B2MAX IS VERY HIGH'
                 WRITE(6,'(" !!",A,T64,"!!")')
     &           ' UPDRHO| DOUBT ON CONVERGENCE. WE TRY ONCE AGAIN'
                 WRITE(6,'(1X,64("!"))')
              ENDIF
              CONVWF=.FALSE.
            ENDIF
          ENDIF
        ENDIF
C       Calculate Bogoliubov correction
        IF(TBOGO.AND.TTROT) THEN
          CALL DCOPY(NNX,RIN0(1,1),1,RHOE(1,1),1)
          CALL EBACK(0)
          CALL VOFRHO(TAU0,FION,RHOE,PSI,SCR,LSCR,TFOR,.FALSE.)
          CALL EBACK(1)
          CALL BOGOL(C0,C2,SC0,EIGV,F,RHOE,PSI,
     &               SCR,LSCR,NSTATE,EBOGO)
          ETOT=ETOT+EBOGO
        ENDIF
      ENDIF
      IF(TONLYDIAG) THEN
        CONVWF=.TRUE.
      ENDIF
C     Change b2limit if needed
      IF(TLANC) THEN
         CALL CHANGE_B2L(GEMAX,TREFINE)
      ENDIF
C     Change Betap if needed
      IF(TTROT) THEN
        CALL CHANGE_BETAP(GEMAX,TREFINE)
      ENDIF
C     ==--------------------------------------------------------------==
      IF(.NOT.TLANC) THEN
        CALL FREEM(IP_EDAV)
      ENDIF
      IF(.NOT.TLANC.AND.TLSD) THEN
        CALL FREEM(IP_CGS)
      ENDIF
C     ==--------------------------------------------------------------==
C     == Density mixing                                               ==
C     ==--------------------------------------------------------------==
      IF(TGMIX) THEN
        CALL MIXING_G(NFR,GEMAX,RIN0,ROUT0,RMIX,PSI,SCR,LSCR,THL)
      ELSE
        CALL MIXING_R(NFR,GEMAX,RIN0,ROUT0,RMIX,SCR,LSCR,THL)
      ENDIF
      CALL DCOPY(NNX,RMIX(1,1),1,RIN0(1,1),1)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_UPDRHO(LUPDRHO,TAG,NSTATE,TFOR,TSTRESS)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !TLANC NDAVV
      INCLUDE 'kpts.inc'        !TKPNT
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'        !TTROT TBOGO
      INCLUDE 'pslo.inc'        !TIVAN
C     Arguments
      INTEGER   LUPDRHO,NSTATE
      LOGICAL   TFOR,TSTRESS
      CHARACTER TAG*30
C     Variables
      INTEGER   LVOFRHO,LRNLSM,LSYMVEC,LSCRDIAG,LRHOOFR,LPTHEORY,
     &          LBOGOL,LSTRESS,LMIXING,LRHOFIX,LHPSI
C     ==--------------------------------------------------------------==
      LSCRDIAG=0
      CALL GIVE_SCR_VOFRHO(LVOFRHO,TAG)
      IF(TFOR) THEN
        CALL GIVE_SCR_RNLSM(LRNLSM,TAG,NSTATE,TFOR)
        CALL GIVE_SCR_SYMVEC(LSYMVEC,TAG)
      ELSE
        LRNLSM=0
        LSYMVEC=0
      ENDIF
      IF(TSTRESS) THEN
        CALL GIVE_SCR_STRESS(LSTRESS,TAG)
      ELSE
        LSTRESS=0
      ENDIF
      LRHOFIX=0
      IF(TLANC) THEN
        IF(.NOT.TFRSBLK) THEN
          IF (TDMAL) THEN
            CALL GIVE_SCR_DIST_FRIESNER(LSCRDIAG,TAG,NSTATE)
          ELSE
            CALL GIVE_SCR_FRIESNER(LSCRDIAG,TAG,NSTATE)
          ENDIF
        ELSE
          IF(TKPNT) THEN
            CALL GIVE_SCR_FRSBLK_C(LSCRDIAG,TAG,NSTATE)
          ELSE
            CALL GIVE_SCR_FRSBLK(LSCRDIAG,TAG,NSTATE)
          ENDIF
        ENDIF
      ELSEIF(TDAVI) THEN
        CALL GIVE_SCR_DAVIDSON(LSCRDIAG,TAG,NSTATE,NDAVV)
      ELSEIF(DIIS) THEN
        CALL GIVE_SCR_KFORCES(LRHOFIX,TAG,NSTATE,.true.,TFOR)
      ENDIF
      IF(TIVAN) CALL GIVE_SCR_RNLSM(LRNLSM,TAG,NSTATE,.FALSE.)
      CALL GIVE_SCR_RHOOFR(LRHOOFR,TAG)
      LHPSI=0
      IF(TBOGO) THEN
        CALL GIVE_SCR_BOGOL(LBOGOL,TAG,NSTATE)
      ELSE
        LBOGOL=0
        IF(TFOR)  CALL GIVE_SCR_HPSI(LHPSI,TAG,NSTATE)
      ENDIF
      CALL GIVE_SCR_PTHEORY(LPTHEORY,TAG,NSTATE)
      CALL GIVE_SCR_MIXING(LMIXING,TAG)
      LUPDRHO=MAX(LVOFRHO,LRNLSM,LSYMVEC,LSTRESS,LRHOFIX,
     &            LSCRDIAG,LRHOOFR,LBOGOL,LHPSI,LPTHEORY,LMIXING)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
