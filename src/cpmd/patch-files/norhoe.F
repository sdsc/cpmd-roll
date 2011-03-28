C     ==================================================================
      SUBROUTINE NORHOE(C0,SC0,EIGV,RHOE,PSI,XMAT1,XMAT2,SCR,LSCR,
     &                  NSTATE)
C     ==--------------------------------------------------------------==
C          This routine estimate the electronic density for a set of 
C                        non orthogonal orbitals
C                           NNN (Sep.23,2005)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'elct.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'sfac.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'nort.inc'
      INCLUDE 'spin.inc'
      INCLUDE 'geq0.inc'
!     Arguments
      INTEGER    NSTATE,LSCR
      COMPLEX*16 C0(NGW,*),SC0(NGW,*),PSI(*)
      REAL*8     EIGV(*),RHOE(*),SCR(*)
      REAL*8     XMAT1(NSTATE,*),XMAT2(NSTATE,*)
!     Variables
      REAL*8     GAM(NSTATE,*),AUXC(*),SMAT(*)
      POINTER    (IP_GAM,GAM),(IP_AUXC,AUXC),(IP_SMAT,SMAT)
      DIMENSION  F(*)
      CHARACTER  TAG*30
      REAL*8     FNL(NAT,NHXS,*),DFNL(*)
      LOGICAL    DEBUG
      INTEGER    ISUB,I,IJ,J,IERR,
     &           IL_GAM,IL_AUXC,IL_SMAT,IL_DDIA,LNORHO,
     &           ICONV
      DATA       ICONV /0/
      SAVE       ICONV
#ifdef PARALLEL
      INTEGER    MSGLEN
#endif
!     
      CALL TISET('    NORHOE',ISUB)
      DEBUG=.FALSE.
      IF(TLSE) CALL STOPGM('NORHOE','NO LSE ALLOWED HERE')
      IF(IMAGP.EQ.2) CALL STOPGM('NORHOE','K-POINTS NOT IMPLEMENTED')
!
!     Scratch space test
      CALL GIVE_SCR_NOFORCE(LNORHO,IL_GAM,IL_AUXC,IL_SMAT,IL_DDIA,
     &    TAG,NSTATE,.FALSE.)
      CALL TEST_SCR('NORHOE','LENGTH',LSCR,LNORHO)
!
      IF(GEQ0) CALL ZCLEAN(C0,NSTATE,NGW)
!
!     Compute the FNL array in non orthogonal basis
      IF(TIVAN) CALL RNLSM(C0,NSTATE,PSI,SCR,LSCR,1,1,.FALSE.)
!
!     Do scratch allocation
      CALL SCRSET(SCR,LSCR,DEBUG)
      CALL SCRPTR(SCR,LSCR,IP_GAM,IL_GAM,'GAM',DEBUG)
      CALL SCRPTR(SCR,LSCR,IP_AUXC,IL_AUXC,'AUXC',DEBUG)
      CALL SCRPTR(SCR,LSCR,IP_SMAT,IL_SMAT,'SMAT',DEBUG)
!
!     Compute the overlap matrix
      CALL CSMAT(GAM,C0,FNL,NSTATE,1)
! 
!     Compute the S**(-1/2) array for doing orthogonalization of C0
      IF(PARENT) THEN
        CALL DGEMM('N','N',NSTATE,NSTATE,NSTATE,1.0D0,GAM(1,1),NSTATE,
     *             XMAT1(1,1),NSTATE,0.0D0,XMAT2(1,1),NSTATE)
        CALL DGEMM('T','N',NSTATE,NSTATE,NSTATE,1.0D0,XMAT1(1,1),NSTATE,
     *             XMAT2(1,1),NSTATE,0.0D0,GAM(1,1),NSTATE)
        CALL JACOBI(NSTATE,NSTATE,GAM,EIGV,XMAT2,IERR)
        CALL DGEMM('N','N',NSTATE,NSTATE,NSTATE,1.0D0,XMAT1(1,1),NSTATE,
     *             XMAT2(1,1),NSTATE,0.0D0,SMAT(1),NSTATE)
        CALL DCOPY(NSTATE*NSTATE,SMAT(1),1,XMAT1(1,1),1)
        ICONV=ICONV+1
        DO I=1,NSTATE
          EIGV(I)=1.0D0/DSQRT(EIGV(I))
        ENDDO
        IJ=0
        DO I=1,NSTATE
          DO J=1,NSTATE
            IJ=IJ+1
            AUXC(IJ)=EIGV(I)*SMAT(IJ)
          ENDDO
        ENDDO
        CALL DGEMM('N','T',NSTATE,NSTATE,NSTATE,1.0D0,AUXC(1),NSTATE,
     *             SMAT(1),NSTATE,0.0D0,GAM(1,1),NSTATE)
        CALL DCOPY(NSTATE*NSTATE,GAM(1,1),1,SMAT(1),1)
        CALL DCOPY(NSTATE*NSTATE,SMAT(1),1,XMAT2(1,1),1)
      ENDIF
#ifdef PARALLEL
      MSGLEN = NSTATE*NSTATE * 8
      CALL MY_BCAST(SMAT,MSGLEN,SOURCE,ALLGRP)
#endif
!
!     Do symmetric orthogonalization. SC0 is having the orthogonal basis
      CALL ROTATE(1.0D0,C0,0.0D0,SC0,SMAT,NSTATE,2*NGW,TLSD,NSUP,NSDOWN)
!
!     Release the scratch space
      CALL SCRREL(SCR,LSCR,DEBUG)
!
!     Compute the FNL array for the orthogonal basis
      CALL RNLSM(SC0,NSTATE,PSI,SCR,LSCR,1,1,.FALSE.)
!
!     Compute the electronic density for the orthogonal basis
      CALL RHOOFR(SC0,RHOE,PSI,SCR,LSCR,NSTATE)
C     ==--------------------------------------------------------------==
      CALL TIHALT('    NORHOE',ISUB)
      RETURN
      END
C     ==================================================================
