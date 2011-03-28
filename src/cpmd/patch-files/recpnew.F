C     ==================================================================
      SUBROUTINE RECPNEW(ISP,ECPNAM)
C     ==--------------------------------------------------------------==
C     ==  Reads Pseudopotential Input (New Format)                    ==
C     ==--------------------------------------------------------------==
C     == INPUT:                                                       ==
C     == ISP     Species index                                        ==
C     == ECPNAM  Filename of pseudopotential file                     ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'cnst.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'ragg.inc'
      INCLUDE 'dpot.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'rmas.inc'
      INCLUDE 'func.inc'
      INCLUDE 'nlcc.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'vdbt.inc'
      INCLUDE 'vdbp.inc'
      INCLUDE 'sgpp.inc'
C     Arguments
      INTEGER   ISP
      CHARACTER ECPNAM*(*)
C     Variables
      INTEGER   IUNIT
      PARAMETER (IUNIT=21)
      INTEGER   IA,IE,IERR,INSCAN,IOUT,IT,I,J,K,L,M,
     &          IV,IR,LP,II,IL,INGHCOM,LENECP,MESHV,LREAD
      REAL*8    RR(MMAXX),C(MMAXX),FC(MMAXX),TEMP(MMAXX)
      POINTER   (IP_RR,RR),(IP_C,C),(IP_FC,FC),(IP_TEMP,TEMP)
      REAL*8    EXCF,S1,DAL,XCTEST,DXC,
     &          HMAT(MPRO*MPRO)
      CHARACTER LINE*80,ECPLIB*120,FNAMES*200
      LOGICAL EXISTS,ERREAD,TSCA
      INTEGER IVAN1
      DATA    IVAN1 /0/ 
      SAVE    IVAN1
C     ==--------------------------------------------------------------==
C     Allocation of local variables
      CALL MEMORY(IP_RR,MMAXX,'RR')
      CALL MEMORY(IP_C,MMAXX,'C')
      CALL MEMORY(IP_FC,MMAXX,'FC')
      CALL MEMORY(IP_TEMP,MMAXX,'TEMP')
C     ==--------------------------------------------------------------==
      TSGP(ISP)=.FALSE.
      TNUM(ISP)=.FALSE.
      TLOG(ISP)=.FALSE.
      TSCA=.FALSE.
      CALL GET_PPLIB(ECPLIB,LENECP)
      CALL XSTRING(ECPNAM,IA,IE)
      FNAMES=ECPLIB(1:LENECP)//ECPNAM(IA:IE)
      INQUIRE(FILE=FNAMES,EXIST=EXISTS)
      IF(.NOT.EXISTS) THEN
         FNAMES=ECPNAM(IA:IE)
         INQUIRE(FILE=FNAMES,EXIST=EXISTS)
         IF(.NOT.EXISTS) THEN
            WRITE(*,*) ' RECPNEW| ECPFILE NOT FOUND ',FNAMES
            CALL STOPGM('RECPNEW',' ')
         ENDIF
      ENDIF
      ECPFILES(ISP)=FNAMES
      IF(TVAN(ISP)) THEN
C..Vanderbilt PP in binary or formatted form
        IF(IVAN1.EQ.0) THEN
          IVAN1=1
          CALL MEMORY(IP_RSCORE,MMAXX*NSX,'RSCORE')
          CALL MEMORY(IP_DION,NBRX*NBRX*NSX,'DION')
          CALL MEMORY(IP_BETAR,MMAXX*NBRX*NSX,'BETAR')
          CALL MEMORY(IP_QQQ,NBRX*NBRX*NSX,'QQQ')
          CALL MEMORY(IP_QFUNC,MMAXX*NBRX*NBRX*NSX,'QFUNC')
          CALL MEMORY(IP_QRL,MMAXX*NBRX*NBRX*LX*NSX,'QRL')
          CALL MEMORY(IP_R,MMAXX*NSX,'R')
          CALL MEMORY(IP_RUCORE,MMAXX*NBRX*NSX,'RUCORE')
          CALL MEMORY(IP_RU,MMAXX*NSX,'RU')
          CALL MEMORY(IP_RAB,MMAXX*NSX,'RAB')
          CALL MEMORY(IP_RSATOM,MMAXX*NSX,'RSATOM')
          CALL MEMORY(IP_VDB_PAWF,NSX*MMAXX*NBRX,'VDB_PAWF')
          CALL MEMORY(IP_VDB_R,NSX*MMAXX,'VDB_R')
        ENDIF
        TNUM(ISP)=.TRUE.
        TKB(ISP)=.FALSE.
        IGAU(ISP)=0
C
        CALL READVAN(ISP,FNAMES)
C
        IF (IFPCOR(ISP).EQ.1) TNLCC(ISP) = .TRUE.
        PMA0(ISP)=ATWT(IATYP(ISP))
        RAGGIO(ISP)=DEFRAG(IATYP(ISP))
        RETURN
      ENDIF
      OPEN(UNIT=IUNIT,FILE=FNAMES,STATUS='OLD')
      REWIND(IUNIT)
C     ==--------------------------------------------------------------==
C..General info about PP and atom
      IERR=INSCAN(IUNIT,'&ATOM')
      IF(IERR.NE.0) THEN
        WRITE(*,*) ' RECPNEW| &ATOM SECTION NOT FOUND '
        CALL STOPGM('RECPNEW',' ')
      ENDIF
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IA=INDEX(LINE,'=')+1
      CALL READSI(LINE,IA,IOUT,IATYP(ISP),ERREAD)
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IA=INDEX(LINE,'=')+1
      CALL READSR(LINE,IA,IOUT,ZV(ISP),ERREAD)
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IA=INDEX(LINE,'=')+1
      CALL READSR(LINE,IA,IOUT,EXCF,ERREAD)
      IA=IOUT+1
      CALL READSR(LINE,IA,IOUT,S1,ERREAD)
      DAL=ABS(S1-SALPHA)
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      PMA0(ISP)=ATWT(IATYP(ISP))
      RAGGIO(ISP)=DEFRAG(IATYP(ISP))
      EXCF=EXCF-100.D0*(INT(EXCF)/100)
      XCTEST=10.D0*MGCX+MGCC
      DXC=ABS(XCTEST-EXCF)
      IF(DXC.GT.0.1D0.OR.DAL.GT.1.D-4) THEN
        CALL XSTRING(ECPNAM,IA,IE)
        WRITE(*,'(/,1X,64("!"))')
        WRITE(*,'(A,A)') ' WARNING! XC FUNCTIONALS INCONSISTENT FOR ',
     &       ECPNAM(IA:IE)
        WRITE(*,'(1X,64("!"))')
      ENDIF
C..The info section
      IERR=INSCAN(IUNIT,'&INFO')
      IT=0
      DO I=1,60
        READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
        IF(INDEX(LINE,'&END').NE.0) GOTO 10
        IT=IT+1
        VDBTI(IT,ISP)=LINE(1:66)
      ENDDO
   10 CONTINUE
      ITMAX(ISP)=IT
C..Potential section
      IERR=INSCAN(IUNIT,'&POTENTIAL')
      IF(IERR.NE.0) THEN
        WRITE(*,*) ' RECPNEW| &POTENTIAL SECTION NOT FOUND '
        CALL STOPGM('RECPNEW',' ')
      ENDIF
C..Normconserving PP
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IF(INDEX(LINE,'BHS').NE.0) THEN
C..Bachelet type
        IGAU(ISP)=3
        TNUM(ISP)=.FALSE.
        READ(IUNIT,*) WRC(ISP,1),RC(ISP,1),WRC(ISP,2),RC(ISP,2)
        DO I=1,LMAX(ISP)
          DO J=1,IGAU(ISP)
            READ(IUNIT,*) RCL(J,ISP,I),AL(J,ISP,I),BL(J,ISP,I)
          ENDDO
        ENDDO
      ELSEIF(INDEX(LINE,'CAR').NE.0) THEN
C..VonBarth-Car type
        IGAU(ISP)=1
        TNUM(ISP)=.FALSE.
        READ(IUNIT,*) RC(ISP,1)
        DO I=1,LMAX(ISP)
          READ(IUNIT,*) RCL(1,ISP,I),AL(1,ISP,I),BL(1,ISP,I)
        ENDDO
      ELSEIF(INDEX(LINE,'GOEDECK').NE.0) THEN
C..Stefan Goedecker PP
        TSGP(ISP)=.TRUE.
        TNUM(ISP)=.FALSE.
        TKB(ISP)=.FALSE.
        IGAU(ISP)=0
        READ(IUNIT,*) LMAX(ISP)
        LMAX(ISP)=LMAX(ISP)+1
        LLOC(ISP)=LMAX(ISP)
        LSKIP(ISP)=LMAX(ISP)+5
        READ(IUNIT,*) RCSG(ISP)
        READ(IUNIT,*) NCLSG(ISP),(CLSG(I,ISP),I=1,NCLSG(ISP))
        IF(NCLSG(ISP).GT.MCFUN) CALL STOPGM('RECPNEW','C_FUNCTION')
        IV=0
        LP=0
        DO L=1,LMAX(ISP)-1
          READ(IUNIT,*) RCNL(L,ISP),NPRO(L,ISP),(HMAT(I),I=1,
     &          (NPRO(L,ISP)*(NPRO(L,ISP)+1))/2)
          IF(NPRO(L,ISP).GT.MPRO) CALL STOPGM('RECPNEW','HMAT')
          II=0
          DO I=1,NPRO(L,ISP)
            DO J=I,NPRO(L,ISP)
              II=II+1
              HLSG(I,J,L,ISP)=HMAT(II)
              HLSG(J,I,L,ISP)=HMAT(II)
            ENDDO
          ENDDO
          DO M=1,2*L-1
            LP=LP+1
            DO K=1,NPRO(L,ISP)
              IV=IV+1
              NGHTOL(IV,ISP)=L-1
              LPVAL(IV,ISP)=LP
              LFVAL(IV,ISP)=K
            ENDDO
          ENDDO
        ENDDO
        NGH(ISP)=IV
      ELSE
C..Numeric
C       Logscale option.
        IF (INDEX(LINE,'LOGSCALE').NE.0.OR.
     &       (INDEX(LINE,'ECHELLE').NE.0
     &       .AND.INDEX(LINE,'LOG').NE.0)) THEN
C         Use logscale defined in the pp file (do not interpolate)
          TSCA=.TRUE.
          READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
        ENDIF
        TNUM(ISP)=.TRUE.
        IGAU(ISP)=0
C       Read number of points
        CALL READSI(LINE,1,IOUT,MESHV,ERREAD)
        IF(MESHV.GT.MMAXX) THEN
          WRITE(*,*) ' RECPNEW! POTENTIAL SECTION'
          CALL XSTRING(ECPNAM,IA,IE)
          WRITE(*,*) ' RECPNEW! MESH FOR ',ECPNAM(IA:IE),' IS ',
     &               MESHV
          WRITE(*,*) ' RECPNEW! MAX NUMBER OF SPLINE POINTS:',MMAXX
          WRITE(*,*) ' RECPNEW! INCREASE SPLINE POINTS NUMBER'
          CALL STOPGM('RECPNEW','MESH TOO BIG')
        ENDIF
        DO J=1,MESHV
          READ(IUNIT,*) RR(J),(VR(J,ISP,IL),IL=1,LMAX(ISP))
        ENDDO
        CALL CKGRID(RR(1),RR(MESHV),RV(1,ISP),MESHV,CLOGVP(ISP))
        IF(.NOT.TSCA) THEN
C         Interpolate data in another grid
          DO IL=1,LMAX(ISP)
            CALL TGRID(RR,MESHV,RV(1,ISP),MESHV,VR(1,ISP,IL),
     &                 MMAXX,C,FC,TEMP)
          ENDDO
        ELSE
C         Do not interpolate data. Use the same grid.
          DO J=1, MESHV
            RV(J,ISP)=RR(J)
          ENDDO
        ENDIF
        MESHVP(ISP)=MESHV
      ENDIF
C..Put analytic potentials on a logarithmic mesh
      IF(.NOT.(TNUM(ISP).OR.TSGP(ISP)))
     &     CALL AGRID(ISP,RR)
C..Read Atomic Wavefunction (if Kleinman-Bylander Integration)
      IF(TKB(ISP)) THEN
        LREAD=LMAX(ISP)
        IF(LLOC(ISP).EQ.LMAX(ISP)) LREAD=LREAD-1
        IF(LREAD.GT.0) THEN
          IERR=INSCAN(IUNIT,'&WAVEFUNCTION')
          IF(IERR.NE.0) THEN
            WRITE(*,*) ' RECPNEW| &WAVEFUNCTION SECTION NOT FOUND '
            CALL STOPGM('RECPNEW',' ')
          ENDIF
          READ(IUNIT,*) MESHV
          IF(MESHV.GT.MMAXX) THEN
            WRITE(*,*) ' RECPNEW! WAVEFUNCTION SECTION'
            CALL XSTRING(ECPNAM,IA,IE)
            WRITE(*,*) ' RECPNEW! MESH FOR ',ECPNAM(IA:IE),' IS ',
     &                 MESHV
            WRITE(*,*) ' RECPNEW! MAX NUMBER OF SPLINE POINTS:',MMAXX
            WRITE(*,*) ' RECPNEW! INCREASE SPLINE POINTS NUMBER'
            CALL STOPGM('RECPNEW','MESH TOO BIG')
          ENDIF
          DO J=1,MESHV
            READ(IUNIT,*) RR(J),(RPS(J,ISP,IL),IL=1,LREAD)
          ENDDO
C..We need same grid for wavefunctions and potentials
          IF(TSCA) THEN
C           Check if the mesh is the same for potential and wavefunctions
            IF(MESHV.NE.MESHVP(ISP)) THEN
              CALL XSTRING(FNAMES,IA,IE)
              WRITE(*,*) ' RECPNEW! YOU USE LOGSCALE OPTION IN THE',
     &             ' PSEUDOPOTENTIAL FILE:',FNAMES(IA:IE)
              WRITE(*,*) ' RECPNEW! POTENTIAL MESH=',MESHVP(ISP)
              WRITE(*,*) ' RECPNEW! WAVEFUNCTION MESH=',MESHW(ISP)
              CALL STOPGM('RECPNEW','THE LOGSCALES ARE DIFFERENT'//
     &             'FOR POTENTIAL AND WAVEFUNCTIONS')
            ENDIF
          ENDIF
          CLOGW(ISP)=CLOGVP(ISP)
          MESHW(ISP)=MESHVP(ISP)
          CALL DCOPY(MESHW(ISP),RV(1,ISP),1,RW(1,ISP),1)
          IF(.NOT.TSCA) THEN
            DO IL=1,LREAD
              CALL TGRID(RR,MESHV,RW(1,ISP),MESHW(ISP),RPS(1,ISP,IL),
     &                   MMAXX,C,FC,TEMP)
            ENDDO
          ENDIF
        ELSE
          CLOGW(ISP)=CLOGVP(ISP)
          MESHW(ISP)=MESHVP(ISP)
        ENDIF
C..aa   To decrease the number of non-local projectors
        IV=0 
        DO IL=1,LMAX(NSP)     
          IF(IL.NE.LLOC(NSP).AND.IL.NE.LSKIP(NSP)) THEN 
            L=IL-1
            NGH(NSP)=NGH(NSP)+(2*L+1)
            IF(L.EQ.0) THEN
              INGHCOM=0
            ELSE
              INGHCOM=L*L
            ENDIF
            DO J=1,2*L+1
              IV=IV+1 
              NGHTOL(IV,NSP)=L
              NGHCOM(IV,NSP)=INGHCOM+J
            ENDDO
          ENDIF
        ENDDO
C..aa 
      ENDIF
C..Nonlinear core correction
      IF(TNLCC(ISP)) THEN
        IERR=INSCAN(IUNIT,'&NLCC')
        IF(IERR.NE.0) THEN
          WRITE(*,*) ' RECPNEW: &NLCC SECTION NOT FOUND '
          CALL STOPGM('RECPNEW',' ')
        ENDIF
        READ(IUNIT,'(A)') LINE
        IF(INDEX(LINE,'ANAL').NE.0) THEN
C..Analytic definition of core charges
          NLCCT(ISP)=1
          READ(IUNIT,*) ANLCC(ISP),BNLCC(ISP),ENLCC(ISP)
        ELSEIF(INDEX(LINE,'NUME').NE.0) THEN
C..Numerical definition of core charges
          NLCCT(ISP)=2
          READ(IUNIT,*) MESHV
          IF(MESHV.GT.MMAXX) THEN
            WRITE(*,*) ' RECPNEW! NONLINEAR CORE CORRECTION SECTION'
            CALL XSTRING(ECPNAM,IA,IE)
            WRITE(*,*) ' RECPNEW! MESH FOR ',ECPNAM(IA:IE),' IS ',
     &                 MESHV
            WRITE(*,*) ' RECPNEW! MAX NUMBER OF SPLINE POINTS:',MMAXX
            WRITE(*,*) ' RECPNEW! INCREASE SPLINE POINTS NUMBER'
            CALL STOPGM('RECPNEW','MESH TOO BIG')
          ENDIF
          DO IR=1,MESHV
            READ(IUNIT,*) RR(IR),CORECG(IR,ISP)
          ENDDO
          CALL CKGRID(RR(1),RR(MESHV),RCGRID(1,ISP),MESHV,CLOGCC(ISP))
          CALL TGRID(RR,MESHV,RCGRID(1,ISP),MESHV,CORECG(1,ISP),
     &               MMAXX,C,FC,TEMP)
          MESHCC(ISP)=MESHV
        ELSE
          WRITE(*,*) ' TYPE OF NLCC DEFINITION NOT CLEAR'
          WRITE(*,*) LINE
          CALL STOPGM('RNLCC',' ')
        ENDIF
      ELSE
        IERR=INSCAN(IUNIT,'&NLCC')
        IF(IERR.EQ.0) THEN
          WRITE(*,'(/,1X,64("!"))')
          WRITE(*,'(1X,A)')
     &         'WARNING! PSEUDOPOTENTIAL GENERATED WITH NLCC '
          CALL XSTRING(ECPNAM,IA,IE)
          WRITE(*,'(1X,A,A)') 'WARNING! FOR ',ECPNAM(IA:IE)
          WRITE(*,'(1X,64("!"))')
        ENDIF
      ENDIF
      CLOSE(IUNIT)
C     ==--------------------------------------------------------------==
C     Deallocation of local variables
      CALL FREEM(IP_RR)
      CALL FREEM(IP_C)
      CALL FREEM(IP_FC)
      CALL FREEM(IP_TEMP)
C     ==--------------------------------------------------------------==
      RETURN
C     ==--------------------------------------------------------------==
   20 CONTINUE
        WRITE(*,*) ' ERROR WHILE READING PP DEFINITIONS'
        CALL STOPGM('RECPNEW',' ')
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE CKGRID(RP1,RPL,RW,MESH,CLOG)
C     ==--------------------------------------------------------------==
C     == Construct logarithmic grid from RP1 to RPL with MESH points  ==
C     == in RW(1:MESH).                                               ==
C     == CLOG is the step                                             ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      INTEGER MESH
      REAL*8  RP1,RPL,RW(MESH),CLOG
C     Variables
      REAL*8  CF
      INTEGER IR
C     ==--------------------------------------------------------------==
      CLOG=LOG(RPL/RP1)/DBLE(MESH-1)
      CF=EXP(CLOG)
      RW(1)=RP1
      DO IR=2,MESH
        RW(IR)=RW(IR-1)*CF
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE TGRID(RP,MP,RW,MW,F,MMAXX,C,FC,TEMP)
C     ==--------------------------------------------------------------==
C     == Interpolate F(1:MP) from RP(1:MP) grid to RW(1:MW)           ==
C     == Output: F(1:MW)                                              ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      INTEGER MP,MW,MMAXX
      REAL*8  RP(MP),RW(MW),F(*),
     &        C(MMAXX),FC(MMAXX),TEMP(MMAXX)
C     Variables
      REAL*8  CURV2
      INTEGER I,IERR
C     ==--------------------------------------------------------------==
      CALL DCOPY(MP,F(1),1,FC(1),1)
      CALL CURV1(MP,RP,FC,0.0D0,0.0D0,3,C,TEMP,0.0D0,IERR)
      DO I=1,MW
        F(I)=CURV2(RW(I),MP,RP,FC,C,0.0D0)
      ENDDO
      RETURN
      END
C     ==================================================================
      SUBROUTINE AGRID(ISP,RR)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'dpot.inc'
      INCLUDE 'pslo.inc'
C     Arguments
      INTEGER  ISP
      REAL*8   RR(*)
C     Variables
      INTEGER  IL,IB,MESHV,IR
      REAL*8   RR1,RX,RR2
#ifdef __DERF
      REAL*8   DERF
      EXTERNAL DERF
#endif
      REAL*8   EXPONENTIAL
      EXTERNAL EXPONENTIAL
C     ==--------------------------------------------------------------==
      IF(IGAU(ISP).GT.1) THEN
        RC(ISP,1)=1.D0/RC(ISP,1)**0.5D0
        RC(ISP,2)=1.D0/RC(ISP,2)**0.5D0
        DO IL=1,LMAX(ISP)
          DO IB=1,IGAU(ISP)
            RCL(IB,ISP,IL) = 1.D0/RCL(IB,ISP,IL)**0.5D0
          ENDDO
        ENDDO
      ENDIF
      CLOGVP(ISP)=LOG(1.025D0)
      MESHV=INT(LOG(7200.0D0*DBLE(IATYP(ISP)))/CLOGVP(ISP))
      IF(MESHV.GT.MMAXX) THEN
        CLOGVP(ISP)=DBLE(MESHV)/DBLE(MMAXX)*CLOGVP(ISP)
        MESHV=MMAXX
      ENDIF
      RR1=.00625D0/DBLE(IATYP(ISP))
      RX=LOG(RR1)+MESHV*CLOGVP(ISP)
      RR2=EXP(RX)
      CALL CKGRID(RR1,RR2,RV(1,ISP),MESHV,CLOGVP(ISP))
      IF(IGAU(ISP).EQ.1) THEN
        DO IL=1,LMAX(ISP)
          DO IR=1,MESHV
            RX=RV(IR,ISP)
            VR(IR,ISP,IL)=-ZV(ISP)/RX*DERF(RX/RC(ISP,1)) 
     *                     +(AL(1,ISP,IL)+BL(1,ISP,IL)*RX*RX)
     *                      *EXPONENTIAL(-(RX/RCL(1,ISP,IL))**2)
          ENDDO
        ENDDO
      ELSEIF(IGAU(ISP).EQ.3) THEN
        DO IL=1,LMAX(ISP)
          DO IR=1,MESHV
            RX=RV(IR,ISP)
            VR(IR,ISP,IL)=-ZV(ISP)/RX*
     *      (WRC(ISP,1)*DERF(RX/RC(ISP,1))+
     *       WRC(ISP,2)*DERF(RX/RC(ISP,2))) 
     *                   +(AL(1,ISP,IL)+BL(1,ISP,IL)*RX*RX)
     *                    *EXPONENTIAL(-(RX/RCL(1,ISP,IL))**2)
     *                   +(AL(2,ISP,IL)+BL(2,ISP,IL)*RX*RX)
     *                    *EXPONENTIAL(-(RX/RCL(2,ISP,IL))**2)
     *                   +(AL(3,ISP,IL)+BL(3,ISP,IL)*RX*RX)
     *                    *EXPONENTIAL(-(RX/RCL(3,ISP,IL))**2)
          ENDDO
        ENDDO
      ELSE
        DO IR=1,MESHV
          RX=RV(IR,ISP)
          VR(IR,ISP,1)=-ZV(ISP)/RX
        ENDDO
      ENDIF
      MESHVP(ISP)=MESHV
      TNUM(ISP)=.TRUE.
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      FUNCTION EXPONENTIAL(X)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      REAL*8 EXPONENTIAL
      REAL*8 X
      REAL*8 XMIN
      PARAMETER (XMIN=-400.D0)
C     ==--------------------------------------------------------------==
      IF (X.LT.XMIN) THEN
        EXPONENTIAL = 0.D0
      ELSE
        EXPONENTIAL = EXP(X)
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE ALLELEC(ISP,ECPNAM)
C     ==--------------------------------------------------------------==
C     ==  GENERATES 1/R Potential                                     ==
C     ==--------------------------------------------------------------==
C     == INPUT:                                                       ==
C     == ISP     Species index                                        ==
C     == ECPNAM  Atom name                                            ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'dpot.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'atom.inc'
      INCLUDE 'vdbt.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'rmas.inc'
      INCLUDE 'ragg.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'sgpp.inc'
C     Arguments
      INTEGER   ISP
      CHARACTER ECPNAM*40
C     Variables
      INTEGER I,IA,IE,IFOUND
      CHARACTER EN*2
      REAL*8    RR(MMAXX)
      POINTER   (IP_RR,RR)
C     ==--------------------------------------------------------------==
      CALL MEMORY(IP_RR,MMAXX,'RR')
      TSGP(ISP)=.FALSE.
      TVAN(ISP)=.FALSE.
      TNUM(ISP)=.TRUE.
      TLOG(ISP)=.FALSE.
      TKB(ISP)=.FALSE.
      ECPFILES(ISP)="NONE"
      LMAX(ISP)=1
      IGAU(ISP)=0
      CALL XSTRING(ECPNAM,IA,IE)
      IF(IA.EQ.IE) THEN
        EN=" "//ECPNAM(IA:IE)
      ELSEIF(IE.EQ.IA+1) THEN
        EN=ECPNAM(IA:IE)
      ELSE
        CALL STOPGM("ALLELEC","ATOM NAME "//ECPNAM(IA:IE))
      ENDIF
      IFOUND=0
      DO I=1,99
        IF(EN .EQ. EL(I)) IFOUND=I
      ENDDO
      IF(IFOUND.EQ.0) CALL STOPGM("ALLELEC","ATOM NAME "//ECPNAM(IA:IE))
      IATYP(ISP)=IFOUND
      PMA0(ISP)=ATWT(IATYP(ISP))
      RAGGIO(ISP)=DEFRAG(IATYP(ISP))
      ZV(ISP)=DBLE(IFOUND)
      VDBTI(1,ISP)="================================="//
     &             "================================="
      VDBTI(2,ISP)=" "
      VDBTI(3,ISP)="                      FULL POTENTIAL ("//EN//")"
      VDBTI(4,ISP)=" "
      VDBTI(5,ISP)="================================="//
     &             "================================="
      ITMAX(ISP)=5
      CALL AGRID(ISP,RR)
      CALL FREEM(IP_RR)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE RECPEAM(ISP,ECPNAM)
C     ==--------------------------------------------------------------==
C     ==  Reads Pseudopotential For EAM Atoms                         ==
C     ==--------------------------------------------------------------==
C     == INPUT:                                                       ==
C     == ISP     Species index                                        ==
C     == ECPNAM  Filename of pseudopotential file                     ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'cnst.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'ragg.inc'
      INCLUDE 'dpot.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'rmas.inc'
      INCLUDE 'func.inc'
      INCLUDE 'nlcc.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'vdbt.inc'
      INCLUDE 'vdbp.inc'
      INCLUDE 'sgpp.inc'
C     Arguments
      INTEGER   ISP
      CHARACTER ECPNAM*40
C
      INTEGER   IA,IE,IOUT,LENECP,I,IERR,IT,INSCAN
      CHARACTER LINE*80,ECPLIB*120,FNAMES*200
      LOGICAL EXISTS,ERREAD
      REAL*8    RR(MMAXX)
      POINTER   (IP_RR,RR)
C     Variables
      INTEGER   IUNIT
      PARAMETER (IUNIT=21)
C     ==--------------------------------------------------------------==
      CALL MEMORY(IP_RR,MMAXX,'RR')
      TSGP(ISP)=.FALSE.
      TVAN(ISP)=.FALSE.
      TNUM(ISP)=.FALSE.
      TLOG(ISP)=.FALSE.
      CALL GET_PPLIB(ECPLIB,LENECP)
      CALL XSTRING(ECPNAM,IA,IE)
      FNAMES=ECPLIB(1:LENECP)//ECPNAM(IA:IE)
      INQUIRE(FILE=FNAMES,EXIST=EXISTS)
      IF(.NOT.EXISTS) THEN
         FNAMES=ECPNAM(IA:IE)
         INQUIRE(FILE=FNAMES,EXIST=EXISTS)
         IF(.NOT.EXISTS) THEN
            WRITE(*,*) ' RECPEAM| ECPFILE NOT FOUND ',FNAMES
            CALL STOPGM('RECPEAM',' ')
         ENDIF
      ENDIF
      ECPFILES(ISP)=FNAMES
      OPEN(UNIT=IUNIT,FILE=FNAMES,STATUS='OLD')
      REWIND(IUNIT)
C     ==--------------------------------------------------------------==
C..General info about PP and atom
      IERR=INSCAN(IUNIT,'&ATOM')
      IF(IERR.NE.0) THEN
        WRITE(*,*) ' RECPEAM| &ATOM SECTION NOT FOUND '
        CALL STOPGM('RECPEAM',' ')
      ENDIF
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IA=INDEX(LINE,'=')+1
      CALL READSI(LINE,IA,IOUT,IATYP(ISP),ERREAD)
      READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
      IA=INDEX(LINE,'=')+1
      CALL READSR(LINE,IA,IOUT,ZV(ISP),ERREAD)
      PMA0(ISP)=ATWT(IATYP(ISP))
      RAGGIO(ISP)=DEFRAG(IATYP(ISP))
C..The info section
      IERR=INSCAN(IUNIT,'&INFO')
      IT=0
      DO I=1,60
        READ(IUNIT,END=20,ERR=20,FMT='(A)') LINE
        IF(INDEX(LINE,'&END').NE.0) GOTO 10
        IT=IT+1
        VDBTI(IT,ISP)=LINE(1:66)
      ENDDO
   10 CONTINUE
      ITMAX(ISP)=IT
C..Potential section
      IERR=INSCAN(IUNIT,'&POTENTIAL')
      IF(IERR.NE.0) THEN
        WRITE(*,*) ' RECPEAM| &POTENTIAL SECTION NOT FOUND '
        CALL STOPGM('RECPEAM',' ')
      ENDIF
C..VonBarth-Car type
      IGAU(ISP)=1
      TNUM(ISP)=.FALSE.
      READ(IUNIT,*) RC(ISP,1)
      DO I=1,LMAX(ISP)
         READ(IUNIT,*) RCL(1,ISP,I),AL(1,ISP,I),BL(1,ISP,I)
      ENDDO
      CALL AGRID(ISP,RR)
      IF(RC(ISP,1).LT.1.D-10) IGAU(ISP)=-1
C     ==--------------------------------------------------------------==
      CLOSE(IUNIT)
      CALL FREEM(IP_RR)
      RETURN
C     ==--------------------------------------------------------------==
   20 CONTINUE
        WRITE(*,*) ' ERROR WHILE READING PP DEFINITIONS'
        CALL STOPGM('RECPEAM',' ')
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GET_PPLIB(ECPLIB,LENECP)
      IMPLICIT NONE
      CHARACTER*(*) ECPLIB
      INTEGER       LENECP
C
      INTEGER ICARG,IARGC
C
      ICARG=IARGC()
      IF(ICARG.GT.1) THEN
        CALL MY_GETARG(2,ECPLIB)
        LENECP=INDEX(ECPLIB,' ')-1
        ECPLIB=ECPLIB(1:LENECP)//'/'
        LENECP=LENECP+1
      ELSE
        CALL MY_GETENV('CPMD_PP_LIBRARY_PATH',ECPLIB)
        LENECP=INDEX(ECPLIB,' ')-1
        IF(LENECP.EQ.0) THEN
          CALL MY_GETENV('PP_LIBRARY_PATH',ECPLIB)
          LENECP=INDEX(ECPLIB,' ')-1
          IF(LENECP.EQ.0) THEN
             ECPLIB='.'
             LENECP=1
          ENDIF
          ECPLIB=ECPLIB(1:LENECP)//'/'
          LENECP=LENECP+1
        ENDIF
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
