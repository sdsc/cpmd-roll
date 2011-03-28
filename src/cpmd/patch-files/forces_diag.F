C     ==================================================================
      SUBROUTINE FORCES_DIAG(NSTATE,C0,C2,CR,SC0,CSCR,VPP,EIGV,
     &                       RHOE,PSI,SCR,LSCR,
     &                       TAU0,VELP,TAUI,FION,IFCALC,
     &                       IREC,TFOR,TINFO)
C     ==--------------------------------------------------------------==
C     == ENTER WITH THE IONIC POSITIONS IN TAU0 AND AN INPUT GUESS    ==
C     == FOR THE DENSITY IN RIN0, THIS ROUTINE RETURNS THE CONVERGED  ==
C     == DENSITY, WAVEFUNCTIONS AND IONIC FORCES.                     ==
C     ==--------------------------------------------------------------==
C     == TAU0: ATOMIC POSITION                                        ==
C     == VELP and TAUI are necessary for RESTART FILE                 ==
C     == FION: IONIC FORCES                                           ==
C     == IFCALC: total number of iterations                           ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'spin.inc'        !NLSD
      INCLUDE 'elct.inc'
      INCLUDE 'ener.inc'
      INCLUDE 'norm.inc'
      INCLUDE 'ropt.inc'        !CALSTE,SDIIS,INFI
      INCLUDE 'andr.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'soft.inc'
      INCLUDE 'cotr.inc'
      INCLUDE 'tpar.inc'
      INCLUDE 'store.inc'
      INCLUDE 'elct2.inc'       !TFIXO
      INCLUDE 'kpts.inc'
      INCLUDE 'mm_extrap.inc'   !NUMCOLD
C     Arguments
      INTEGER    NSTATE,IFCALC,IREC(100),LSCR
      COMPLEX*16 C0(*),C2(*),CR(*),SC0(*),CSCR(*),PSI(NNR1)
      REAL*8     EIGV(*),TAU0(*),VELP(*),TAUI(*),FION(*),VPP(*),
     &           RHOE(NNR1,NLSD),SCR(LSCR),THL(2)
      LOGICAL    TFOR,TINFO
C     Variables
      CHARACTER TAG*30
      REAL*8    TIME1,TIMEF,ETOT0,DETOT,TIME2,TCPU
      EXTERNAL  TIMEF
      INTEGER   I,INFR,NHPSI,LFORCES_DIAG,MSGLEN
C     ==--------------------------------------------------------------==
      CALL GIVE_SCR_FORCES_DIAG(LFORCES_DIAG,TAG,NSTATE,TFOR)
      CALL TEST_SCR('FORCES_DIAG',TAG,LSCR,LFORCES_DIAG)
C     ==--------------------------------------------------------------==
      CONVWF=.FALSE.
      ETOT0=0.0D0
      IF(TDIAG.AND.TLANC) THEN
        CALL SET_B2L()
      ENDIF
C     ==--------------------------------------------------------------==
      IF(TDIAG) THEN
        IF(.NOT.TINFO.AND.PARENT) THEN
           WRITE(6,'(T9,A)')
     &     'INFR       DRHOMAX        ETOT       DETOT   HPSI    TCPU'
        ENDIF
      ELSE
        IF(.NOT.TINFO.AND.PARENT) THEN
          WRITE(6,'(T9,A)')
     &    'INFR         GEMAX            ETOT         DETOT     TCPU'
        ELSEIF(PARENT) THEN
          WRITE(6,'(2A)') ' NFI      GEMAX       CNORM',
     *    '           ETOT        DETOT      TCPU'
        ENDIF
        SDIIS=.TRUE.
        SPCG=.TRUE.
      ENDIF
C     ==================================================================
C     ==                        MAIN  LOOP                            ==
C     ==================================================================
      DO INFR=1,NOMORE_ITER
        TIME1=TIMEF()
        IFCALC=IFCALC+1
C       Diagonalization
        IF(TDIAG) THEN
          CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                RHOE,PSI,SCR,LSCR,
     &                NSTATE,.FALSE.,TINFO,.FALSE.,INFR,THL,NHPSI)
        ELSE
          IF(TKPNT) THEN
             CALL  K_UPDWF(C0,C2,SC0,TAU0,FION,CR,CSCR,VPP,EIGV,
     &                     RHOE,PSI,SCR,LSCR,NSTATE,.FALSE.,INFR)
          ELSE

             CALL UPDWF(C0,C2,SC0,TAU0,FION,CR,CSCR,VPP,EIGV,
     &                  RHOE,PSI,SCR,LSCR,NSTATE,.FALSE.,.TRUE.)
          ENDIF
        ENDIF
C       Printout the evolution of the iterative optimization
        IF(PARENT) THEN
          DETOT=ETOT-ETOT0
          IF(INFR.EQ.1) DETOT=0.0D0
          TIME2=TIMEF()
          TCPU=(TIME2-TIME1)*0.001D0
          IF(TINFO) THEN
            I=-1
            IF (TDIAG) I=INFR
            CALL WRPRINT_WFOPT(EIGV,F,AMU,NSTATE,ETOT,ETOT0,
     &         TCPU,GEMAX,CNORM,THL,.FALSE.,IFCALC,I)
          ELSEIF(TDIAG) THEN
            WRITE(6,
     &           '(T9,I4,T15,1PE12.3,T27,0PF12.6,T39,1PE12.3,'//
     &           'T53,0PF5.2,T59,0PF7.2) ')
     &           INFR,GEMAX,ETOT,DETOT,NHPSI/DBLE(NSTATE),TCPU
          ELSE
            WRITE(6,
     &       '(T9,I4,T15,1PE12.3,T31,0PF12.6,T45,1PE12.3,T59,0PF7.2) ')
     &       INFR,GEMAX,ETOT,DETOT,TCPU
          ENDIF
          ETOT0=ETOT
        ENDIF
        IF(MOD(IFCALC,ISCTORE).EQ.0)
     &       CALL ZHWWF(2,IREC,C0,C2,NSTATE,EIGV,TAU0,VELP,TAUI,NFI)
C       Check to break the loop.
        IF(.NOT.EXSOFT) CALL TESTEX(EXSOFT)
        IF(EXSOFT) GOTO 200     !Soft Exit (no force calculation)
        IF(CONVWF) GOTO 100
C     ==--------------------------------------------------------------==
C     special case for ASPC extrapolator with CSTEPS flag. once we have 
C     a full wavefunction history, we don't converge out but use the
C     specified number of corrector steps. 
C     for the first wavefunction during init we have TINFO=.TRUE. .
C     that one is not taken from the history and may no be converged,
C     we have to converge that one in full.
        IF(TASPC.AND.(NASPC.GT.0)) THEN
          IF(.NOT.TINFO) THEN
            IF((INFR.GE.NASPC).AND.(NUMCOLD.GE.MEXTRA)) GOTO 100
          ENDIF
        ENDIF
C     ==--------------------------------------------------------------==
      ENDDO
C     ==================================================================
C     ==                      END OF MAIN  LOOP                       ==
C     ==================================================================
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
  100 CONTINUE
C     ==            DIAGONALIZATION FOLLOWING OPTIMIZATION            ==
      IF(TDIAGOPT) THEN
        TDIAG=.TRUE.
        TFIXO=.TRUE.
        CALL DENS_FOR_DIAG(C0,RHOE,PSI,SCR,LSCR,NSTATE)
        CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &              RHOE,PSI,SCR,LSCR,
     &              NSTATE,TFOR,TINFO,CALSTE,INFR,THL,NHPSI)
        SDIIS=.TRUE.
        TDIAG=.FALSE.
      ENDIF
C     ==    IF WE NEED FORCES AND DON'T HAVE THEM YET, GET THEM NOW   ==
      IF(TFOR) THEN
        IF(TDIAG) THEN
C         Diagonalization
          CALL AZZERO(FION,3*NAX*NSX)
          CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                RHOE,PSI,SCR,LSCR,
     &                NSTATE,.TRUE.,TINFO,CALSTE,INFR,THL,NHPSI)
C     Forces from geometrical restraints
          IF(PARENT) THEN
            DO I=1,MRESTR
              RESVAL(I)=RESVAL(I)+GSRATE(I)*DT_IONS
            ENDDO
            CALL RESTFC(TAU0,SCR,FION)
          ENDIF
        ELSE
          CALL AZZERO(FION,3*NAX*NSX)
          IF(TKPNT) THEN
             INFR=INFR+1
             CONVWF=.FALSE.
             CALL  K_UPDWF(C0,C2,SC0,TAU0,FION,CR,CSCR,VPP,EIGV,
     &                     RHOE,PSI,SCR,LSCR,NSTATE,.TRUE.,INFR)
             CONVWF=.TRUE.
C     Forces from geometrical restraints
          IF(PARENT) THEN
            DO I=1,MRESTR
              RESVAL(I)=RESVAL(I)+GSRATE(I)*DT_IONS
            ENDDO
            CALL RESTFC(TAU0,SCR,FION)
          ENDIF
          ELSE
             CALL FORCEDR(C0,C2,SC0,RHOE,PSI,TAU0,FION,EIGV,
     &                    SCR,LSCR,NSTATE,1,.TRUE.,TFOR)
          ENDIF
C     AK: NOTE: Restraints are already treated in FORCEDR()
        ENDIF
        MSGLEN = 3*NAX*NSX * 8
        CALL MY_BCAST(FION,MSGLEN,SOURCE,ALLGRP)
      ENDIF
 200  CONTINUE
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE UPDIAG(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                  RHOE,PSI,SCR,LSCR,NSTATE,IFCALC,TFOR,TINFO,
     &                  TIME1,ETOT0)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'spin.inc'        !NLSD
      INCLUDE 'elct.inc'
      INCLUDE 'ener.inc'
      INCLUDE 'norm.inc'
      INCLUDE 'ropt.inc'        !CALSTE,SDIIS,NDISRS
      INCLUDE 'andr.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'soft.inc'
      INCLUDE 'store.inc'
      INCLUDE 'elct2.inc'
C     Arguments
      LOGICAL    TFOR,TINFO
      INTEGER    LSCR,NSTATE,IFCALC
      COMPLEX*16 C0(*),C2(*),CR(*),SC0(*),CSCR(*),PSI(*)
      REAL*8     VPP(*),TAU0(*),FION(*),EIGV(*),RHOE(*),SCR(LSCR),
     &           TIME1,ETOT0
C     Local variables
      LOGICAL    TDODIAG
      INTEGER    NHPSI
      REAL*8     DETOT,TCPU,THL(2),TIME2,TIMEF
      EXTERNAL   TIMEF
C     ==--------------------------------------------------------------==
C     Determine if we do diagonalization this time
      TDODIAG = .FALSE.
      IF (NPERID.GT.0 .AND. NRPERI.EQ.0) THEN
        TDODIAG=(MOD(IFCALC,NPERID).EQ.0)
      ELSE IF (NPERID.EQ.0 .AND. NRPERI.GT.0) THEN
        TDODIAG=(NDISRS.GE.NRPERI)
        IF(TDODIAG) NDISRS=0
      ELSE IF (NPERID.GT.0 .AND. NRPERI.GT.0) THEN
        TDODIAG=(NDISRS.GE.NRPERI .AND.
     &           (NDISTP.GE.NPERID.OR.NDISRS.GT.NRPERI))
        IF(TDODIAG) THEN
          NDISRS=0
          NDISTP=0
        ENDIF
      ELSEIF (CONVWF .AND. NPERID.EQ.0 .AND. NRPERI.EQ.0) THEN
        TDODIAG = .TRUE.
      ENDIF
C     Yes, we do
      IF(TDODIAG) THEN
c        ampre=2.0D-4
c        if (parent) write (*,*) 'randomizing WF, amplitude: ', ampre
c        call rrane(c0,c2,nstate)
c        sdiis=.true.
c      endif
c      if(.false.) then
        TIME2=TIMEF()
        TCPU=(TIME2-TIME1)*0.001D0
        DETOT=ETOT-ETOT0
        IF(.NOT.CONVWF) THEN
          IF(TINFO) THEN
            CALL WRPRINT_WFOPT(EIGV,F,AMU,NSTATE,ETOT,ETOT0,
     &          TCPU,GEMAX,CNORM,THL,.FALSE.,IFCALC,IFCALC)
          ELSE
            WRITE(6,
     &        '(T9,I4,T15,1PE12.3,T31,0PF12.6,T45,1PE12.3,T59,0PF7.2) ')
     &        IFCALC,GEMAX,ETOT,DETOT,TCPU
          ENDIF
        ENDIF
        TIME1=TIMEF()
        ETOT0=ETOT
        TDIAG=.TRUE.
        TFIXO=.TRUE.
C       Get density as required by UPDRHO
        CALL DENS_FOR_DIAG(C0,RHOE,PSI,SCR,LSCR,NSTATE)
        IFCALC=IFCALC+1
C       Full diagonalization
        CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &              RHOE,PSI,SCR,LSCR,
     &              NSTATE,TFOR,TINFO,CALSTE,IFCALC,THL,NHPSI)
C       Calculate energies the usual way and init DIIS if required
        SDIIS=.TRUE.
        NDISRS=0
        TDIAG=.FALSE.
        CONVWF=.FALSE.
        IF(PARENT.AND.TINFO) WRITE(6,'(2A)') ' NFI      GEMAX',
     &       '       CNORM           ETOT        DETOT      TCPU'
        IF(PARENT.AND..NOT.TINFO) WRITE(6,'(T9,A)') 'INFR',
     &       '         GEMAX            ETOT         DETOT     TCPU'
        IF(TFOR) CALL AZZERO(FION,3*NAX*NSX)
C       Re-init energy arrays, DIIS, etc.
        CALL UPDWF(C0,C2,SC0,TAU0,FION,CSCR,CR,VPP,EIGV,
     &             RHOE,PSI,SCR,LSCR,NSTATE,TFOR,.TRUE.)
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE DENS_FOR_DIAG(C0,RHOE,PSI,SCR,LSCR,NSTATE)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'elct.inc'        !N
      INCLUDE 'andr.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'spin.inc'        !NLSD
      INCLUDE 'pslo.inc'        !TIVAN
      INCLUDE 'kpts.inc'        !TKPNT
      INCLUDE 'nlps.inc'
      INCLUDE 'fint.inc'        !TTROT
C     Arguments
      INTEGER    LSCR,NSTATE
      COMPLEX*16 C0(NGWK,N,NKPNT),PSI(*)
      REAL*8     RHOE(*),SCR(*)
C     Variables
      INTEGER    IKIND,IKPT,KBEG,KEND,KINC,NKPOINT
C     ==--------------------------------------------------------------==
      IF(TIVAN) THEN
        CALL INQ_SWAP(KBEG,KEND,KINC)
        DO IKPT=KBEG,KEND,KINC
          NKPOINT=NKPBL(IKPT)
          IF(TKBLOCK) CALL RKPT_SWAP(C0,NSTATE,IKPT,
     &        'HGKP HGKM MASKGW EIGKR TWNL C0')
          DO IKIND=1,NKPOINT
            CALL RNLSM(C0(1,1,IKIND),NSTATE,PSI,SCR,LSCR,
     &           IKPT,IKIND,.FALSE.)
          ENDDO
        ENDDO
      ENDIF
      IF(TKPNT) THEN
        CALL RHOOFR_C(C0,RHOE,PSI,SCR,LSCR,NSTATE)
      ELSE
        CALL RHOOFR  (C0,RHOE,PSI,SCR,LSCR,NSTATE)
      ENDIF
      CALL DCOPY(NNR1*NLSD,RHOE,1,RIN0,1)
C     DENSITY IS NOW THERE, DO MIXING STUFF
      IF(TRAND) CALL RRANDD(RIN0,AMPRD)
      CALL AZZERO(ROUT0,NNR1*NLSD)
      CALL AZZERO(RMIX,NNR1*NLSD)
C     NL-Projector Overlap Matrix
      IF(TTROT) CALL CALC_ALM(SCR,LSCR)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_FORCES_DIAG(LFORCES_DIAG,TAG,NSTATE,TFOR)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !TPRES
      INCLUDE 'kpts.inc'
C     Arguments
      INTEGER   LFORCES_DIAG,NSTATE,LTSCR
      LOGICAL   TFOR
      CHARACTER TAG*30
C     ==--------------------------------------------------------------==
      IF(TDIAG) THEN
        CALL GIVE_SCR_UPDRHO(LFORCES_DIAG,TAG,NSTATE,
     &                       TFOR,TFOR.AND.TPRES)
      ELSE
       IF(TKPNT) THEN
          CALL GIVE_SCR_KUPDWF(LFORCES_DIAG,TAG,NSTATE,TFOR)
       ELSE
          CALL GIVE_SCR_UPDWF(LFORCES_DIAG,TAG,NSTATE,TFOR)
       ENDIF 
      ENDIF
      IF (TFOR) THEN
        LTSCR=3*NAX*NSX
      ELSE
        LTSCR=0
      ENDIF
      LFORCES_DIAG=MAX(LFORCES_DIAG,LTSCR)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
