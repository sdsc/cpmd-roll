C hello emacs, this is -*- fortran -*-
C     ==================================================================
C     == VANDERBILT PSEUDOPOTENTALS                                   ==
C     ==================================================================
      REAL*8         RSCORE(MMAXX,*),DION(NBRX,NBRX,*),
     &               BETAR(MMAXX,NBRX,*),QQQ(NBRX,NBRX,*),
     &               QFUNC(MMAXX,NBRX,NBRX,*),QRL(MMAXX,NBRX,NBRX,LX,*),
     &               R(MMAXX,*),RUCORE(MMAXX,NBRX,*),RU(MMAXX,*),
     &               RAB(MMAXX,*),RSATOM(MMAXX,*),
     &               VDB_PAWF(NSX,MMAXX,*),VDB_R(MMAXX,*)
      POINTER        (IP_RSCORE,RSCORE),(IP_DION,DION),
     *               (IP_BETAR,BETAR),(IP_QQQ,QQQ),
     *               (IP_QFUNC,QFUNC),(IP_QRL,QRL),(IP_R,R),
     *               (IP_RUCORE,RUCORE),(IP_RU,RU),(IP_RAB,RAB),
     *               (IP_RSATOM,RSATOM),
     *               (IP_VDB_PAWF,VDB_PAWF),(IP_VDB_R,VDB_R)
      COMMON /NCPR0/ IP_RSCORE,IP_DION,IP_BETAR,IP_QQQ,
     *               IP_QFUNC,IP_QRL,IP_R,IP_RUCORE,IP_RU,
     *               IP_RAB,IP_RSATOM,
     *               IP_VDB_PAWF,IP_VDB_R
C     ==================================================================
      REAL*8         CMESH(MAXSP)
      INTEGER        NBETA(MAXSP),NVALES(MAXSP),
     *               IFPCOR(MAXSP),KKBETA(MAXSP),MESHVA(MAXSP)
      COMMON /NCPR1/ CMESH,NBETA,NVALES,IFPCOR,KKBETA,MESHVA
C     ==================================================================
