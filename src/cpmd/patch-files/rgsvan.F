C     ==================================================================
      SUBROUTINE RGSVAN(C0,FNLA,NSTATE,SMAT)
C     ==--------------------------------------------------------------==
C     ==  Gram-Schmidt orthogonalization for Vanderbilt pp            ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'ions.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'sfac.inc'
      INTEGER NSTATE,ISUB
      COMPLEX*16 C0(NGW,*)
      REAL*8 FNLA(LDF1,NHXS,*),SMAT(*),FNL(*),DFNL(*)
      LOGICAL TLSD_BACK
C     ==--------------------------------------------------------------==
      IF(NSTATE.LE.0) RETURN
      CALL TISET('    RGSVAN',ISUB)
      TLSD_BACK=TLSD
      TLSD=.FALSE.
      CALL CSMAT(SMAT,C0,FNLA,NSTATE,1)
      CALL UINV('U',SMAT,NSTATE,NSTATE)
      IF(NGW.GT.0)
     *  CALL DTRMM('R','U','N','N',2*NGW,NSTATE,1.D0,SMAT,NSTATE,C0,
     *             2*NGW)
      IF(LDF1.GT.0)
     *  CALL DTRMM('R','U','N','N',LDF1*NHXS,NSTATE,1.D0,SMAT,NSTATE,
     *             FNLA,LDF1*NHXS)
      TLSD=TLSD_BACK
      CALL TIHALT('    RGSVAN',ISUB)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
