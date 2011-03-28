C     ==================================================================
      SUBROUTINE MM_FORCES_DIAG(NSTATE,C0,C1,C2,CR,SC0,CSCR,VPP,EIGV,
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
      INCLUDE 'ropt.inc'        !CALSTE
      INCLUDE 'andr.inc'
      INCLUDE 'andp.inc'
      INCLUDE 'soft.inc'
      INCLUDE 'store.inc'
      INCLUDE 'linres.inc'
      INCLUDE 'mm_input.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'mm_extrap.inc' !NUMCOLD
C     Arguments
      INTEGER    NSTATE,IFCALC,IREC(100),LSCR
      COMPLEX*16 C0(*),C2(*),C1(*),CR(*),SC0(*),CSCR(*),PSI(NNR1)
      REAL*8     EIGV(*),TAU0(*),VELP(*),TAUI(*),FION(*),VPP(*),
     &           RHOE(NNR1,NLSD),SCR(LSCR),THL(2)
      LOGICAL    TFOR,TINFO
C     Variables
      CHARACTER TAG*30
      REAL*8    TIME1,TIMEF,ETOT0,DETOT,TIME2,TTHL,TCPU
      EXTERNAL  TIMEF
      INTEGER   INFR,NHPSI,LFORCES_DIAG
      logical   update_pot
      
C     ==--------------------------------------------------------------==
C  
      if(qmnode)then
        TIME1 = TIMEF()
C       CALL GIVE_SCR_FORCES_DIAG(LFORCES_DIAG,TAG,NSTATE,TFOR)
C       CALL TEST_SCR('FORCES_DIAG',TAG,LSCR,LFORCES_DIAG)
C     ==--------------------------------------------------------------==
        ECNSTR=0.0D0
        CONVWF=.FALSE.
        ETOT0=0.0D0
        IF(TDIAG.AND.TLANC) THEN
          CALL SET_B2L()

          if(classical)then
            EKIN=0.d0
            ETOT=0.D0
            call azzero(C2,2*NGW*nstate)
            call azzero(FION,3*NAX*NSX)
            goto 100
          endif
       ENDIF


C     ==--------------------------------------------------------------==
        IF(TDIAG) THEN
          IF(.NOT.TINFO.AND.PARENT) THEN
             WRITE(6,'(T9,A)')
     &       'INFR       DRHOMAX        ETOT       DETOT   HPSI    TCPU'
          ENDIF
        ELSE
          IF(.NOT.TINFO.AND.PARENT) THEN
             WRITE(6,'(T9,A)')
     &       'INFR         GEMAX            ETOT         DETOT     TCPU'
          ENDIF
          SDIIS=.TRUE.
          SPCG=.TRUE.
        ENDIF
      endif
C
      update_pot=.true.
C     ==================================================================
C     ==                        MAIN  LOOP                            ==
C     ==================================================================
      DO INFR=1,NOMORE_ITER
        TIME1=TIMEF()
C       calculate the electrostatic potential in the first loop only
        if(qmmm .and.INFR.gt.1 ) update_pot = .false.
        IFCALC=IFCALC+1
C       Diagonalization
        IF(TDIAG) THEN
          CALL STOPGM("mm_forces_diag","UPDRHO not compatible")
          CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                RHOE,PSI,SCR,LSCR,
     &                NSTATE,.FALSE.,TINFO,.FALSE.,INFR,THL,NHPSI)
        ELSE
          CALL UPDWF(C0,C2,SC0,TAU0,FION,CR,CSCR,VPP,EIGV,
     &            RHOE,PSI,SCR,LSCR,NSTATE,.FALSE.,update_pot)
        ENDIF
C       Printout the evolution of the iterative optimization
        IF(PARENT) THEN
          DETOT=ETOT-ETOT0
          IF(INFR.EQ.1) DETOT=0.0D0
          TIME2=TIMEF()
          TCPU=(TIME2-TIME1)*0.001D0
          TTHL=THL(1)
          IF(TLSD) TTHL=0.5d0*(THL(1)+THL(2))
          IF(TINFO) THEN
            CALL WRPRINT_WFOPT(EIGV,F,AMU,NSTATE,ETOT,ETOT0,
     &         TCPU,GEMAX,CNORM,THL,.FALSE.,IFCALC,INFR)
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
        IF(qmnode) THEN
           IF(MOD(IFCALC,ISCTORE).EQ.0)
     &          CALL ZHWWF(2,IREC,C0,C2,NSTATE,EIGV,TAU0,VELP,TAUI,NFI)
        ENDIF
C       Check to break the loop.
C       CALL TESTEX(EXSOFT)
        if(qmmm)call my_bcast(CONVWF,8/IRAT,QMMMSOURCE,QMMMGRP)
C       IF(EXSOFT) GOTO 200     !Soft Exit (no force calculation)
        IF(CONVWF) GOTO 100     !Convergence of wavefunctions
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
 300  CONTINUE
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
      IF(PARENT) WRITE(6,'(A)') ' WARNING! DENSITY NOT CONVERGED !!!'
  100 CONTINUE
      IF(TFOR) THEN
        IF(TDIAG) THEN
C         Diagonalization
          CALL AZZERO(FION,3*NAX*NSX)
          CALL STOPGM("mm_forces_diag","UPDRHO not compatible")
          CALL UPDRHO(C0,C2,CR,SC0,CSCR,VPP,TAU0,FION,EIGV,
     &                RHOE,PSI,SCR,LSCR,
     &                NSTATE,.TRUE.,TINFO,CALSTE,INFR,THL,NHPSI)
        ELSE
          CALL UPDWF(C0,C2,SC0,TAU0,FION,CR,CSCR,VPP,EIGV,
     &               RHOE,PSI,SCR,LSCR,NSTATE,.TRUE.,.TRUE.)
        ENDIF
      ENDIF
      IF(TDDFT) THEN
         CALL LR_TDDFT(C0,C1,C2,SC0,RHOE,PSI,TAU0,FION,EIGV,
     &                 SCR,LSCR,N,TFOR,IOUTPUT)
C        Now we are ready to calculate the QM/MM forces
C        The full TDDFT QM forces are already in FION
      ENDIF
 200  CONTINUE
      if(qmmm) call my_sync(qmmmgrp)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_MM_FORCES_DIAG(LFORCES_DIAG,TAG,NSTATE,TFOR)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !TPRES
C     Arguments
      INTEGER   LFORCES_DIAG,NSTATE
      LOGICAL   TFOR
      CHARACTER TAG*30
C     ==--------------------------------------------------------------==
      IF(TDIAG) THEN
        CALL GIVE_SCR_UPDRHO(LFORCES_DIAG,TAG,NSTATE,
     &                       TFOR,TFOR.AND.TPRES)
      ELSE
        CALL GIVE_SCR_UPDWF(LFORCES_DIAG,TAG,NSTATE,TFOR)
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
