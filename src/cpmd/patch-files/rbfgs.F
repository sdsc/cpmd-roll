C     ==================================================================
      SUBROUTINE RBFGS(XPAR,DXPAR,SCR,LSCR)
C     ==--------------------------------------------------------------==
C     ==  SOLVE THE NEWTON EQUATION AND DETERMINE AN IONIC STEP       ==
C     ==--------------------------------------------------------------==
C     == INPUT:                                                       ==
C     ==   XPAR(NODIM)                                                ==
C     ==  DXPAR(NODIM)                                                ==
C     == OUTPUT:                                                      ==
C     ==   XPAR(NODIM)                                                ==
C     ==  (NODIM Number of Freedom degres                             ==
C     ==  SCR(LSCR) Scratch array                                     ==
C     == Use HESS(NODIM,NODIM) Hessian matrix (estimated)             ==
C     ==     DTM(NODIM)        Step                                   == 
C     ==--------------------------------------------------------------==
C     == IF TINVBFGS=.TRUE. use inverse Hessian matrix                ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'ions.inc'
      INCLUDE 'tpar.inc'
      INCLUDE 'isos.inc'
      INCLUDE 'cotr.inc'
C     Arguments
      INTEGER LSCR
      REAL*8  XPAR(NODIM),DXPAR(NODIM),SCR(LSCR)
C     Variables
      REAL*8    EPS
      PARAMETER (EPS=1.D-6)
      REAL*8    HESSVD(NODIM,NODIM),SFION(NODIM),SVAL(NODIM)
      POINTER   (IP_HESSVD,HESSVD),(IP_SFION,SFION),(IP_SVAL,SVAL)
      CHARACTER TAG*30
      INTEGER   ISUB,LRBFGS,I,NRANK,INFO
      REAL*8    SDLEN,DDOT,QNRLEN,TR,SS
      EXTERNAL  DDOT  
C     ==--------------------------------------------------------------==
      CALL TISET('     RBFGS',ISUB)
C     ==--------------------------------------------------------------==
C     ==  SCRATCH SPACE ALLOCATION:                                   ==
C     ==    HESSVD  HESS IN SVD                                       ==
C     ==    SFION   FION                                              ==
C     ==    SVAL    SINGULAR VALUES                                   ==
C     ==    SCR     SCRATCH AND S                                     ==
C     ==--------------------------------------------------------------==
      CALL GIVE_SCR_RBFGS(LRBFGS,TAG)
      CALL TEST_SCR('RBFGS',TAG,LSCR,LRBFGS)
C     ==--------------------------------------------------------------==
      IF(TINVBFGS) THEN
C       use inverse Hessian Matrix
        CALL DGEMV('N',NODIM,NODIM,-1.D0,HESS,NODIM,DXPAR,1,1.D0,XPAR,1)
        RETURN
      ENDIF
C     ==--------------------------------------------------------------==
#ifdef _BGL 
      CALL GET_ADDR(IP_SVAL,SCR(1))
      LRBFGS=NODIM+MOD(NODIM,2)
      CALL GET_ADDR(IP_SFION,SCR(LRBFGS+1))
      LRBFGS=LRBFGS+NODIM+MOD(NODIM,2)
      CALL GET_ADDR(IP_HESSVD,SCR(LRBFGS+1))
      LRBFGS=LRBFGS+NODIM*NODIM+MOD(NODIM*NODIM,2)+1
#else
      LRBFGS=LRBFGS-NODIM*NODIM
      CALL GET_ADDR(IP_HESSVD,SCR(LRBFGS+1))
      LRBFGS=LRBFGS-NODIM
      CALL GET_ADDR(IP_SFION,SCR(LRBFGS+1))
      LRBFGS=LRBFGS-NODIM
      CALL GET_ADDR(IP_SVAL,SCR(LRBFGS+1))
      LRBFGS=1
#endif
C     ==--------------------------------------------------------------==
C     ==  SOLVE HESS*S = -FION                                        ==
C     ==  (FION is given, the unknown variable is S)                  == 
C     ==--------------------------------------------------------------==
      CALL DCOPY(NODIM*NODIM,HESS(1,1),1,HESSVD(1,1),1)
      DO I=1,NODIM
        SFION(I)=-DXPAR(I)
        SCR(LRBFGS+I-1)=DTM(I)*DXPAR(I)
      ENDDO
      SDLEN=SQRT(DDOT(NODIM,SCR(LRBFGS),1,SCR(LRBFGS),1))
      CALL DGELSS(NODIM,NODIM,1,HESSVD,NODIM,SFION,NODIM,
     *            SVAL,EPS,NRANK,SCR(LRBFGS),6*NODIM,INFO)
      QNRLEN=SQRT(DDOT(NODIM,SFION,1,SFION,1))
C     ==--------------------------------------------------------------==
C     ==  THIS IS A PRIMITIVE TRUST REGION CONCEPT                    ==
C     ==--------------------------------------------------------------==
      TR=100.0D0 * SDLEN
      IF(TR.LT.0.01D0) TR=0.01D0
      TR=MIN(TR,DMAX)
      IF(QNRLEN.GT.TR) THEN
        SS=SQRT(TR/QNRLEN)
        CALL DSCAL(NODIM,SS,SFION,1)
      ENDIF
      CALL FIXCOM(SFION)
      CALL DAXPY(NODIM,1.0D0,SFION,1,XPAR(1),1)
      CALL TIHALT('     RBFGS',ISUB)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GIVE_SCR_RBFGS(LRBFGS,TAG)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'        !PARENT MGDIIS
      INCLUDE 'cotr.inc'        !NODIM
C     Arguments
      INTEGER LRBFGS
      CHARACTER*30 TAG
C     ==--------------------------------------------------------------==
      IF(TINVBFGS) THEN
        LRBFGS=0
        TAG  ='0'
      ELSE
        LRBFGS=NODIM*NODIM+8*NODIM+10
        TAG  ='NODIM*NODIM+8*NODIM'
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
