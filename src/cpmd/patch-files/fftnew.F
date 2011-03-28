C     ==================================================================
      SUBROUTINE FFTNEW(ISIGN,ITASK,F,SPARSE)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'fft.inc'
C     Arguments
      INTEGER    ISIGN,ITASK
      COMPLEX*16 F(*)
      LOGICAL SPARSE
C     Variables
      REAL*8     SCALE
      INTEGER    M
#ifdef PARALLEL
      INTEGER    LDA,MM,N1U,N1O
#endif
C     ==--------------------------------------------------------------==
      IF(ITASK.EQ.10) THEN
        IF(ISIGN.EQ.-1) THEN
          SCALE=1.D0
#ifdef PARALLEL
          IF(SPARSE) THEN
            M=MSRAYS
            CALL MLTFFT('N','T',F,QR1S,M,XF,M,QR1S,LR1S,M,ISIGN,SCALE)
            LDA=LSRM*LR1M
            MM=QR2S*(QR3MAX-QR3MIN+1)
            IF(TR4A2A) THEN
              CALL TX2YN4(XF,YF,MM,MSRAYS,LR1,LDA,MSQS,LMSQ,LRXPL,
     *                    SP5,SP9,MAXFFTN,NPROC)
            ELSE
              CALL TX2YN(XF,YF,MM,MSRAYS,LR1,LDA,MSQS,LMSQ,LRXPL,
     *                   SP5,SP9,MAXFFTN,NPROC)
            ENDIF
            M=(QR3MAX-QR3MIN+1)*QR1
            CALL MLTFFT('N','T',YF,QR2S,M,XF,M,QR2S,LR2S,M,ISIGN,SCALE)
            M=QR1*QR2S
            CALL PUTZ(XF,YF,QR3MIN,QR3MAX,QR3S,M)
            CALL MLTFFT('N','T',YF,QR3S,M,F,M,QR3S,LR3S,M,ISIGN,SCALE)
          ELSE
            M=MFRAYS
            CALL MLTFFT('N','T',F,QR1S,M,XF,M,QR1S,LR1S,M,ISIGN,SCALE)
            LDA=LFRM*LR1M
            MM=QR2S*QR3S
            IF(TR4A2A) THEN
              CALL TX2YN4(XF,YF,MM,MFRAYS,LR1,LDA,MSQF,LMSQ,LRXPL,
     *                    SP5,SP8,MAXFFTN,NPROC)
            ELSE
              CALL TX2YN(XF,YF,MM,MFRAYS,LR1,LDA,MSQF,LMSQ,LRXPL,
     *                   SP5,SP8,MAXFFTN,NPROC)
            ENDIF
            M=QR1*QR3S
            CALL MLTFFT('N','T',YF,QR2S,M,XF,M,QR2S,LR2S,M,ISIGN,SCALE)
            M=QR1*QR2S
            CALL MLTFFT('N','T',XF,QR3S,M,F,M,QR3S,LR3S,M,ISIGN,SCALE)
            N1U=LRXPL(MEPOS,1)
            N1O=LRXPL(MEPOS,2)
            CALL PHASEN(F,QR1,QR2S,QR3S,N1U,N1O,LR2S,LR3S)
          ENDIF
#else
          IF(SPARSE) THEN
            M=(QR2MAX-QR2MIN+1)*(QR3MAX-QR3MIN+1)
            CALL MLTFFT('N','T',F,QR1S,M,XF,M,QR1S,LR1S,M,ISIGN,SCALE)
            M=(QR3MAX-QR3MIN+1)*QR1
            CALL PUTZ(XF,YF,QR2MIN,QR2MAX,QR2S,M)
            CALL MLTFFT('N','T',YF,QR2S,M,XF,M,QR2S,LR2S,M,ISIGN,SCALE)
            M=QR1*QR2S
            CALL PUTZ(XF,YF,QR3MIN,QR3MAX,QR3S,M)
            CALL MLTFFT('N','T',YF,QR3S,M,F,M,QR3S,LR3S,M,ISIGN,SCALE)
          ELSE
            CALL FFT3D(F,QR1S,QR2S,QR3S,LR1S,LR2S,LR3S,ISIGN,SCALE)
            CALL PHASEN(F,QR1,QR2S,QR3S,1,LR1S,LR2S,LR3S)
          ENDIF
#endif
        ELSE
#ifdef PARALLEL
          IF(SPARSE) THEN
            SCALE=1.D0
            M=QR1*QR2S
            CALL MLTFFT('T','N',F,M,QR3S,XF,QR3S,M,LR3S,M,ISIGN,SCALE)
            CALL GETZ(XF,F,QR3MIN,QR3MAX,QR3S,M)
            M=(QR3MAX-QR3MIN+1)*QR1
            CALL MLTFFT('T','N',F,M,QR2S,YF,QR2S,M,LR2S,M,ISIGN,SCALE)
            LDA=LSRM*LR1M
            MM=QR2S*(QR3MAX-QR3MIN+1)
            IF(TR4A2A) THEN
              CALL TY2XN4(XF,YF,MM,MSRAYS,LR1,LDA,MSQS,LMSQ,LRXPL,
     *                    SP5,SP9,NPROC)
            ELSE
              CALL TY2XN(XF,YF,MM,MSRAYS,LR1,LDA,MSQS,LMSQ,LRXPL,
     *                   SP5,SP9,NPROC)
            ENDIF
            M=MSRAYS
            SCALE=1.D0/DBLE(LR1S*LR2S*LR3S)
            CALL MLTFFT('T','N',XF,M,QR1S,F,QR1S,M,LR1S,M,ISIGN,SCALE)
          ELSE
            N1U=LRXPL(MEPOS,1)
            N1O=LRXPL(MEPOS,2)
            CALL PHASEN(F,QR1,QR2S,QR3S,N1U,N1O,LR2S,LR3S)
            SCALE=1.D0
            M=QR1*QR2S
            CALL MLTFFT('T','N',F,M,QR3S,XF,QR3S,M,LR3S,M,ISIGN,SCALE)
            M=QR1*QR3S
            CALL MLTFFT('T','N',XF,M,QR2S,YF,QR2S,M,LR2S,M,ISIGN,SCALE)
            LDA=LFRM*LR1M
            MM=QR2S*QR3S
            IF(TR4A2A) THEN
              CALL TY2XN4(XF,YF,MM,MFRAYS,LR1,LDA,MSQF,LMSQ,LRXPL,
     *                    SP5,SP8,NPROC)
            ELSE
              CALL TY2XN(XF,YF,MM,MFRAYS,LR1,LDA,MSQF,LMSQ,LRXPL,
     *                   SP5,SP8,NPROC)
            ENDIF
            SCALE=1.D0/DBLE(LR1S*LR2S*LR3S)
            M=MFRAYS
            CALL MLTFFT('T','N',XF,M,QR1S,F,QR1S,M,LR1S,M,ISIGN,SCALE)
          ENDIF
#else
          IF(SPARSE) THEN
            SCALE=1.D0
            M=QR1*QR2S
            CALL MLTFFT('T','N',F,M,QR3S,XF,QR3S,M,LR3S,M,ISIGN,SCALE)
            CALL GETZ(XF,F,QR3MIN,QR3MAX,QR3S,M)
            M=(QR3MAX-QR3MIN+1)*QR1
            CALL MLTFFT('T','N',F,M,QR2S,YF,QR2S,M,LR2S,M,ISIGN,SCALE)
            SCALE=1.D0/DBLE(LR1S*LR2S*LR3S)
            CALL GETZ(YF,XF,QR2MIN,QR2MAX,QR2S,M)
            M=(QR2MAX-QR2MIN+1)*(QR3MAX-QR3MIN+1)
            CALL MLTFFT('T','N',XF,M,QR1S,F,QR1S,M,LR1S,M,ISIGN,SCALE)
          ELSE
            CALL PHASEN(F,QR1,QR2S,QR3S,1,LR1S,LR2S,LR3S)
            SCALE=1.D0/DBLE(LR1S*LR2S*LR3S)
            CALL FFT3D(F,QR1,QR2S,QR3S,LR1,LR2S,LR3S,ISIGN,SCALE)
          ENDIF
#endif
        ENDIF
      ELSE
        CALL STOPGM("FFTNEW","ITASK ERROR")
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE SETFFTN(IPOOL)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'cppt.inc'
      INCLUDE 'fft.inc'
C     Arguments
      INTEGER    IPOOL
C     Variables
      DIMENSION  MSQF(*),MSQS(*)
      DIMENSION  MSP(NHRM,2,*),MSQSPOOL(LMSQMAX,NPROC,*)
      DIMENSION  MSQFPOOL(LMSQMAX,NPROC,*)
      INTEGER    IP,IPX
C     ==--------------------------------------------------------------==
      IF (IPOOL.EQ.0) THEN
        MSRAYS   = NGRAYS
        MFRAYS   = NHRAYS
        LLR1     = NNR1
        QR1S     = KR1S
        QR2S     = KR2S
        QR3S     = KR3S
        QR1      = KR1
        LR1S     = NR1S
        LR2S     = NR2S
        LR3S     = NR3S
        LR1      = NR1
        QR2MAX   = KR2MAX
        QR2MIN   = KR2MIN
        QR3MAX   = KR3MAX
        QR3MIN   = KR3MIN
        LSRM     = NGRM
        LFRM     = NHRM
        LR1M     = NR1M
        LMSQ     = NHRM
        MAXFFTN  = MAXFFT
        JGW      = NGW
        JGWS     = NGWS
        JHG      = NHG
        JHGS     = NHGS
        CALL GET_ADDR(IP_NZFF,NZH(1))
        CALL GET_ADDR(IP_INZF,INDZ(1))
        CALL GET_ADDR(IP_NZFS,NZHS(1))
        CALL GET_ADDR(IP_INZS,INDZS(1))
        CALL GET_ADDR(IP_INZH,INYH(1,1))
        DO IP=0,NPROC-1
          LRXPL(IP,1)    = NRXPL(IP,1)
          LRXPL(IP,2)    = NRXPL(IP,2)
          SP5(IP)        = SPARM(5,IP)
          SP8(IP)        = SPARM(8,IP)
          SP9(IP)        = SPARM(9,IP)
          IPX=LMSQ*IP
          IF(NHRM.GT.0) THEN
            CALL ICOPY(NHRM,MSP(1,1,IP+1),1,MSQF(IPX+1),1)
            CALL ICOPY(NHRM,MSP(1,2,IP+1),1,MSQS(IPX+1),1)
          ENDIF
        ENDDO
      ELSEIF (IPOOL.GT.0 .AND. IPOOL.LE.FFTPOOL) THEN
C       LOAD FROM POOL
        MSRAYS   = FPOOLV( 1,IPOOL)
        MFRAYS   = FPOOLV( 2,IPOOL)
        LLR1     = FPOOLV( 3,IPOOL)
        QR1S     = FPOOLV( 4,IPOOL)
        QR2S     = FPOOLV( 5,IPOOL)
        QR3S     = FPOOLV( 6,IPOOL)
        QR1      = FPOOLV( 7,IPOOL)
        QR2      = FPOOLV( 8,IPOOL)
        QR3      = FPOOLV( 9,IPOOL)
        LR1S     = FPOOLV(10,IPOOL)
        LR2S     = FPOOLV(11,IPOOL)
        LR3S     = FPOOLV(12,IPOOL)
        LR1      = FPOOLV(13,IPOOL)
        LR2      = FPOOLV(14,IPOOL)
        LR3      = FPOOLV(15,IPOOL)
        QR2MAX   = FPOOLV(16,IPOOL)
        QR2MIN   = FPOOLV(17,IPOOL)
        QR3MAX   = FPOOLV(18,IPOOL)
        QR3MIN   = FPOOLV(19,IPOOL)
        LSRM     = FPOOLV(20,IPOOL)
        LFRM     = FPOOLV(21,IPOOL)
        LR1M     = FPOOLV(22,IPOOL)
        LMSQ     = FPOOLV(23,IPOOL)
        MAXFFTN  = FPOOLV(24,IPOOL)
        JGW      = FPOOLV(25,IPOOL)
        JGWS     = FPOOLV(26,IPOOL)
        JHG      = FPOOLV(27,IPOOL)
        JHGS     = FPOOLV(28,IPOOL)
        CALL GET_ADDR(IP_NZFF,NZFFP(1,IPOOL))
        CALL GET_ADDR(IP_INZF,INZFP(1,IPOOL))
        CALL GET_ADDR(IP_NZFS,NZFSP(1,IPOOL))
        CALL GET_ADDR(IP_INZS,INZSP(1,IPOOL))
        CALL GET_ADDR(IP_INZH,INZHP(1,1,IPOOL))
        DO IP=0,NPROC-1
          LRXPL(IP,1)    = LRXPOOL(IP,1,IPOOL)
          LRXPL(IP,2)    = LRXPOOL(IP,2,IPOOL)
          SP5(IP)        = SPM(5,IP,IPOOL)
          SP8(IP)        = SPM(8,IP,IPOOL)
          SP9(IP)        = SPM(9,IP,IPOOL)
          IPX=LMSQ*IP
          CALL ICOPY(LMSQ,MSQFPOOL(1,IP+1,IPOOL),1,MSQF(IPX+1),1)
          CALL ICOPY(LMSQ,MSQSPOOL(1,IP+1,IPOOL),1,MSQS(IPX+1),1)
        ENDDO
      ELSE
        CALL STOPGM("SETFFTN","FFTPOOL NOT DEFINED")
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE RMFFTNSET(IPOOL)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'fft.inc'
C     Arguments
      INTEGER  IPOOL
C     Variables
      INTEGER  I,J,IP
      DIMENSION  MSQSPOOL(LMSQMAX,NPROC,*)
      DIMENSION  MSQFPOOL(LMSQMAX,NPROC,*)
C     ==--------------------------------------------------------------==
      IF (IPOOL.GT.0 .AND. IPOOL.LE.FFTPOOL) THEN
        DO IP=IPOOL+1,FFTPOOL
          I=IP
          J=IP-1
          CALL ICOPY(28,FPOOLV(1,I),1,FPOOLV(1,J),1)
          CALL ICOPY(LNZF,NZFFP(1,I),1,NZFFP(1,J),1)
          CALL ICOPY(LNZF,INZFP(1,I),1,INZFP(1,J),1)
          CALL ICOPY(LNZS,NZFSP(1,I),1,NZFSP(1,J),1)
          CALL ICOPY(LNZS,INZSP(1,I),1,INZSP(1,J),1)
          CALL ICOPY(3*LNZF,INZHP(1,1,I),1,INZHP(1,1,J),1)
          CALL ICOPY(2*MAXCPU+2,LRXPOOL(0,1,I),1,LRXPOOL(0,1,J),1)
          CALL ICOPY(9*MAXCPU+9,SPM(1,0,I),1,SPM(1,0,J),1)
          CALL ICOPY(LMSQMAX*NPROC,MSQFPOOL(1,1,I),1,MSQFPOOL(1,1,J),1)
          CALL ICOPY(LMSQMAX*NPROC,MSQSPOOL(1,1,I),1,MSQSPOOL(1,1,J),1)
        ENDDO
        CALL IAZZERO(FPOOLV(1,FFTPOOL),28)
        CALL IAZZERO(NZFFP(1,FFTPOOL),LNZF)
        CALL IAZZERO(INZFP(1,FFTPOOL),LNZF)
        CALL IAZZERO(NZFSP(1,FFTPOOL),LNZF)
        CALL IAZZERO(INZSP(1,FFTPOOL),LNZF)
        CALL IAZZERO(INZHP(1,1,FFTPOOL),3*LNZF)
        CALL IAZZERO(LRXPOOL(0,1,FFTPOOL),2*MAXCPU+2)
        CALL IAZZERO(SPM(1,0,FFTPOOL),9*MAXCPU+9)
        CALL IAZZERO(MSQFPOOL(1,1,FFTPOOL),LMSQMAX*NPROC)
        CALL IAZZERO(MSQSPOOL(1,1,FFTPOOL),LMSQMAX*NPROC)
        FFTPOOL=FFTPOOL-1
      ELSE
        CALL STOPGM("RMFFTNSET","FFTPOOL NOT DEFINED")
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE ADDFFTNSET(ECUTF,ECUTS,IPOOL)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'cppt.inc'
      INCLUDE 'cnst.inc'
      INCLUDE 'cell.inc'
      INCLUDE 'kpts.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'fft.inc'
C     Arguments
      REAL*8   ECUTF,ECUTS
      INTEGER  IPOOL
C     Variables
      DIMENSION  MSQSPOOL(LMSQMAX,NPROC,*)
      DIMENSION  MSQFPOOL(LMSQMAX,NPROC,*)
      REAL*8   RR,XPLANES,XPNOW,XPAIM
      REAL*8   AA1,AA2,AA3
      INTEGER  FFTCHK,IG,L,I,J,K,NH1,NH2,NH3,LH1,LH2,LH3
      EXTERNAL FFTCHK
C
      INTEGER  ICOUNT
      SAVE     ICOUNT
      DATA     ICOUNT /0/
C     ==--------------------------------------------------------------==
      IF(ICOUNT.EQ.0) THEN
        LMSQMAX=NHRM
        CALL IAZZERO(LRXPOOL,2*FFTPOOLSIZE*(MAXCPU+1))
        CALL IAZZERO(SPM,9*FFTPOOLSIZE*(MAXCPU+1))
        L=(LMSQMAX*NPROC)/IRAT + 1
        CALL MEMORY(IP_MSQF,L,'MSQF')
        CALL MEMORY(IP_MSQS,L,'MSQS')
        L=(LMSQMAX*NPROC*FFTPOOLSIZE)/IRAT + 1
        CALL MEMORY(IP_MSQFPOOL,L,'MSQFPOOL')
        CALL MEMORY(IP_MSQSPOOL,L,'MSQSPOOL')
        L=(NHG*FFTPOOLSIZE)/IRAT+1
        CALL MEMORY(IP_NZFFP,L,'NZFFP')
        CALL MEMORY(IP_NZFSP,L,'NZFSP')
        CALL MEMORY(IP_INZFP,L,'INZFP')
        CALL MEMORY(IP_INZSP,L,'INZSP')
        L=(3*NHG*FFTPOOLSIZE)/IRAT+1
        CALL MEMORY(IP_INZHP,L,'INZHP')
      ENDIF
      ICOUNT=1
      IF(ECUTF.LT.0.D0 .OR. ECUTS.LT.0.D0) RETURN
C
C     IF(TKPNT) CALL STOPGM("ADDFFTNSET","NOT IMPLEMENTED")
C
      FFTPOOL=FFTPOOL+1
      IF(FFTPOOL.GT.FFTPOOLSIZE) THEN
        CALL STOPGM("ADDFFTNSET","TOO MANY ENTRIES IN POOL")
      ENDIF
      IPOOL=FFTPOOL
C
      JHG=NHG
      DO IG=2,NHG
        IF(TPIBA2*HG(IG).GT.ECUTF) THEN
          JHG=IG-1
          GOTO 100
        ENDIF
      ENDDO
  100 CONTINUE
      RR=DBLE(JHG)
      CALL GLOSUM(1,RR)
      JHGS=NINT(RR)
      IF(JHGS.GT.NHGS) CALL STOPGM("ADDFFTNSET","JHGS TOO LARGE")
      JGW=NHG
      DO IG=2,NHG
        IF(TPIBA2*HG(IG).GT.ECUTS) THEN
          JGW=IG-1
          GOTO 101
        ENDIF
      ENDDO
  101 CONTINUE
      RR=DBLE(JGW)
      CALL GLOSUM(1,RR)
      JGWS=NINT(RR)
      IF(JGWS.GT.NGWS) CALL STOPGM("ADDFFTNSET","JGWS TOO LARGE")
C
      AA1=ALAT
      AA2=ALAT*CELLDM(2)
      AA3=ALAT*CELLDM(3)
      LR1S=NINT(AA1/PI*SQRT(ECUTF)+0.5D0)
      LR2S=NINT(AA2/PI*SQRT(ECUTF)+0.5D0)
      LR3S=NINT(AA3/PI*SQRT(ECUTF)+0.5D0)
C
      LR1S=FFTCHK(LR1S,2)
      LR2S=FFTCHK(LR2S,2)
      LR3S=FFTCHK(LR3S,2)
      CALL LEADIM(LR1S,LR2S,LR3S,QR1S,QR2S,QR3S)
C
      NH1=NR1S/2+1
      NH2=NR2S/2+1
      NH3=NR3S/2+1
      LH1=LR1S/2+1
      LH2=LR2S/2+1
      LH3=LR3S/2+1
!$OMP parallel do private(IG,I,J,K) shared(NH1,NH2,NH3,LH1,LH2,LH3)
      DO IG=1,JHG
        I=INYH(1,IG)-NH1
        J=INYH(2,IG)-NH2
        K=INYH(3,IG)-NH3
        INZHP(1,IG,IPOOL)=LH1+I
        INZHP(2,IG,IPOOL)=LH2+J
        INZHP(3,IG,IPOOL)=LH3+K
      ENDDO
      CALL GET_ADDR(IP_INZH,INZHP(1,1,IPOOL))
C
      CALL IAZZERO(LRXPOOL(0,1,IPOOL),2*(MAXCPU+1))
      XPLANES=DBLE(LR1S)
      XPNOW=0.0D0
      DO I=NPROC,1,-1
        XPAIM = XPNOW + XPLANES/NPROC
        LRXPOOL(I-1,1,IPOOL)=NINT(XPNOW)+1
        LRXPOOL(I-1,2,IPOOL)=NINT(XPAIM)
        IF(NINT(XPAIM).GT.LR1S) LRXPOOL(I-1,2,IPOOL)=LR1S
        IF(I.EQ.1) LRXPOOL(I-1,2,IPOOL)=LR1S
        XPNOW = XPAIM
      ENDDO
      LR1=LRXPOOL(MEPOS,2,IPOOL)-LRXPOOL(MEPOS,1,IPOOL)+1
      CALL LEADIM(LR1,LR2S,LR3S,QR1,QR2S,QR3S)
      LR2=LR2S
      LR3=LR3S
      QR2=QR2S
      QR3=QR3S
      LLR1=QR1*QR2*QR3
C
      CALL SETRAYS(IPOOL)
C
      MAXFFTN = MAXFFT
C
      FPOOLV( 1,IPOOL) = MSRAYS
      FPOOLV( 2,IPOOL) = MFRAYS
      FPOOLV( 3,IPOOL) = LLR1
      FPOOLV( 4,IPOOL) = QR1S
      FPOOLV( 5,IPOOL) = QR2S
      FPOOLV( 6,IPOOL) = QR3S
      FPOOLV( 7,IPOOL) = QR1 
      FPOOLV( 8,IPOOL) = QR2 
      FPOOLV( 9,IPOOL) = QR3 
      FPOOLV(10,IPOOL) = LR1S
      FPOOLV(11,IPOOL) = LR2S
      FPOOLV(12,IPOOL) = LR3S
      FPOOLV(13,IPOOL) = LR1
      FPOOLV(14,IPOOL) = LR2
      FPOOLV(15,IPOOL) = LR3
      FPOOLV(16,IPOOL) = QR2MAX
      FPOOLV(17,IPOOL) = QR2MIN
      FPOOLV(18,IPOOL) = QR3MAX
      FPOOLV(19,IPOOL) = QR3MIN
      FPOOLV(20,IPOOL) = LSRM
      FPOOLV(21,IPOOL) = LFRM
      FPOOLV(22,IPOOL) = LR1M
      FPOOLV(23,IPOOL) = LMSQ
      FPOOLV(24,IPOOL) = MAXFFTN
      FPOOLV(25,IPOOL) = JGW
      FPOOLV(26,IPOOL) = JGWS
      FPOOLV(27,IPOOL) = JHG
      FPOOLV(28,IPOOL) = JHGS
C
      IF(PARENT) THEN
        WRITE(6,*)
        WRITE(6,'(A,T50,A,I4)') ' Add new FFT set ',' set number ',IPOOL
        WRITE(6,'(A,T51,3I5)') ' Real space Grid ',LR1S,LR2S,LR3S
        WRITE(6,'(A,T20,A,F6.0,T44,A,I10)') ' Sparse FFT setup: ',
     *        'Cutoff [Ry]:',ECUTS,'Plane Waves:',JGWS
        WRITE(6,'(A,T20,A,F6.0,T44,A,I10)') ' Full FFT setup  : ',
     *        'Cutoff [Ry]:',ECUTF,'Plane Waves:',JHGS
        WRITE(6,*)
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE SETRAYS(IPOOL)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'irat.inc'
      INCLUDE 'cppt.inc'
      INCLUDE 'fft.inc'
C     Arguments
      INTEGER IPOOL
C     Variables
      DIMENSION MG(QR2S,QR3S),MS(*),MZ(*)
      DIMENSION  MSQS(*),MSQF(*)
      DIMENSION  MSQSPOOL(LMSQMAX,NPROC,*)
      DIMENSION  MSQFPOOL(LMSQMAX,NPROC,*)
      INTEGER MY(*),MQ(*)
      POINTER (IP_MY,MY),(IP_MQ,MQ)
      INTEGER NH1,NH2,NH3,I,J,IG,NY1,NY2,NY3,INY1,INY2,INY3,
     *        IMG,JMG,JHGL,JGWL,NN2,INDY1,INDY2,INDY3
#ifdef PARALLEL
      INTEGER MSGLEN,IPRO,QR1M,IP,IXF,JJ,IJ,MXRP
#endif
C     ==--------------------------------------------------------------==
C     GATHER ARRAY FOR FFT ALONG X
C     SPARSITY FOR FFT ALONG Y
      CALL MEMORY(IP_MG,(QR2S*QR3S)/IRAT+1,'MG')
      CALL MEMORY(IP_MZ,(2*QR3S)/IRAT+1,'MZ')
      CALL MEMORY(IP_MY,(2*QR2S)/IRAT+1,'MY')
      CALL IAZZERO(MG,QR2S*QR3S)
      CALL IAZZERO(MZ,2*QR3S)
      CALL IAZZERO(MY,2*QR2S)
      NH1=LR1S/2+1
      NH2=LR2S/2+1
      NH3=LR3S/2+1
      DO IG=1,JGW
        NY2=INZH(2,IG)
        NY3=INZH(3,IG)
        INY2=-NY2+2*NH2
        INY3=-NY3+2*NH3
        MG(NY2,NY3)=MG(NY2,NY3)+1
        MG(INY2,INY3)=MG(INY2,INY3)+1
        MY(NY2)=MY(NY2)+1
        MY(INY2)=MY(INY2)+1
        MZ(NY3)=MZ(NY3)+1
        MZ(INY3)=MZ(INY3)+1
      ENDDO
#ifdef PARALLEL
      MSGLEN = LR2S * 8/IRAT
      CALL MY_COMBINE(MY,MY(LR2S+1),MSGLEN,2,ALLGRP)
      CALL ICOPY(LR2S,MY(LR2S+1),1,MY,1)
      MSGLEN = LR3S * 8/IRAT
      CALL MY_COMBINE(MZ,MZ(LR3S+1),MSGLEN,2,ALLGRP)
      CALL ICOPY(LR3S,MZ(LR3S+1),1,MZ,1)
#endif
      QR2MIN=1
      DO I=1,QR2S
        IF(MY(I).NE.0) THEN
          QR2MIN=I
          GOTO 50
        ENDIF
      ENDDO
   50 CONTINUE
      QR2MAX=QR2S
      DO I=QR2S,1,-1
        IF(MY(I).NE.0) THEN
          QR2MAX=I
          GOTO 51
        ENDIF
      ENDDO
   51 CONTINUE
      QR3MIN=1
      DO I=1,QR3
        IF(MZ(I).NE.0) THEN
          QR3MIN=I
          GOTO 52
        ENDIF
      ENDDO
   52 CONTINUE
      QR3MAX=1
      DO I=QR3,1,-1
        IF(MZ(I).NE.0) THEN
          QR3MAX=I
          GOTO 53
        ENDIF
      ENDDO
   53 CONTINUE
C     ==--------------------------------------------------------------==
      IMG=0
      DO J=1,QR3S
        DO I=1,QR2S
          IF(MG(I,J).NE.0) THEN
            IMG=IMG+1
            MG(I,J)=IMG
          ENDIF
        ENDDO
      ENDDO
      MSRAYS=IMG
      DO IG=JGW+1,JHG
        NY2=INZH(2,IG)
        NY3=INZH(3,IG)
        INY2=-NY2+2*NH2
        INY3=-NY3+2*NH3
        JMG=MG(NY2,NY3)
        IF(JMG.EQ.0) MG(NY2,NY3)=-1
        JMG=MG(INY2,INY3)
        IF(JMG.EQ.0) MG(INY2,INY3)=-1
      ENDDO
      DO J=1,QR3S
        DO I=1,QR2S
          IF(MG(I,J).LT.0) THEN
            IMG=IMG+1
            MG(I,J)=IMG
          ENDIF
        ENDDO
      ENDDO
      MFRAYS=IMG
C
      JHGL=0
      JGWL=0
      CALL IAZZERO(SPM(1,0,IPOOL),9*MAXCPU+9)
      SPM(1,MEPOS,IPOOL)=JHG
      SPM(2,MEPOS,IPOOL)=JHGL
      SPM(3,MEPOS,IPOOL)=JGW
      SPM(4,MEPOS,IPOOL)=JGWL
      SPM(5,MEPOS,IPOOL)=LR1
      SPM(6,MEPOS,IPOOL)=LR2
      SPM(7,MEPOS,IPOOL)=LR3
      SPM(8,MEPOS,IPOOL)=MFRAYS
      SPM(9,MEPOS,IPOOL)=MSRAYS
C
      CALL GET_ADDR(IP_NZFF,NZFFP(1,IPOOL))
      CALL GET_ADDR(IP_INZF,INZFP(1,IPOOL))
      CALL GET_ADDR(IP_NZFS,NZFSP(1,IPOOL))
      CALL GET_ADDR(IP_INZS,INZSP(1,IPOOL))
#ifdef PARALLEL
      DO I=0,NPROC-1
        IPRO=I
        MSGLEN = 9 * 8/IRAT
        CALL MY_BCAST(SPM(1,I,IPOOL),MSGLEN,IPRO,ALLGRP)
      ENDDO
C     MAXIMUM OF LR1, MSRAYS AND MFRAYS FOR MP_INDEX
      LR1M = 0
      LFRM = 0
      LSRM = 0
      DO I=0,NPROC-1
        LR1M = MAX(LR1M,SPM(5,I,IPOOL))
        LFRM = MAX(LFRM,SPM(8,I,IPOOL))
        LSRM = MAX(LSRM,SPM(9,I,IPOOL))
      ENDDO
      QR1M=MAX(LR1M+MOD(LR1M+1,2),QR1)
      LMSQ=MAX(LFRM,LSRM)
C     SCATTER ARRAY FOR FFT ALONG X
      CALL MEMORY(IP_MQ,LMSQ*2/IRAT+1,'MQ')
      CALL IAZZERO(MQ,2*LMSQ)
      DO I=1,QR2S
        DO J=1,QR3S
          IJ=MG(I,J)
          IF(IJ.GT.0) THEN
            MQ(IJ)=I
            MQ(LMSQ+IJ)=J
          ENDIF
        ENDDO
      ENDDO
C     CONCATENATE GATHER/SCATTER ARRAYS
      MSGLEN = LFRM * 8/IRAT
      CALL MY_CONCAT(MQ(1),MSQS,MSGLEN,ALLGRP)
      CALL MY_CONCAT(MQ(LMSQ+1),MSQF,MSGLEN,ALLGRP)
C     TRANSLATE I,J TO A SINGLE G/S INDEX
      DO IP=0,NPROC-1
        MXRP=SPARM(8,IP)
        DO IXF=1,MXRP
          JJ=IXF+IP*LMSQ
          I=MSQS(JJ)
          J=MSQF(JJ)
          MSQFPOOL(IXF,IP+1,IPOOL)=I+(J-1)*QR2S
          IF(IXF.LE.SPARM(9,IP)) 
     *       MSQSPOOL(IXF,IP+1,IPOOL)=I+(J-QR3MIN)*QR2S
        ENDDO
      ENDDO
C     REDEFINE NZH AND INDZ FOR COMPRESSED STORAGE
!$OMP parallel do private(IG,NY1,NY2,NY3,INY1,INY2,INY3)
#ifdef  _BGL 
!IBM* ASSERT (ITERCNT(10000))
#endif
      DO IG=1,JHG
        NY1=INZH(1,IG)
        NY2=INZH(2,IG)
        NY3=INZH(3,IG)
        INY1=-NY1+2*NH1
        INY2=-NY2+2*NH2
        INY3=-NY3+2*NH3
        NZFF(IG)=NY1 + (MG(NY2,NY3)-1)*QR1S
        INZF(IG)=INY1 + (MG(INY2,INY3)-1)*QR1S
      ENDDO
#ifdef  _BGL 
      CALL ALIGNX(16,NZFS(1))
      CALL ALIGNX(16,NZFF(1))
      CALL ALIGNX(16,INZS(1))
      CALL ALIGNX(16,NZFS(1))
!IBM* ASSERT (ITERCNT(10000))
!IBM* INDEPENDENT
#endif
!$OMP parallel do private(IG)
      DO IG=1,JGW
        NZFS(IG)=NZFF(IG)
        INZS(IG)=INZF(IG)
      ENDDO
#else
C     Gather arrays
#ifdef  _BGL 
!IBM* ASSERT (ITERCNT(10000))
#endif
!$OMP parallel do private(IG,INDY1,INDY2,INDY3)
      DO IG=1,JHG
        INDY1=INZH(1,IG)
        INDY2=INZH(2,IG)
        INDY3=INZH(3,IG)
        NZFF(IG) = INDY1 + (INDY2-1)*QR1S + (INDY3-1)*QR1S*QR2S
        INDY1=-INZH(1,IG)+NH1*2
        INDY2=-INZH(2,IG)+NH2*2-QR2MIN
        INDY3=-INZH(3,IG)+NH3*2-QR3MIN
        INZF(IG) = INDY1 + (INDY2-1)*QR1S + (INDY3-1)*QR1S*QR2S
      ENDDO
      NH1=LR1S/2+1
      NH2=LR2S/2+1
      NH3=LR3S/2+1
      NN2=QR2MAX-QR2MIN+1
#ifdef  _BGL 
!IBM* ASSERT (ITERCNT(10000))
#endif
!$OMP parallel do private(IG,INDY1,INDY2,INDY3)
      DO IG=1,JGW
        INDY1=INZH(1,IG)
        INDY2=INZH(2,IG)-QR2MIN
        INDY3=INZH(3,IG)-QR3MIN
        NZFS(IG) = INDY1 + INDY2*QR1 + INDY3*QR1*NN2
        INDY1=-INZH(1,IG)+NH1*2
        INDY2=-INZH(2,IG)+NH2*2-QR2MIN
        INDY3=-INZH(3,IG)+NH3*2-QR3MIN
        INZS(IG) = INDY1 + INDY2*QR1 + INDY3*QR1*NN2
      ENDDO
#endif
      CALL FREEM(IP_MG)
      CALL FREEM(IP_MY)
      CALL FREEM(IP_MZ)
#ifdef PARALLEL
      CALL FREEM(IP_MQ)
#endif
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
