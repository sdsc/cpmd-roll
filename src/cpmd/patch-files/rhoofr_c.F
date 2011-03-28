C     ==================================================================
      SUBROUTINE RHOOFR_C(C0,RHOE,PSI,SCR,LSCR,NSTATE)
C     ==--------------------------------------------------------------==
C     ==                        COMPUTES                              ==
C     ==  THE NORMALIZED ELECTRON DENSITY RHOE IN REAL SPACE          ==
C     ==  THE KINETIC ENERGY EKIN. IT IS DONE IN RECIPROCAL SPACE     ==
C     ==  WHERE THE ASSOCIATED OPERATORS ARE DIAGONAL.                ==
C     ==  RHOE IS OBTAINED FOURIER TRANSFORMING THE WFN TO REAL       ==
C     ==  SPACE (PSI).                                                ==
C     ==--------------------------------------------------------------==
C     ==  WARNING: IF YOU USE SPECIAL K-POINTS FOR A SPECIAL STRUCTURE==
C     ==           YOU NEED TO SYMMETRIZE CHARGE DENSITY              ==
C     ==           FOR THAT -> SPECIFY THE POINT GROUP                ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'spin.inc'
      INCLUDE 'elct.inc'
      INCLUDE 'cnst.inc'
      INCLUDE 'geq0.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'ener.inc'
      INCLUDE 'cppt.inc'
      INCLUDE 'sfac.inc'
      INCLUDE 'fft.inc'
      INCLUDE 'rswf.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'prcp.inc'
      INCLUDE 'ropt.inc'
      INCLUDE 'kpts.inc'
      INCLUDE 'kpnt.inc'
      INCLUDE 'symm.inc'
C     Arguments
      INTEGER    NSTATE,LSCR
      COMPLEX*16 C0(NGWK,NSTATE,NKPNT),PSI(MAXFFT*NOGRP)
      REAL*8     RHOE(NNR1,NLSD),SCR(LSCR)
C     Variables
      DIMENSION  F(NSTATE,NKPTS),WK(NKPTS),
     &           HGKP(NHG,NKPNT),HGKM(NHG,NKPNT)
      REAL*8     FNL(*),DFNL(*)
      REAL*8     RHOEG(*),PSIX(*)
      POINTER    (IP_RHOEG,RHOEG),(IP_PSIX,PSIX)
      INTEGER    ISUB,LEAD,LEADX,NNRX,IFFT,I,L,IS1,
     &           IG,ID,NSTA,IB,IBB,IWF,ISPIN1,IAT,IS,IA,LRHOOFR,
     &           KBEG,KEND,KINC,IKPT,NKPOINT,IKK,IKIND
      REAL*8     DDOT,DASUM,XKIN,SK1,XSKIN,ARGP,ARGM,G2P,G2M,
     &           COEF3,R1,R2,RSUM,RSUMV,RSUM1,RSUM1ABS
      EXTERNAL   DDOT,DASUM
      REAL*8     DELTA,DELTAKIN
      PARAMETER  (DELTA=1.D-6,DELTAKIN=1.D-10)
      CHARACTER  TAG*30
      LOGICAL    TFCAL
#ifdef PARALLEL
      INTEGER    MSGLEN,NL2,IX1,IXP,IX
#endif
#ifdef __DERF
      REAL*8     DERF
      EXTERNAL   DERF
#endif
C     ==--------------------------------------------------------------==
      CALL TISET('  RHOOFR_C',ISUB)
C     ==--------------------------------------------------------------==
C     Test on SCR dimension
      CALL GIVE_SCR_RHOOFR(LRHOOFR,TAG)
      CALL TEST_SCR('RHOOFR_C',TAG,LSCR,LRHOOFR)
C     ==--------------------------------------------------------------==
#ifdef PARALLEL
      IF(NOGRP.EQ.1) THEN
        LEAD  = KR1S*NGRAYS
        LEADX = NNR1
        IFFT=1
        NNRX=NNR1
      ELSE
        LEAD  = KR1S*NGRM
        LEADX = KRX*KR2S*KR3S
        IFFT=2
        NNRX=KRX*KR2S*KR3S
      ENDIF
#else
      LEAD  = NNR1
      LEADX = NNR1
      NNRX=NNR1
      IFFT=1
#endif
      CALL GET_ADDR(IP_PSIX,PSI(1))
      CALL GET_ADDR(IP_RHOEG,RHOE(1,1))
C     Initialize
      CALL AZZERO(RHOEG,NLSD*LEADX)
C     Accumulate the charge and kinetic energy
      RSUM=0.D0
      XKIN=0.D0
      CALL INQ_SWAP(KBEG,KEND,KINC)
      DO IKPT=KBEG,KEND,KINC
        NKPOINT=NKPBL(IKPT)
        IF(TKBLOCK) CALL RKPT_SWAP(C0,NSTATE,IKPT,'HGKP HGKM C0')
        DO IKIND = 1, NKPOINT
          IKK=KPBEG(IKPT)+IKIND
          DO I=1,NSTATE
            IF(F(I,IKK).NE.0.D0) THEN
              RSUM=RSUM+WK(IKK)*F(I,IKK)*
     &             DDOT(NGWK*2,C0(1,I,IKIND),1,C0(1,I,IKIND),1)
              SK1=0.0D0
              IF(AKIN.GT.DELTAKIN) THEN
                XSKIN=1.D0/GSKIN
                DO IG=1,NGW
                  ARGP=(HGKP(IG,IKIND)-GCKIN)*XSKIN
                  ARGM=(HGKM(IG,IKIND)-GCKIN)*XSKIN
                  G2P=HGKP(IG,IKIND)+GAKIN*(1.D0+DERF(ARGP))
                  G2M=HGKM(IG,IKIND)+GAKIN*(1.D0+DERF(ARGM))
                  SK1=SK1+G2P*ABS(C0(IG,I,IKIND))**2+
     &                 G2M*ABS(C0(IG+NGW,I,IKIND))**2
                ENDDO
              ELSE
                DO IG=1,NGW
                  SK1=SK1+HGKP(IG,IKIND)*ABS(C0(IG,I,IKIND))**2+
     &                 HGKM(IG,IKIND)*ABS(C0(IG+NGW,I,IKIND))**2
                ENDDO
              ENDIF
              XKIN=XKIN+0.5D0*WK(IKK)*F(I,IKK)*SK1
            ENDIF
          ENDDO
C         Loop over the electronic states
          DO ID=1,NSTATE,NOGRP
            NSTA=MIN(NSTATE-ID+1,NOGRP)
            TFCAL=RSACTIVE
            DO I=ID,ID+(NSTA-1)
              TFCAL=TFCAL.OR.(F(I,IKK).NE.0.D0)
            ENDDO
            IF(TFCAL) THEN
              CALL ZAZZERO(PSI,MAXFFT*NOGRP)
              DO IB=1,NSTA
                IS1=ID+(IB-1)
                IBB=(IB-1)*LEAD
#ifdef __SR8000
*poption parallel
#endif
#ifdef _vpp_
!OCL NOVREC(PSI)
#endif
!CDIR NODEP
                DO IG=1,NGW
                  PSI(NZHS(IG)+IBB)=C0(IG,IS1,IKIND)
                  PSI(INDZS(IG)+IBB)=C0(IG+NGW,IS1,IKIND)
                ENDDO
                IF(GEQ0) PSI(NZHS(1)+IBB)=C0(1,IS1,IKIND)
              ENDDO
C             Fourier transform the wave functions to real space.
              IF(IFFT.EQ.1) THEN
                CALL S_INVFFT(PSI)
              ELSE
                CALL SG_INVFFT(PSI)
              ENDIF
C             Store real space wavefunctions
              IF(RSACTIVE) THEN
                IF(NOGRP.EQ.1) THEN
                  IWF=ID+(IKIND-1)*NSTATE
                  IF(IWF.LE.MAXSTATES) THEN
                    CALL DCOPY(2*LEADX,PSI(1),1,RSWF(1,IWF),1)
                  ENDIF
                ELSE
                CALL STOPGM('RHOOFR_C','TASKGROUPS NOT IMPLEMENTED '
     &          // 'WITH "REAL SPACE WFN KEEP" AND K-POINTS')
                ENDIF
              ENDIF
C             Compute the charge density from the wave functions
C             in real space 
              IF(NOGRP.GT.1) THEN
                DO IB=1,NSTA
                  IF(NOLIST(IB).EQ.ME) THEN
                    IS1=ID+(IB-1)    
                  ENDIF
                ENDDO
              ELSE
                IS1=ID
              ENDIF
              COEF3=WK(IKK)*F(IS1,IKK)/OMEGA
              IF(COEF3.NE.0.D0) THEN
                IF(TLSD) THEN
                  ISPIN1=0
                  IF(IS1.GT.NSUP) ISPIN1=LEADX
#ifdef __SR8000
*poption parallel
#endif
                  DO L=1,NNRX
                    R1=DREAL(PSI(L))
                    R2=DIMAG(PSI(L))
                    RHOEG(L+ISPIN1)=RHOEG(L+ISPIN1)+COEF3*(R1*R1+R2*R2)
                  ENDDO
                ELSE
#ifdef __SR8000
*poption parallel
#endif
                  DO L=1,NNRX
                    R1=DREAL(PSI(L))
                    R2=DIMAG(PSI(L))
                    RHOEG(L)=RHOEG(L)+COEF3*(R1*R1+R2*R2)
                  ENDDO
                ENDIF
              ENDIF
            ENDIF               !Endif for TFCAL
          ENDDO                 !End loop over electronic states
        ENDDO                   !End loop over k points (IKIND)
      ENDDO                     !End loop over IKPT
C     ==--------------------------------------------------------------==
      EKIN=XKIN*TPIBA2
#ifdef PARALLEL
      IF(NOGRP.GT.1) THEN
C       Summation of density within orbital split
        NL2=NLINK(NOLIST(NOGRP))
        IX1=NRXPL(MEPOS,1)-NRXPL(NL2,1)
        MSGLEN= 8 * NNRX
        IF(TLSD) THEN
          CALL MY_COMBINE(RHOEG(1),PSIX(1),MSGLEN,1,MEOGRP)
          CALL AZZERO(RHOE(1,1),NNR1)
          DO IXP=1,NR1
            IX=IX1+IXP
            CALL DCOPY(KR2S*KR3S,PSIX(IX),KRX,RHOE(IXP,1),KR1)
          ENDDO
          CALL MY_COMBINE(RHOEG(LEADX+1),PSIX(1),MSGLEN,1,MEOGRP)
          CALL AZZERO(RHOE(1,2),NNR1)
          DO IXP=1,NR1
            IX=IX1+IXP
            CALL DCOPY(KR2S*KR3S,PSIX(IX),KRX,RHOE(IXP,2),KR1)
          ENDDO
        ELSE
          CALL MY_COMBINE(RHOEG,PSIX(1),MSGLEN,1,MEOGRP)
          CALL AZZERO(RHOE,NNR1)
          DO IXP=1,NR1
            IX=IX1+IXP
            CALL DCOPY(KR2S*KR3S,PSIX(IX),KRX,RHOE(IXP,1),KR1)
          ENDDO
        ENDIF
      ENDIF
#endif
C     ==--------------------------------------------------------------==
C     MOVE DENSITY ACCORDING TO MOVEMENT OF ATOMS
      IF(MODENS) CALL MOVERHO(RHOE,PSI,SCR,LSCR)
C     CONTRIBUTION OF THE VANDERBILT PP TO RHOE
      IF(TIVAN) THEN
        IF(TLSD) THEN
C         ALPHA SPIN
          CALL RHOV(NSTATE,1,NSUP,RSUMV,PSI,SCR,LSCR)
          RSUM=RSUM+OMEGA*RSUMV
          DO I=1,NNR1
            RHOE(I,1)=RHOE(I,1)+DREAL(PSI(I))
          ENDDO
C         BETA SPIN
          CALL RHOV(NSTATE,NSUP+1,NSTATE,RSUMV,PSI,SCR,LSCR)
          RSUM=RSUM+OMEGA*RSUMV
          DO I=1,NNR1
            RHOE(I,2)=RHOE(I,2)+DREAL(PSI(I))
          ENDDO
        ELSE
          CALL RHOV(NSTATE,1,NSTATE,RSUMV,PSI,SCR,LSCR)
          RSUM=RSUM+OMEGA*RSUMV
          DO I=1,NNR1
            RHOE(I,1)=RHOE(I,1)+DREAL(PSI(I))
          ENDDO
        ENDIF
C       Vanderbilt Charges
        IF(PARENT) THEN
          CALL AZZERO(SCR,NAT)
          CALL AUGCHG(FNL,F,SCR,NSTATE)
          IAT=0
          DO IS=1,NSP
            VDBCHG(IS)=0.0D0
            DO IA=1,NA(IS)
              IAT=IAT+1
              VDBCHG(IS)=VDBCHG(IS)+SCR(IAT)
            ENDDO
            VDBCHG(IS)=VDBCHG(IS)/NA(IS)
          ENDDO
        ENDIF
      ENDIF
C     ALPHA+BETA DENSITY IN RHOE(*,1), BETA DENSITY IN RHOE(*,2)
      IF(TLSD) THEN
        DO I=1,NNR1
          RHOE(I,1) = RHOE(I,1) + RHOE(I,2)
        ENDDO
      ENDIF
C     SYMMETRIZE DENSITY IF POINT GROUP SPECIFIED 
C     (NEED FOR SPECIAL K-POINTS).
      IF(TSYMRHO) THEN 
        IF(TLSD) THEN
          CALL SYMRHO(RHOE(1,1),PSI,SCR,LSCR)
          CALL SYMRHO(RHOE(1,2),PSI,SCR,LSCR)
        ELSE         
          CALL SYMRHO(RHOE(1,1),PSI,SCR,LSCR)
        ENDIF
      ENDIF
C     HERE TO CHECK THE INTEGRAL OF THE CHARGE DENSITY 
      RSUM1=DASUM(NNR1,RHOE(1,1),1)
      RSUM1=RSUM1*OMEGA/DBLE(NR1S*NR2S*NR3S)
      CSUMG=RSUM
      CSUMR=RSUM1
      IF(TLSD) THEN
        RSUM1=0.D0
        RSUM1ABS=0.D0
        DO I=1,NNR1
          RSUM1 = RSUM1 + RHOE(I,1)-2.D0*RHOE(I,2)
          RSUM1ABS = RSUM1ABS + ABS(RHOE(I,1)-2.D0*RHOE(I,2))
        ENDDO
        CSUMS=RSUM1*OMEGA/DBLE(NR1S*NR2S*NR3S)
        CSUMSABS=RSUM1ABS*OMEGA/DBLE(NR1S*NR2S*NR3S)
      ELSE
        CSUMS=0.D0
        CSUMSABS=0.D0
      ENDIF
      CALL GLOSUM(4,CSUMG)
      IF(PARENT.AND.ABS(CSUMR-CSUMG).GT.DELTA) THEN
        WRITE(*,'(A,T45,F20.12)') 'IN FOURIER SPACE:', CSUMG
        WRITE(*,'(A,T45,F20.12)') 'IN REAL SPACE:', CSUMR
        IF(INDPG.NE.0.AND.CDUAL.LT.4.D0)
     &       WRITE(*,*) 'YOUR DUAL NUMBER ',CDUAL,
     &       ' COULD BE TOO SMALL WITH DENSITY SYMMETRISATION'
        CALL STOPGM('RHOOFR','TOTAL DENSITY SUMS ARE NOT EQUAL')
        CALL STOPGM('RHOOFR_C','TOTAL DENSITY SUMS ARE NOT EQUAL')
      ENDIF
      CALL TIHALT('  RHOOFR_C',ISUB)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
