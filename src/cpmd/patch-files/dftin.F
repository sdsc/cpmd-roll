#ifdef __SR8000
*option MP(P(0)), LANGLVL(SAVE(0))
#endif
C     ==================================================================
      SUBROUTINE DFTIN
C     ==--------------------------------------------------------------==
C     ==  THIS ROUTINE READS THE SECTION &DFT &END ON UNIT IUNIT      ==
C     ==--------------------------------------------------------------==
C     ==  THE INPUT HAS TO BE IN THE FOLLOWING FORMAT                 ==
C     ==     &DFT                                                     ==
C     ==        Options                                               ==
C     ==     &END                                                     ==
C     ==--------------------------------------------------------------==
C     ==  LIST OF OPTIONS                                             ==
C     ==                                                              ==
C     ==    OLDCODE/NEWCODE                                           ==
C     ==    LDA CORRELATION functionals                               ==
C     ==    SLATER                                                    ==
C     ==      alpha                                                   ==
C     ==    GRADIENT CORRECTION functionals                           ==
C     ==    FUNCTIONAL {LDA,BONLY,BP,BLYP,GGA/PW91,PBE,REVPBE,HCTH,   ==
C     ==                OPTX,OLYP,XLYP}                               ==
C     ==    FUNCTIONAL {B3LYP,X3LYP,B1LYP,PBE0,PBE1W,PBES}            ==
C     ==    FUNCTIONAL {TPSS}                                         ==
C     ==    HARTREE                                                   ==
C     ==    HARTREE-FOCK                                              ==
C     ==    ACM0                                                      ==
C     ==    ACM1                                                      ==
C     ==      a1                                                      ==
C     ==    ACM3                                                      ==
C     ==      a1 a2 a3                                                ==
C     ==    LR KERNEL {NONE,LDA,...}                                  ==
C     ==    REFUNCT {LDA,BP,BLYP,PBE,OLYP}                            ==
C     ==    GC-CUTOFF                                                 ==
C     ==      gceps                                                   ==
C     ==    SMOOTH                                                    ==
C     ==      mf sdelta                                               ==
C     ==    [NO] EXCHANGE CORRELATION TABLE                           ==
C     ==      narray rmaxxc                                           ==
C     ==    BECKE BETA                                                ==
C     ==      beta                                                    ==
C     ==    SCREENED EXCHANGE [SELF] {EXP,ERFC}                       ==
C     ==      srxa                                                    ==
C     ==    WANNIER SCREENING [WFC,DENSITY,DIAG]                      ==
C     ==      dwfc dwfmax                                             ==
C     ==                                                              ==
C     ==    LDA functionals : NO,PZ,VWN,LYP,PW,WIGNER,HEDIN,          ==
C     ==                      OBPZ,OBPW,TETER                         ==
C     ==    Correlation functionals : PZ,VWN,LYP,PW,HCTH              ==
C     ==    Gradient correction functionals :                         ==
C     ==       EXCH, CORREL, BECKE88, GGAX, PERDEW86, LYP, GGAC,      ==
C     ==       PBEX, PBEC , HCTH/120, OPTX, OLYP,PBESC,PBESX          ==
C     ==                                                              ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'tbxc.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'func.inc'
      INCLUDE 'ener.inc'
      INCLUDE 'linres.inc'
      INCLUDE 'hfx.inc'
      INCLUDE 'wann.inc'
      INTEGER   IUNIT,IERR,INSCAN
      INTEGER   I,J,IA,IE,IUNK,MAXUNKNOWN
      PARAMETER (MAXUNKNOWN=30)
      CHARACTER*80 LINE,LINEOLD,UNKNOWN(MAXUNKNOWN)
      REAL*8 A1PAR,A2PAR,A3PAR
      LOGICAL   TREFF,TR_CODE
      INTEGER   TR_X,TR_C,TR_GX,TR_GC
#ifdef PARALLEL
      INTEGER   MSGLEN
#endif
C     ==--------------------------------------------------------------==
C     ==  DEFAULTS                                                    ==
C     ==--------------------------------------------------------------==
      CALL IAZZERO(IXCPAR,NLLI*MXCSET)
      CALL AZZERO(RXCPAR,NLLR*MXCSET)
      DO I=1,MXCSET
        DO J=1,NLLL
          LXCPAR(J,I)=.FALSE.
        ENDDO
      ENDDO
C     ==--------------------------------------------------------------==
      IF(.NOT.PARENT) GOTO 9999
      TREFF = .FALSE.
      IUNK = 0
      IUNIT = 5
      MFXCX = -1
      MFXCC = -1
      SALPHA = 2.D0/3.D0
      MGCX = 0
      MGCC = 0
      MHFX = 0
      MTAU = 0
      TGC=.FALSE.
      TGCX=.FALSE.
      TGCC=.FALSE.
      TTAU=.FALSE.
      THYBRID=.FALSE.
      TSMOOTH=.FALSE.
      TOLDCODE=.FALSE.
      PXLDA=1.D0
      PXGC=1.D0
      PCLDA=1.D0
      PCGC=1.D0
      PHFX=0.D0
      MSRX=0
      MSELF=0
      SRXA=0.D0
C     ==--------------------------------------------------------------==
      TD_X  = -1
      TD_C  = -1
      TD_GX = -1
      TD_GC = -1
      TD_HF = -1
      TD_MTAU = -1
      TD_TTAU=.FALSE.
      TD_TGC=.FALSE.
      TD_TGCX=.FALSE.
      TD_TGCC=.FALSE.
      TD_HYBRID=.FALSE.
      TD_CODE=.FALSE.
      TDPXLDA=1.D0
      TDPXGC=1.D0
      TDPCLDA=1.D0
      TDPCGC=1.D0
      TDPHFX=0.D0
C     ==--------------------------------------------------------------==
      TD_FUNCTIONAL=0
      TENERGY_OK=.TRUE.
C     ==--------------------------------------------------------------==
      GCEPS=1.0D-8
      NARRAY=0
      RMAXXC=2.0D0
      RMAXBX=100.0D0
      BBETA=0.0042D0
      BETAPP=0.0D0
C     ==--------------------------------------------------------------==
      TWSCR = .FALSE.
      TWFC  = .FALSE.
      TDEN  = .FALSE.
      TDIAW = .FALSE.
      DWFC  = 1.D10
      DWFMAX= 0.D0
C     ==--------------------------------------------------------------==
      IERR=INSCAN(IUNIT,'&DFT')
      IF(IERR.NE.0) GOTO 100
C     ==--------------------------------------------------------------==
      WRITE(LINE,'(80(" "))')
   10 CONTINUE
        LINEOLD=LINE
        READ(IUNIT,ERR=99,END=99,FMT='(A80)') LINE
        IF(INDEX(LINE,'&END').NE.0) GOTO 100
        IF(INDEX(LINE,'GRAD').NE.0 .AND. INDEX(LINE,'CORREC').NE.0) THEN
C..Gradient Correction
          TGC=.TRUE.
          IF(INDEX(LINE,'EXCH').NE.0) TGCX=.TRUE.
          IF(INDEX(LINE,'CORREL').NE.0) TGCC=.TRUE.
          IF(INDEX(LINE,'BECKE88').NE.0) MGCX=1
          IF((INDEX(LINE,'GGAX').NE.0).OR.
     &       (INDEX(LINE,'PW91X').NE.0)) MGCX=2
          IF((INDEX(LINE,'PBEX').NE.0).AND.
     &       .NOT.(INDEX(LINE,'REVPBEX').NE.0)) MGCX=3
          IF(INDEX(LINE,'REVPBEX').NE.0) MGCX=4
          IF((INDEX(LINE,'PBESX').NE.0))  MGCX=9
          IF(INDEX(LINE,'HCTH').NE.0) THEN
             TOLDCODE=.TRUE.
             MFXCX=0
             MFXCC=0
             MGCX=5
             MGCC=5
          ENDIF
          IF(INDEX(LINE,'OPTX').NE.0) THEN
             TOLDCODE=.TRUE.
             MFXCX=0
             MGCX=6
          ENDIF
          IF(INDEX(LINE,'PERDEW86').NE.0) MGCC=1
          IF(INDEX(LINE,'LYP').NE.0) MGCC=2
          IF((INDEX(LINE,'GGAC').NE.0).OR.
     &       (INDEX(LINE,'PW91C').NE.0)) MGCC=3
          IF((INDEX(LINE,'REVPBEC').NE.0)
     & .     OR.(INDEX(LINE,'PBEC').NE.0)) MGCC=4
          IF((INDEX(LINE,'PBESC').NE.0))  MGCC=7
          IF(.NOT.TGCX.AND..NOT.TGCC.AND.MGCX.EQ.0.AND.MGCC.EQ.0) THEN
            TGCX=.TRUE.
            TGCC=.TRUE.
          ENDIF
          IF(TGCX) MGCX=1
          IF(TGCC) MGCC=1
          IF(MGCX.GT.0) TGCX=.TRUE.
          IF(MGCC.GT.0) TGCC=.TRUE.
          GOTO 10
        ELSE IF(INDEX(LINE,'HARTREE').NE.0 .AND.
     *           INDEX(LINE,'FOCK').NE.0) THEN
          TGC=.FALSE.
          TGCX=.FALSE.
          TGCC=.FALSE.
          MFXCX=0
          MFXCC=0
          MGCX=0
          MGCC=0
          MHFX=1
          SALPHA=2.d0/3.d0
          GOTO 10
        ELSE IF(INDEX(LINE,'HARTREE').NE.0) THEN
          TGC=.FALSE.
          TGCX=.FALSE.
          TGCC=.FALSE.
          MFXCX=0
          MFXCC=0
          MGCX=0
          MGCC=0
          MHFX=2
          SALPHA=2.d0/3.d0
          GOTO 10
        ELSE IF(INDEX(LINE,'SLATER').NE.0) THEN
C..Slater exchange
          IF(INDEX(LINE,'NO').NE.0) THEN
            MFXCX=0
          ELSE
            MFXCX=1
            READ(IUNIT,ERR=99,END=99,FMT=*) SALPHA
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'LDA').NE.0 .AND.
     *           INDEX(LINE,'CORRELATION').NE.0) THEN
C..LDA Correlation functionals
          IF(INDEX(LINE,'NO').NE.0) THEN
            MFXCC=0
          ELSEIF(INDEX(LINE,'PZ').NE.0) THEN
            MFXCC=1
          ELSEIF(INDEX(LINE,'VWN').NE.0) THEN
            MFXCC=2
          ELSEIF(INDEX(LINE,'LYP').NE.0) THEN
            MFXCC=3
          ELSEIF(INDEX(LINE,'PW').NE.0) THEN
            MFXCC=4
          ELSEIF(INDEX(LINE,'WIGNER').NE.0) THEN
            MFXCC=5
          ELSEIF(INDEX(LINE,'HEDIN').NE.0) THEN
            MFXCC=6
          ELSEIF(INDEX(LINE,'OBPZ').NE.0) THEN
            MFXCC=7
          ELSEIF(INDEX(LINE,'OBPW').NE.0) THEN
            MFXCC=8
          ELSEIF(INDEX(LINE,'TETER').NE.0) THEN
            MFXCC=9
            MFXCX=0
          ELSEIF(INDEX(LINE,'HCTH').NE.0) THEN
            TOLDCODE=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=5
            MGCC=5
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'GC-CUTOFF').NE.0) THEN
C..Cutoff for the density for GC functionals
          READ(IUNIT,ERR=99,END=99,FMT=*) GCEPS
          GOTO 10
        ELSE IF(INDEX(LINE,'SCREE').NE.0.AND.
     *    INDEX(LINE,'EXCHANGE').NE.0) THEN
C..Short range exact exchange
          MSRX=1
          IF(INDEX(LINE,'EXP').NE.0) MSRX=1
          IF(INDEX(LINE,'ERFC').NE.0) MSRX=2
          IF(INDEX(LINE,'SELF').NE.0) MSELF=1
          READ(IUNIT,ERR=99,END=99,FMT=*) SRXA
          GOTO 10
        ELSE IF(INDEX(LINE,'BECKE').NE.0.AND.
     *           INDEX(LINE,'BETA').NE.0) THEN
C..Parameter value for Becke exchange
          READ(IUNIT,ERR=99,END=99,FMT=*) BBETA
          BETAPP=BBETA
          GOTO 10
        ELSE IF(INDEX(LINE,'SMOOTH').NE.0) THEN
C..Smoothing of the density
          TSMOOTH=.TRUE.
          READ(IUNIT,ERR=99,END=99,FMT=*) SMF,SDELTA
          GOTO 10
        ELSE IF(INDEX(LINE,'EXCH').NE.0 .AND.
     *   INDEX(LINE,'CORR').NE.0 .AND. INDEX(LINE,'TABL').NE.0) THEN
C..Tables for exchange and correlation
          IF(INDEX(LINE,'NO').NE.0) THEN
            NARRAY=0
            RMAXXC=1.0D0
          ELSE
            READ(IUNIT,ERR=99,END=99,FMT=*) NARRAY,RMAXXC
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'OLDCODE').NE.0) THEN
          TOLDCODE=.TRUE.
          GOTO 10
        ELSE IF(INDEX(LINE,'NEWCODE').NE.0) THEN
          TOLDCODE=.FALSE.
          GOTO 10
        ELSE IF(INDEX(LINE,'ACM0').NE.0) THEN
          TOLDCODE=.TRUE.
          THYBRID=.TRUE.
          PXLDA=0.75D0
          PXGC=0.75D0
          PCLDA=1.D0
          PCGC=1.D0
          PHFX=0.25D0
          GOTO 10
        ELSE IF(INDEX(LINE,'ACM1').NE.0) THEN
          READ(IUNIT,ERR=99,END=99,FMT=*) A1PAR
          TOLDCODE=.TRUE.
          THYBRID=.TRUE.
          PXLDA=1.D0-A1PAR
          PXGC=1.D0-A1PAR
          PCLDA=1.D0
          PCGC=1.D0
          PHFX=A1PAR
          GOTO 10
        ELSE IF(INDEX(LINE,'ACM3').NE.0) THEN
          READ(IUNIT,ERR=99,END=99,FMT=*) A1PAR,A2PAR,A3PAR
          TOLDCODE=.TRUE.
          THYBRID=.TRUE.
          PXLDA=1.D0-A1PAR
          PXGC=1.D0-A2PAR
          PCLDA=1.D0
          PCGC=1.D0-A3PAR
          PHFX=A1PAR
          GOTO 10
        ELSE IF(INDEX(LINE,'FUNCTIONAL').NE.0) THEN
          IF(INDEX(LINE,'NONE').NE.0) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
            MHFX=0
            SALPHA=2.d0/3.d0
          ELSEIF(INDEX(LINE,'SONLY').NE.0) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=1
            MFXCC=0
            MGCX=0
            MGCC=0
            MHFX=0
            SALPHA=2.d0/3.d0
          ELSEIF(INDEX(LINE,'LDA').NE.0) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=0
            MFXCC=9
            MGCX=0
            MGCC=0
            MHFX=0
            SALPHA=2.d0/3.d0
          ELSEIF(INDEX(LINE,'BONLY').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.FALSE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=1
            MGCC=0
            MHFX=0
          ELSEIF(INDEX(LINE,'BP').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=1
            MGCC=1
            MHFX=0
          ELSEIF(INDEX(LINE,'BLYP').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=3
            MGCX=1
            MGCC=2
            MHFX=0
          ELSEIF(INDEX(LINE,'XLYP').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=3
            MGCX=7
            MGCC=2
            MHFX=0
          ELSEIF((INDEX(LINE,'GGA').NE.0).OR.
     *              (INDEX(LINE,'PW91').NE.0)) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=2
            MGCC=3
            MHFX=0
          ELSEIF(INDEX(LINE,'PBE1W').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=1
            MGCX=3
            MGCC=6
            MHFX=0
          ELSEIF(INDEX(LINE,'REVPBE').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=4
            MGCC=4
            MHFX=0
          ELSEIF(INDEX(LINE,'PBE0').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=2
            MGCX=3
            MGCC=4
            MHFX=1
            PXLDA=0.75D0
            PXGC=0.75D0
            PCLDA=1.D0
            PCGC=1.D0
            PHFX=0.25D0
          ELSEIF(INDEX(LINE,'PBES').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=9
            MGCC=7
            MHFX=0
          ELSEIF(INDEX(LINE,'PBE').NE.0) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            SALPHA=2.d0/3.d0
            MFXCC=9
            MGCX=3
            MGCC=4
            MHFX=0
          ELSEIF(INDEX(LINE,'HCTH').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=5
            MGCC=5
            MHFX=0
          ELSEIF(INDEX(LINE,'OPTX').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=6
            MGCC=6
            MHFX=0
          ELSEIF(INDEX(LINE,'OLYP').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=3
            MGCX=6
            MGCC=2
            MHFX=0
          ELSEIF(INDEX(LINE,'X3LYP').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=1
            MGCX=8
            MGCC=2
            MHFX=1
            PXLDA=0.782D0
            PXGC=1.D0
            PCLDA=1.D0
            PCGC=0.871D0
            PHFX=0.218D0
          ELSEIF(INDEX(LINE,'B3LYP').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=1
            MGCX=1
            MGCC=2
            MHFX=1
            PXLDA=0.8D0
            PXGC=0.72D0
            PCLDA=1.D0
            PCGC=0.81D0
            PHFX=0.2D0
          ELSEIF(INDEX(LINE,'B1LYP').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            SALPHA=2.d0/3.d0
            MFXCC=1
            MGCX=1
            MGCC=2
            MHFX=1
            PXLDA=0.75D0
            PXGC=0.75D0
            PCLDA=1.D0
            PCGC=1.D0
            PHFX=0.25D0
          ELSEIF(INDEX(LINE,'TPSS').NE.0) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            TTAU=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
            MTAU=1
            MHFX=0
          ELSEIF(INDEX(LINE,'SAOP').NE.0) THEN
            TD_FUNCTIONAL=10
            CALL TDM_FUN(TD_FUNCTIONAL,1)
            TENERGY_OK=.FALSE.
          ELSEIF(INDEX(LINE,'LB94').NE.0) THEN
            TD_FUNCTIONAL=11
            CALL TDM_FUN(TD_FUNCTIONAL,1)
            TENERGY_OK=.FALSE.
          ELSEIF(INDEX(LINE,'GLLB').NE.0) THEN
            TD_FUNCTIONAL=12
            CALL TDM_FUN(TD_FUNCTIONAL,1)
            TENERGY_OK=.FALSE.
          ELSE
            WRITE(*,*) ' DFTIN : FUNCTIONAL NOT AVAILABLE'
            WRITE(*,*) ' DFTIN : ',LINE
            CALL STOPGM('DFTIN',' ')
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'REFUNCT').NE.0) THEN
          TREFF=.TRUE.
          TR_X=0
          TR_C=9
          TR_GX=0
          TR_GC=0
          TR_CODE=.FALSE.
          IF(INDEX(LINE,'LDA').NE.0) THEN
            TR_X=0
            TR_C=9
            TR_GX=0
            TR_GC=0
            TR_CODE=.FALSE.
          ELSEIF(INDEX(LINE,'PBE').NE.0) THEN
            TR_X=0
            TR_C=9
            TR_GX=3
            TR_GC=4
            TR_CODE=.FALSE.
          ELSEIF(INDEX(LINE,'BLYP').NE.0) THEN
            TR_X=1
            TR_C=3
            TR_GX=1
            TR_GC=2
            TR_CODE=.FALSE.
          ELSEIF(INDEX(LINE,'OLYP').NE.0) THEN
            TR_X=0
            TR_C=3
            TR_GX=6
            TR_GC=2
            TR_CODE=.TRUE.
          ELSEIF(INDEX(LINE,'BP').NE.0) THEN
            TR_X=0
            TR_C=9
            TR_GX=1
            TR_GC=1
            TR_CODE=.FALSE.
          ELSE
            WRITE(*,*) ' DFTIN : REFERENCE FUNCTIONAL NOT AVAILABLE'
            CALL STOPGM('DFTIN',' ')
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'LR KERNEL').NE.0) THEN
          IF(INDEX(LINE,'NONE').NE.0) THEN
            TD_TGC=.FALSE.
            TD_TGCX=.FALSE.
            TD_TGCC=.FALSE.
            TD_X=0
            TD_C=0
            TD_GX=0
            TD_GC=0
            TD_HF=0
            TD_MTAU=0
            TD_CODE=.FALSE.
          ELSEIF(INDEX(LINE,'PBE0').NE.0) THEN
            TD_CODE=.TRUE.
            TD_TGC=.TRUE.
            TD_TGCX=.TRUE.
            TD_TGCC=.TRUE.
            TD_HYBRID=.TRUE.
            TD_X=1
            TD_C=2
            TD_GX=3
            TD_GC=4
            TD_HF=1
            TDPXLDA=0.75D0
            TDPXGC=0.75D0
            TDPCLDA=1.D0
            TDPCGC=1.D0
            TDPHFX=0.25D0
          ELSEIF(INDEX(LINE,'PBE').NE.0) THEN
            TD_TGC=.TRUE.
            TD_TGCX=.TRUE.
            TD_TGCC=.TRUE.
            TD_X=0
            TD_C=9
            TD_GX=3
            TD_GC=4
            TD_HF=0
            TD_MTAU=0
            TD_CODE=.FALSE.
          ELSEIF(INDEX(LINE,'LDA').NE.0) THEN
            TD_TGC=.FALSE.
            TD_TGCX=.FALSE.
            TD_TGCC=.FALSE.
            TD_X=0
            TD_C=9
            TD_GX=0
            TD_GC=0
            TD_HF=0
            TD_MTAU=0
            TD_CODE=.FALSE.
          ELSE
            WRITE(*,*) ' DFTIN : TDDFT KERNEL FUNCTIONAL NOT AVAILABLE'
            CALL STOPGM('DFTIN',' ')
          ENDIF
          GOTO 10
        ELSEIF(INDEX(LINE,'WANNIER').NE.0 .AND.
     &         INDEX(LINE,'SCREEN').NE.0) THEN
          TWSCR=.TRUE.
          DWFMAX=1.D-8
          IF(INDEX(LINE,'WFC').NE.0) TWFC=.TRUE.
          IF(INDEX(LINE,'DENSITY').NE.0) TDEN=.TRUE.
          IF(INDEX(LINE,'DIAG').NE.0) TDIAW=.TRUE.
          IF(TWFC.AND.TDEN) THEN
            READ(IUNIT,ERR=99,END=99,FMT=*) DWFC,DWFMAX
          ELSEIF(TWFC) THEN
            READ(IUNIT,ERR=99,END=99,FMT=*) DWFC
          ELSEIF(TDEN) THEN
            READ(IUNIT,ERR=99,END=99,FMT=*) DWFMAX
          ELSE
            TDEN=.TRUE.
          ENDIF
          IF(TDIAW) THEN
            TWFC=.FALSE.
            TDEN=.FALSE.
          ENDIF
          GOTO 10
        ELSE 
C         Unknown Keyword. store and continue
          IF(' '.NE.LINE) THEN
            IF(IUNK.LT.MAXUNKNOWN) THEN
              IUNK=IUNK+1
              UNKNOWN(IUNK)=LINE
            ELSE
              DO I=1,MAXUNKNOWN-1
                UNKNOWN(I)=UNKNOWN(I+1)
              ENDDO
              UNKNOWN(IUNK)=LINE
            ENDIF
          ENDIF
          GOTO 10
        ENDIF
C     ==--------------------------------------------------------------==
   99 CONTINUE
      WRITE(*,*) ' DFTIN:   ERROR IN READING INPUT FILE'
      WRITE(*,*) ' THE LAST TWO LINES READ WERE '
      CALL XSTRING(LINEOLD,IA,IE)
      WRITE(*,*) LINEOLD(1:IE)
      CALL XSTRING(LINE,   IA,IE)
      WRITE(*,*) LINE(1:IE)
      CALL STOPGM('DFTIN',' ')
C     ==--------------------------------------------------------------==
  100 CONTINUE
C     ==--------------------------------------------------------------==
C     ==  Test of options                                             ==
C     ==--------------------------------------------------------------==
      IF(THYBRID) THEN
        TOLDCODE=.TRUE.
        NARRAY=0
        RMAXXC=1.0D0
      ENDIF
      IF(MFXCX.LT.0) THEN
        MFXCX=0
        IF(TOLDCODE) MFXCX=1
      ENDIF
      IF(MFXCC.LT.0) THEN
        MFXCC=9
        IF(TOLDCODE) MFXCC=1
      ENDIF
      IF(MGCC.EQ.2) MFXCC=3
      IF(MFXCC.EQ.9.AND.MFXCX.NE.0) CALL STOPGM('DFTIN','FUNCTIONALS')
      IF(TOLDCODE) THEN
        IF(MFXCC.EQ.9.AND.(MGCC.EQ.3 .OR. MGCC.EQ.4)) THEN
          MFXCC=1
          MFXCX=1
        ENDIF
      ENDIF
      IF(MGCC.EQ.2.AND.MFXCC.NE.3) THEN
        WRITE(6,'(A)') 
     &        ' WARNING: INCONSISTENT DEFINITION OF LYP FUNCTIONAL '
      ENDIF
      IF( MFXCX.EQ.0 .AND. MFXCC.EQ.3 .AND. MGCC.EQ.2 .AND.
     &    .NOT.TOLDCODE ) THEN
          WRITE(*,'(A)') ' IF YOU REALLY WANT TO USE THIS FUNCTIONAL '
          WRITE(*,'(A)') ' (LYP WITHOUT SLATER EXCHANGE) USE THE'
          WRITE(*,'(A)') ' OLDCODE OPTION '
          WRITE(*,'(A)') ' BUT MOST LIKELY THIS IS A INPUT ERROR '
          WRITE(*,'(A)') ' SEE THE MANUAL ON HOW TO SPECIFY'
          WRITE(*,'(A)') ' THE LYP FUNCTIONAL'
          CALL STOPGM('DFTIN','FUNCTIONALS')
      ENDIF
      IF(NARRAY.EQ.1) NARRAY=0
      IF(TWSCR.AND.MHFX.EQ.0) TWSCR=.FALSE.
C     ==--------------------------------------------------------------==
      IXCPAR(1,IFXC0) = MFXCX
      IXCPAR(2,IFXC0) = MFXCC
      IXCPAR(3,IFXC0) = MGCX
      IXCPAR(4,IFXC0) = MGCC
      IXCPAR(5,IFXC0) = MHFX
      IXCPAR(6,IFXC0) = MTAU
      LXCPAR(1,IFXC0) = TGC
      LXCPAR(2,IFXC0) = TGCX
      LXCPAR(3,IFXC0) = TGCC
      LXCPAR(4,IFXC0) = TOLDCODE
      LXCPAR(5,IFXC0) = THYBRID
      LXCPAR(6,IFXC0) = TTAU
      RXCPAR(1,IFXC0) = PXLDA
      RXCPAR(2,IFXC0) = PCLDA
      RXCPAR(3,IFXC0) = PXGC
      RXCPAR(4,IFXC0) = PCGC
      RXCPAR(5,IFXC0) = PHFX
C     ==--------------------------------------------------------------==
C     TDDFT KERNEL
      IF(TD_X.LT.0 .OR. TD_C.LT.0 .OR. TD_GX.LT.0 .OR. TD_GC.LT.0) THEN
        TD_X = MFXCX
        TD_C = MFXCC
        TD_GX = MGCX
        TD_GC = MGCC
        TD_HF = MHFX
        TD_TGC = TGC
        TD_TGCX = TGCX
        TD_TGCC = TGCC
        TD_CODE = TOLDCODE
        TD_HYBRID = THYBRID
        TDPXLDA=PXLDA
        TDPXGC=PXGC
        TDPCLDA=PCLDA
        TDPCGC=PCGC 
        TDPHFX=PHFX
      ENDIF
      IXCPAR(1,IFXCK) = TD_X
      IXCPAR(2,IFXCK) = TD_C
      IXCPAR(3,IFXCK) = TD_GX
      IXCPAR(4,IFXCK) = TD_GC
      IXCPAR(5,IFXCK) = TD_HF
      IXCPAR(6,IFXCK) = TD_MTAU
      LXCPAR(1,IFXCK) = TD_TGC
      LXCPAR(2,IFXCK) = TD_TGCX
      LXCPAR(3,IFXCK) = TD_TGCC
      LXCPAR(4,IFXCK) = TD_CODE
      LXCPAR(5,IFXCK) = TD_HYBRID
      LXCPAR(6,IFXCK) = .FALSE.
      RXCPAR(1,IFXCK) = TDPXLDA
      RXCPAR(2,IFXCK) = TDPCLDA
      RXCPAR(3,IFXCK) = TDPXGC
      RXCPAR(4,IFXCK) = TDPCGC
      RXCPAR(5,IFXCK) = TDPHFX
C     ==--------------------------------------------------------------==
      IF(TREFF) THEN
        IXCPAR(1,IFXCR) = TR_X
        IXCPAR(2,IFXCR) = TR_C
        IXCPAR(3,IFXCR) = TR_GX
        IXCPAR(4,IFXCR) = TR_GC
        LXCPAR(1,IFXCR) = (TR_GX.NE.0) .OR. (TR_GC.NE.0)
        LXCPAR(2,IFXCR) = TR_GX.NE.0
        LXCPAR(3,IFXCR) = TR_GC.NE.0
        LXCPAR(4,IFXCR) = TR_CODE
      ELSE
        IXCPAR(1,IFXCR) = -100
      ENDIF
C     ==--------------------------------------------------------------==
C     ==  WRITE INFO TO OUTPUT                                        ==
C     ==--------------------------------------------------------------==
      WRITE(6,*)
      WRITE(6,'(A)') ' EXCHANGE CORRELATION FUNCTIONALS '
      IF(TD_FUNCTIONAL.NE.0) THEN
        WRITE(6,'(A)') ' EXCHANGE CORRELATION POTENTIAL METHOD '
        WRITE(6,'(A)') 
     &         ' WARNING: NO CORRESPONDING ENERGY FUNCTIONAL AVAILABLE'
        IF(TD_FUNCTIONAL.EQ.10) THEN
           WRITE(6,'(A)') ' SAOP POTENTIAL (modified)'
        ELSEIF(TD_FUNCTIONAL.EQ.11) THEN
           WRITE(6,'(A)') ' LB94 POTENTIAL (modified)'
        ELSEIF(TD_FUNCTIONAL.EQ.12) THEN
           WRITE(6,'(A)') ' GLLB POTENTIAL (modified)'
        ENDIF
      ELSEIF(THYBRID) THEN
        WRITE(6,'(A)') ' HYBRID FUNCTIONAL   '
        IF(MFXCX.EQ.0) THEN
          WRITE(6,'(A,T62,A4)') '    LDA EXCHANGE:','NONE'
        ELSEIF(MFXCX.EQ.1) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA EXCHANGE:','SLATER',PXLDA
        ENDIF
        IF(MFXCC.EQ.0) THEN
          WRITE(6,'(A,T62,A4)') '    LDA CORRELATION:','NONE'
        ELSEIF(MFXCC.EQ.1) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA CORRELATION:','PERDEW & ZUNGER',PCLDA
        ELSEIF(MFXCC.EQ.2) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA CORRELATION:','VWN',PCLDA
          IF(TLSD) THEN
            CALL STOPGM('LSD_VWN','NOT PROGRAMMED')
          ENDIF
        ELSEIF(MFXCC.EQ.3) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA CORRELATION:','LYP',PCLDA
        ELSEIF(MFXCC.EQ.4) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA CORRELATION:','PERDEW & WANG',PCLDA
          IF(TLSD) THEN
            CALL STOPGM('LSD_PW','NOT PROGRAMMED')
          ENDIF
        ELSEIF(MFXCC.EQ.9) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    LDA CORRELATION:','PADE',PCLDA
        ENDIF
        IF(MGCX.EQ.1) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','BECKE88',PXGC
        ELSEIF(MGCX.EQ.2) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','PERDEW-WANG',PXGC
        ELSEIF(MGCX.EQ.3) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','PBE',PXGC
        ELSEIF(MGCX.EQ.4) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','revPBE',PXGC
        ELSEIF(MGCX.EQ.5) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','HCTH',PXGC
        ELSEIF(MGCX.EQ.6) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','OPTX',PXGC
        ELSEIF(MGCX.EQ.7) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','X(0.722 B88 + 0.347 PW91)',PXGC
        ELSEIF(MGCX.EQ.8) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','X(0.542 B88 + 0.167 PW91)',PXGC
        ENDIF
        IF(MGCC.EQ.1) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','PERDEW86',PCGC
        ELSEIF(MGCC.EQ.2) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','LYP',PCGC
        ELSEIF(MGCC.EQ.3) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','PERDEW-WANG',PCGC
        ELSEIF(MGCC.EQ.4) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','PBE',PCGC
        ELSEIF(MGCC.EQ.5) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC EXCHANGE:','HCTH',PCGC
        ELSEIF(MGCC.EQ.6) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','PBE1W',PCGC
        ELSEIF(MGCC.EQ.7) THEN
          WRITE(6,'(A,T40,A,T58,F8.2)') 
     &       '    GC CORRELATION:','PBES',PCGC
        ENDIF
        IF(MHFX.EQ.1) THEN
          WRITE(6,'(A,T58,F8.2)') '    HARTREE-FOCK EXCHANGE:',PHFX
        ELSEIF(MHFX.EQ.2) THEN
          WRITE(6,'(A,T58,F8.2)') '    HARTREE CORRECTION:',PHFX
        ENDIF
      ELSEIF(MHFX.EQ.0) THEN
        IF(MFXCX.EQ.0) THEN
          WRITE(6,'(A,T62,A4)') '    LDA EXCHANGE:','NONE'
        ELSEIF(MFXCX.EQ.1) THEN
          WRITE(6,'(A,T42,A15,F8.5,A1)') 
     &         '    LDA EXCHANGE:','SLATER (ALPHA =',SALPHA,')'
        ENDIF
        IF(MFXCC.EQ.0) THEN
          WRITE(6,'(A,T62,A4)') '    LDA CORRELATION:','NONE'
        ELSEIF(MFXCC.EQ.1) THEN
          WRITE(6,'(A,T51,A15,/,A)')
     &         '    LDA CORRELATION:','PERDEW & ZUNGER',
     &         '       [J.P. PERDEW AND A ZUNGER, PRB 23 5048 (1981)]'
        ELSEIF(MFXCC.EQ.2) THEN
          WRITE(6,'(A,T46,A20,/,2A)') 
     &         '    LDA CORRELATION:','VOSKO, WILK & NUSAIR',
     &         '       [S.H. VOSKO, L. WILK, AND M. NUSAIR,',
     &         ' CAN. J. PHYS. 58 1200 (1980)]'
          IF(TLSD) THEN
            CALL STOPGM('LSD_VWN','NOT PROGRAMMED')
          ENDIF
        ELSEIF(MFXCC.EQ.3) THEN
          WRITE(6,'(A,T50,A16,/,2A)')
     &         '    LDA CORRELATION:','LEE, YANG & PARR',
     &         '       [C.L. LEE, W. YANG, AND R.G. PARR, PRB 37 785',
     &         ' (1988)]'
        ELSEIF(MFXCC.EQ.4) THEN
          WRITE(6,'(A,T53,A13,/,A)')
     &         '    LDA CORRELATION:','PERDEW & WANG',
     &         '       [J.P. PERDEW AND Y. WANG, PRB 45 13244 (1992)]'
          IF(TLSD) THEN
            CALL STOPGM('LSD_PW','NOT PROGRAMMED')
          ENDIF
        ELSEIF(MFXCC.EQ.9) THEN
          WRITE(6,'(A,/,A)') '    LDA XC THROUGH PADE APPROXIMATION',
     &         '    S.GOEDECKER, J.HUTTER, M.TETER PRB 54 1703 (1996)'
        ELSEIF(MFXCC.EQ.10) THEN
          WRITE(6,'(A)') ' +++++++++++++ WARNING LYP+VWN'
          IF(TLSD) THEN
            CALL STOPGM('LSD_VWN','NOT PROGRAMMED')
          ENDIF
        ENDIF
        IF(TGCC .OR. TGCX) THEN
          WRITE(6,'(A,/,A,T51,1PE15.5)')
     &         '    GRADIENT CORRECTED FUNCTIONAL',
     &         '    DENSITY THRESHOLD: ',GCEPS
        ENDIF
        IF(TGCX) THEN
          IF(MGCX.EQ.1) THEN
            WRITE(6,'(A,/,A,/,A,T56,F10.6)')
     &        '    EXCHANGE ENERGY',
     &        '       [A.D. BECKE, PHYS. REV. A 38, 3098 (1988)]',
     &        '       PARAMETER BETA:',BBETA
          ELSEIF(MGCX.EQ.2) THEN
            WRITE(6,'(A,/,A,A)') '    EXCHANGE ENERGY',
     &        '       [GGA: J.P. PERDEW ET AL. PHYS. REV. B 46, 6671',
     &        ' (1992)]'
          ELSEIF(MGCX.EQ.3) THEN
            WRITE(6,'(A,/,A)') '    EXCHANGE ENERGY',
     &        '       [PBE: J.P. PERDEW ET AL. PRL 77, 3865 (1996)]'
          ELSEIF(MGCX.EQ.4) THEN
            WRITE(6,'(A,A)') '    EXCHANGE ENERGY    ',
     &     ' [revPBE: Y. ZHANG ET AL. PRL 80, 890 (1998)]'
          ELSEIF(MGCX.EQ.5) THEN
            WRITE(6,'(A,A)') '    HCTH/120 XC FUNCTIONAL ',
     *     ' [HCTH: N.C. HANDY ET AL. JCP 109, 6264 (1998)]'
          ELSEIF(MGCX.EQ.6) THEN
            WRITE(6,'(A,A)') '    OPTX XC FUNCTIONAL ',
     *     ' [OPTX: N.C. HANDY ET AL. JCP 116, 5411 (2002)]'
          ELSEIF(MGCX.EQ.7 .OR. MGCX.EQ.8) THEN
            WRITE(6,'(A,A)') '    EXCHANGE ENERGY    ',
     *     ' [XIN XU and GODDARD PNAS 101, 2673 (2004)]'
          ELSEIF(MGCX.EQ.9) THEN
            WRITE(6,'(A,A)') '    PBEsol  XC FUNCTIONAL ',
     *     ' [PBEsol: J.P. PERDEW et al (2007) ]'
          ENDIF
        ENDIF
        IF(TGCC) THEN
          IF(MGCC.EQ.1) THEN
            WRITE(6,'(A,/,A)') '    CORRELATION ENERGY',
     &        '       [J.P. PERDEW, PHYS. REV. B 33, 8822 (1986)]'
          ELSEIF(MGCC.EQ.2) THEN
            WRITE(6,'(A,/,A)') '    CORRELATION ENERGY',
     &       '       [LYP: C.L. LEE ET AL. PHYS. REV. B 37, 785 (1988)]'
          ELSEIF(MGCC.EQ.3) THEN
            WRITE(6,'(A,/,A)') '    CORRELATION ENERGY ',
     &        '       [GGA: J.P. PERDEW ET AL. PHYS. REV. B 46, 6671',
     &        ' (1992)]'
            IF(tlsd) THEN
              CALL STOPGM('LSD_GGAC','NOT PROGRAMMED')
            ENDIF
          ELSEIF(MGCC.EQ.4) THEN
            WRITE(6,'(A,/,A)') '    CORRELATION ENERGY ',
     &        '       [PBE: J.P. PERDEW ET AL. PRL 77, 3865 (1996)]'
          ELSEIF(MGCC.EQ.5) THEN
            WRITE(6,'(A,A)') '                       '
          ELSEIF(MGCC.EQ.7) THEN
            WRITE(6,'(A,A)') '    PBEsol  XC FUNCTIONAL ',
     *     ' [PBEsol: J.P. PERDEW et al (2007) ]'
          ENDIF
        ENDIF
        IF(TTAU) THEN
          IF(MTAU.EQ.1) THEN
            WRITE(6,'(A)') '    META FUNCTIONAL TPSS'
          ENDIF
        ENDIF
      ELSEIF(MHFX.EQ.2) THEN
        WRITE(6,'(T37,A)') 'ORTHOGONALIZED HARTREE METHOD'
      ELSEIF(MHFX.EQ.1) THEN
        IF(MAX(TD_X,TD_C,TD_GX,TD_GC).EQ.0) THEN
          WRITE(6,'(T47,A)') 'HARTREE-FOCK METHOD'
        ENDIF
      ENDIF
      IF(MSRX.NE.0.AND.MHFX.NE.0) THEN
        IF(MSRX.EQ.1) THEN
          WRITE(6,'(T25,A)') 
     &      'SCREENED EXACT EXCHANGE USING EXP(-A*R)/R'
        ELSEIF(MSRX.EQ.2) THEN
          WRITE(6,'(T25,A)') 
     &      'SCREENED EXACT EXCHANGE USING ERFC(A*R)/R'
        ELSE
          CALL STOPGM('DFTIN','MSRX/=1 or 2')
        ENDIF
        IF(MSELF.NE.0) THEN
          WRITE(6,'(T42,A)') 'ONLY SCREEN SELF EXCHANGE'
        ENDIF
        WRITE(6,'(T24,A,T57,F9.3)') 
     &      ' SCREENING PARAMETER [BOHR^-1]:',SRXA
      ENDIF
      IF(MHFX.NE.0 .AND. TWSCR) THEN
        IF(TWFC) 
     &     WRITE(6,'(A,T56,F10.3)') 
     &     ' SCREENING RADIUS FOR WANNIER CENTERS IN HFX[BOHR] ',DWFC
        IF(TDEN) 
     &     WRITE(6,'(A,T56,G10.3)') 
     &     ' SCREENING THRESHOLD FOR OVERLAP DENSITY IN HFX ',DWFMAX
        IF(TDIAW) WRITE(6,'(A)') ' DIAGONAL SCREENING IN HFX '
      ENDIF
      IF(TSMOOTH) THEN
        WRITE(6,'(A,F6.4,A,F6.4)') ' SMOOTHING OF DENSITY: ALPHA=',
     &      SMF,'  BETA=',SDELTA
      ENDIF
      WRITE(6,*)
      IF(TD_X.NE.MFXCX .OR. TD_C.NE.MFXCC .OR. 
     &   TD_GX.NE.MGCX .OR. TD_GC.NE.MGCC .OR.TD_HF.NE.MHFX) THEN
        WRITE(6,'(A)') ' FUNCTIONAL FOR XC KERNEL IN LINEAR RESPONSE'
        IF(MAX(TD_X,TD_C,TD_GX,TD_GC,TD_HF).EQ.0) THEN
          WRITE(6,'(T60,A)') 'NONE'
        ENDIF
        IF(TD_C.EQ.9) THEN
          WRITE(6,'(A,/,A)') '    LDA XC THROUGH PADE APPROXIMATION',
     &        '    S.GOEDECKER, J.HUTTER, M.TETER PRB 54 1703 (1996)'
        ENDIF
        IF(TD_GX.EQ.3) THEN
            WRITE(6,'(A,/,A)') '    EXCHANGE ENERGY',
     &        '       [PBE: J.P. PERDEW ET AL. PRL 77, 3865 (1996)]'
        ENDIF
        IF(TD_GC.EQ.4) THEN
            WRITE(6,'(A,/,A)') '    CORRELATION ENERGY',
     &        '       [PBE: J.P. PERDEW ET AL. PRL 77, 3865 (1996)]'
        ENDIF
        WRITE(6,*)
      ENDIF
      IF(TREFF) THEN
        IF(TR_X.EQ.0.AND.TR_C.EQ.9.AND.TR_GX.EQ.0.AND.TR_GC.EQ.0) THEN
          WRITE(6,'(A,T62,A,/)') ' REFERENCE FUNCTIONAL: ',' LDA'
        ELSEIF
     *    (TR_X.EQ.0.AND.TR_C.EQ.9.AND.TR_GX.EQ.3.AND.TR_GC.EQ.4) THEN
          WRITE(6,'(A,T62,A,/)') ' REFERENCE FUNCTIONAL: ',' PBE'
        ELSEIF
     *    (TR_X.EQ.1.AND.TR_C.EQ.3.AND.TR_GX.EQ.1.AND.TR_GC.EQ.2) THEN
          WRITE(6,'(A,T62,A,/)') ' REFERENCE FUNCTIONAL: ',' BLYP'
        ELSEIF
     *    (TR_X.EQ.0.AND.TR_C.EQ.3.AND.TR_GX.EQ.6.AND.TR_GC.EQ.2) THEN
          WRITE(6,'(A,T62,A,/)') ' REFERENCE FUNCTIONAL: ',' OLYP'
        ELSEIF
     *    (TR_X.EQ.0.AND.TR_C.EQ.9.AND.TR_GX.EQ.1.AND.TR_GC.EQ.1) THEN
          WRITE(6,'(A,T62,A,/)') ' REFERENCE FUNCTIONAL: ',' BP'
        ELSE
          WRITE(6,'(A)') ' REFERENCE FUNCTIONAL NOT AVAILABLE'
          CALL STOPGM('DFTIN','REFUNCT')
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      IF(IUNK.NE.0) THEN
        WRITE(*,'(/,1X,64("="))')
        WRITE(*,'(1X,A,14X,A,14X,A)') '= ',
     &    'UNKNOWN KEYWORDS IN SECTION &DFT','='
        DO I=1,IUNK
          LINEOLD=UNKNOWN(I)
          CALL XSTRING(LINEOLD,IA,IE)
          WRITE(*,'(A,A)') ' = ',LINEOLD(IA:IE)
        ENDDO
      WRITE(*,'(1X,64("="),/)')
      ENDIF
C     ==--------------------------------------------------------------==
 9999 CONTINUE
#ifdef PARALLEL
C..CNTL
      MSGLEN = MLOGO * 8/IRAT
      CALL MY_BCAST(CNTL1,MSGLEN,SOURCE,ALLGRP)
C..CNTI
      MSGLEN = MINTE * 8/IRAT
      CALL MY_BCAST(CNTI1,MSGLEN,SOURCE,ALLGRP)
C..CNTR
      MSGLEN = MREAL * 8
      CALL MY_BCAST(CNTR1,MSGLEN,SOURCE,ALLGRP)
C..TABX
      MSGLEN = 1 * 8/IRAT
      CALL MY_BCAST(TOLDCODE,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 5 * 8
      CALL MY_BCAST(RMAXXC,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 1 * 8/IRAT
      CALL MY_BCAST(NARRAY,MSGLEN,SOURCE,ALLGRP)
C..FUNC
      MSGLEN = 4 * 8
      CALL MY_BCAST(SALPHA,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 8 * 8/IRAT
      CALL MY_BCAST(MFXCX,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 5 * 8
      CALL MY_BCAST(PXLDA,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = NLLI*MXCSET * 8/IRAT
      CALL MY_BCAST(IXCPAR,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = NLLL*MXCSET * 8/IRAT
      CALL MY_BCAST(LXCPAR,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = NLLR*MXCSET * 8/IRAT
      CALL MY_BCAST(RXCPAR,MSGLEN,SOURCE,ALLGRP)
C..LINRES
      MSGLEN = 6 * 8/IRAT
      CALL MY_BCAST(TD_X,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 6 * 8/IRAT
      CALL MY_BCAST(TD_TGC,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 5 * 8
      CALL MY_BCAST(TDPXLDA,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 1 * 8/IRAT
      CALL MY_BCAST(TD_FUNCTIONAL,MSGLEN,SOURCE,ALLGRP)
C..ENERGY
      MSGLEN = 1 * 8/IRAT
      CALL MY_BCAST(TENERGY_OK,MSGLEN,SOURCE,ALLGRP)
C..HFX 3/4
      MSGLEN = 4 * 8/IRAT
      CALL MY_BCAST(TWSCR,MSGLEN,SOURCE,ALLGRP)
      MSGLEN = 2 * 8
      CALL MY_BCAST(DWFC,MSGLEN,SOURCE,ALLGRP)
      IF(TWSCR) THEN
        TDIPD=.TRUE.
        TWANN=.TRUE.
      ENDIF
#endif
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE TDM_FUN(FUN,ITAG)
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'func.inc'
      INCLUDE 'tbxc.inc'
      INTEGER FUN,ITAG
C     ==--------------------------------------------------------------==
      IF(ITAG.GT.0) THEN
        TOLDCODE=.FALSE.
        TPOTENTIAL=.FALSE.
        SALPHA=2.d0/3.d0
        IF(FUN.EQ.0) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
        ELSEIF(FUN.EQ.1) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=0
            MFXCC=9
            MGCX=0
            MGCC=0
            MHFX=0
        ELSEIF(FUN.EQ.2) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=9
            MGCX=1
            MGCC=1
            MHFX=0
        ELSEIF(FUN.EQ.3) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=9
            MGCX=3
            MGCC=4
            MHFX=0
        ELSEIF(FUN.EQ.4) THEN
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=1
            MFXCC=3
            MGCX=1
            MGCC=2
            MHFX=0
        ELSEIF(FUN.EQ.5) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=3
            MGCX=6
            MGCC=2
            MHFX=0
        ELSEIF(FUN.EQ.6) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=5
            MGCC=5
            MHFX=0
        ELSEIF(FUN.EQ.7) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            TTAU=.TRUE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
            MTAU=1
            MHFX=0
        ELSEIF(FUN.EQ.10 .OR. FUN.EQ.11 .OR. FUN.EQ.12) THEN
            TPOTENTIAL=.TRUE.
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            TTAU=.FALSE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
            MTAU=0
            MHFX=0
        ELSEIF(FUN.EQ.20) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            MFXCC=2
            MGCX=3
            MGCC=4
            MHFX=1
            PXLDA=0.75D0
            PXGC=0.75D0
            PCLDA=1.D0
            PCGC=1.D0
            PHFX=0.25D0
            CALL HF_INIT(.TRUE.)
        ELSEIF(FUN.EQ.21) THEN
            TOLDCODE=.TRUE.
            TGC=.TRUE.
            TGCX=.TRUE.
            TGCC=.TRUE.
            THYBRID=.TRUE.
            MFXCX=1
            MFXCC=3
            MGCX=1
            MGCC=2
            MHFX=1
            PXLDA=0.8D0
            PXGC=0.72D0
            PCLDA=1.D0
            PCGC=0.81D0
            PHFX=0.2D0
            CALL HF_INIT(.TRUE.)
        ELSEIF(FUN.EQ.30) THEN
            TGC=.FALSE.
            TGCX=.FALSE.
            TGCC=.FALSE.
            MFXCX=0
            MFXCC=0
            MGCX=0
            MGCC=0
            MHFX=1
            CALL HF_INIT(.TRUE.)
        ELSE
          CALL STOPGM("TD_METHOD","FUNCTIONAL NOT SUPPORTED(TAG=1)")
        ENDIF
      ELSEIF(ITAG.LT.0) THEN
        FUN=-1
C       Hybrid functionals
        IF(THYBRID) THEN
          FUN=20
        ELSEIF(MHFX.EQ.1) THEN
C         Hartree Fock
          FUN=30
        ELSE
C         NONE
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.0 .AND. 
     &       MGCX.EQ.0 .AND. MGCC.EQ.0) FUN = 0
C         LDA
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.9 .AND. 
     &       MGCX.EQ.0 .AND. MGCC.EQ.0) FUN = 1
C         BP
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.9 .AND. 
     &       MGCX.EQ.1 .AND. MGCC.EQ.1) FUN = 2
C         PBE
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.9 .AND. 
     &       MGCX.EQ.3 .AND. MGCC.EQ.4) FUN = 3
C         BLYP
          IF(MFXCX.EQ.1 .AND. MFXCC.EQ.3 .AND. 
     &       MGCX.EQ.1 .AND. MGCC.EQ.2) FUN = 4
C         OLYP
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.3 .AND. 
     &       MGCX.EQ.6 .AND. MGCC.EQ.2) FUN = 5
C         HCTH
          IF(MFXCX.EQ.0 .AND. MFXCC.EQ.0 .AND. 
     &       MGCX.EQ.5 .AND. MGCC.EQ.5) FUN = 6
C         TPSS
          IF(MFXCX.EQ.1 .AND. MFXCC.EQ.3 .AND. 
     &       MGCX.EQ.1 .AND. MGCC.EQ.2 .AND. MTAU.EQ.1) FUN = 7
        ENDIF
        IF(FUN.EQ.-1) THEN
          CALL STOPGM("TD_METHOD","FUNCTIONAL NOT SUPPORTED(TAG<0)")
        ENDIF
      ELSE
        CALL STOPGM("TD_METHOD","TAG NOT SUPPORTED")
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE SET_FUNCTIONAL(ISET)
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'func.inc'
      INCLUDE 'tbxc.inc'
      INTEGER ISET
C     ==--------------------------------------------------------------==
      MFXCX = IXCPAR(1,ISET)
      MFXCC = IXCPAR(2,ISET)
      MGCX  = IXCPAR(3,ISET)
      MGCC  = IXCPAR(4,ISET)
      MHFX  = IXCPAR(5,ISET)
      MTAU  = IXCPAR(6,ISET)
      TGC   = LXCPAR(1,ISET)
      TGCX  = LXCPAR(2,ISET)
      TGCC  = LXCPAR(3,ISET)
      TOLDCODE = LXCPAR(4,ISET)
      THYBRID  = LXCPAR(5,ISET)
      TTAU     = LXCPAR(6,ISET)
      PXLDA = RXCPAR(1,ISET)
      PCLDA = RXCPAR(2,ISET)
      PXGC  = RXCPAR(3,ISET)
      PCGC  = RXCPAR(4,ISET)
      PHFX  = RXCPAR(5,ISET)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
