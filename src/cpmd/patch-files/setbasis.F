#ifdef __SR11000
*option OPT(O(3))
#endif
C     ==================================================================
      SUBROUTINE SETBASIS
C     ==--------------------------------------------------------------==
C     == SET ATOMIC BASIS         (call once)                         ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'dpot.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'atwf.inc'
      INCLUDE 'qspl.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'pimd.inc'
      INCLUDE 'response_p.inc'  ! dsebasti, for the super-group variables
C     Variables
      DIMENSION ATRG(MMAXX,*),ATWFR(MMAXX,M1SHLX,*)
      DIMENSION ATRG_EPR(MMAXX,*),ATWFR_EPR(MMAXX,M1SHLX,*)
      INTEGER   IFNUM
      PARAMETER (IFNUM=21)
      INTEGER   NE(4,7),IBTYPE(MAXSP)
      CHARACTER LQ(0:3)*1
      REAL*8    VALCH,ZC,DCLOG,
     &          SRULES
      INTEGER   IS,IATOM,MS,M,N,L,IR,I,
     &          IFIRST
      SAVE      IFIRST
      DATA      IFIRST /0/
      DATA      LQ /'S','P','D','F'/
      LOGICAL IONODE
      INTEGER IOSOURCE,IOGROUP
#ifdef PARALLEL
      INTEGER   MSGLEN
#endif
C     ==--------------------------------------------------------------==
      IF(IFIRST.NE.0) RETURN
C     ==--------------------------------------------------------------==
      IF(TPATH) THEN
        IONODE=GRANDPARENT
        IOSOURCE=SUPERSOURCE
        IOGROUP=SUPERGROUP
c dsebasti
      elseif (TNMR) then
        IONODE=nmr_superparent
        IOSOURCE=nmr_supersource
        IOGROUP=nmr_supergroup
c dsebasti
      ELSE
        IONODE=PARENT
        IOSOURCE=SOURCE
        IOGROUP=ALLGRP
      ENDIF
      CALL MEMORY(IP_ATWFR,MMAXX*NSX*M1SHLX,'ATWFR')
      CALL MEMORY(IP_ATRG,MMAXX*NSX,'ATRG')
      IF(TEPR_HYP) THEN
        CALL MEMORY(IP_ATWFR_EPR,MMAXX*NSX*M1SHLX,'ATWFR_EPR')
        CALL MEMORY(IP_ATRG_EPR,MMAXX*NSX,'ATRG_EPR')
      ENDIF
      IFIRST=1
      IF(IONODE) THEN
        WRITE(*,'(/,A)') ' GENERATE ATOMIC BASIS SET'            
C     ==--------------------------------------------------------------==
C       SLATER MINIMAL BASIS
        DO IS=1,NSP
          IBTYPE(IS)=1
          IATOM=IATYP(IS)
          VALCH=ZV(IS)
          ZC=DBLE(IATOM)-VALCH
          CALL ICOPY(28,NELCON(1,1,IATOM),1,NE,1)
          MS=0
          M=0
          DO N=1,7
            DO L=1,4
              M=M+NE(L,N)
              IF(M.GT.NINT(ZC).AND.NE(L,N).NE.0) THEN
                MS=MS+1
                NQSTO(MS,IS)=N
                LSHELL(MS,IS)=L-1
                STOEXP(MS,IS)=SRULES(IATOM,NE,N,L-1)
                OC(MS,IS)=NE(L,N)
              ENDIF
            ENDDO
          ENDDO
          NSHELL(IS)=MS
          MESHAT(IS)=256
          DCLOG=1.049999881D0
          CLOGAT(IS)=DLOG(DCLOG)
          ATRG(1,IS)=.7142857D-03
          DO IR=2,MESHAT(IS)
            ATRG(IR,IS)=DCLOG*ATRG(IR-1,IS)
          ENDDO
          DO I=1,NSHELL(IS)
            L=LSHELL(I,IS)
            CALL STORPS(ATRG(1,IS),ATWFR(1,I,IS),MESHAT(IS),
     *                        NQSTO(I,IS),L,STOEXP(I,IS))
          ENDDO
        ENDDO
C       LOOK FOR SECTION BASIS ON INPUT FILE
        CALL READ_BASIS(IBTYPE)
C       Print Basis Set Info
        DO IS=1,NSP
          IATOM=IATYP(IS)
          IF(IBTYPE(IS).EQ.1) THEN
            WRITE(*,'(5X,A,8X,A)') EL(IATOM),'SLATER ORBITALS'
            DO I=1,NSHELL(IS)
              WRITE(*,
     *            '(8X,I1,A1,8X,"ALPHA=",F9.4,T40,"OCCUPATION=",F5.2)')
     *            NQSTO(I,IS),LQ(LSHELL(I,IS)),STOEXP(I,IS),OC(I,IS)
            ENDDO
          ELSEIF(IBTYPE(IS).EQ.2) THEN
            WRITE(*,'(5X,A,8X,A)') EL(IATOM),'NUMERICAL ORBITALS'
            DO I=1,NSHELL(IS)
              WRITE(*,
     &            '(8X,"L VALUE=",A,6X,T40,"OCCUPATION=",F5.2)')
     *            LQ(LSHELL(I,IS)),OC(I,IS)
            ENDDO
          ELSEIF(IBTYPE(IS).EQ.3) THEN
            WRITE(*,'(5X,A,8X,A)') EL(IATOM),'PSEUDO ATOMIC ORBITALS'
            DO I=1,NSHELL(IS)
              WRITE(*,
     &            '(8X,"L VALUE=",A,6X,T40,"OCCUPATION=",F5.2)')
     *            LQ(LSHELL(I,IS)),OC(I,IS)
            ENDDO
          ENDIF
        ENDDO
        WRITE(*,*)
      ENDIF
#ifdef PARALLEL
C     Parallel
      CALL MY_SYNC(IOGROUP)
      MSGLEN = (M1SHLX+1)*MAXSP * 8/IRAT
      CALL MY_BCAST(NSHELL,MSGLEN,IOSOURCE,IOGROUP)
      MSGLEN = M1SHLX*(3*MAXSP+1) * 8
      CALL MY_BCAST(OC,MSGLEN,IOSOURCE,IOGROUP)
      MSGLEN = MAXSP * 8/IRAT
      CALL MY_BCAST(MESHAT,MSGLEN,IOSOURCE,IOGROUP)
      MSGLEN = MAXSP * 8
      CALL MY_BCAST(CLOGAT,MSGLEN,IOSOURCE,IOGROUP)
      MSGLEN = MMAXX*NSX*M1SHLX * 8
      CALL MY_BCAST(ATWFR,MSGLEN,IOSOURCE,IOGROUP)
      MSGLEN = MMAXX*NSX * 8
      CALL MY_BCAST(ATRG,MSGLEN,IOSOURCE,IOGROUP)
      IF(TEPR_HYP) THEN
        MSGLEN = MMAXX*NSX*M1SHLX * 8
        CALL MY_BCAST(ATWFR_EPR,MSGLEN,IOSOURCE,IOGROUP)
        MSGLEN = MMAXX*NSX * 8
        CALL MY_BCAST(ATRG_EPR,MSGLEN,IOSOURCE,IOGROUP)
        MSGLEN = MAXSP * 8/IRAT
        CALL MY_BCAST(MESH_EPR,MSGLEN,IOSOURCE,IOGROUP)
      ENDIF
C     Parallel
#endif
C     Initalization of NATTOT and M1SHL
      M1SHL=0
      NATTOT=0
      NUMAORMAX=0
      DO IS=1,NSP
        IF(M1SHL.LT.NSHELL(IS)) M1SHL=NSHELL(IS)
        NUMAOR(IS)=0
        DO I=1,NSHELL(IS)
          L=LSHELL(I,IS)
          NATTOT=NATTOT+NA(IS)*(2*L+1)
          NUMAOR(IS)=NUMAOR(IS)+(2*L+1)
        ENDDO
        NUMAORMAX=MAX(NUMAORMAX,NUMAOR(IS))
      ENDDO
      CALL MEMORY(IP_CAT,2*NSPLPO*M1SHL*NSX,'CAT')
C     Transform to G-Space
      CALL RTOG(0)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE RTOG(ITY)
C     ==--------------------------------------------------------------==
C     == Transform atomic orbital in R-space to G-space               ==
C     == Calculate CAT(NSPLPO,2,M1SHL,NSX) for each species           ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'dpot.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'atwf.inc'
      INCLUDE 'qspl.inc'
      INCLUDE 'cppt.inc'
      INCLUDE 'cnst.inc'
      INCLUDE 'gvec.inc'
      INCLUDE 'sphe.inc'
      INCLUDE 'pimd.inc'
      INCLUDE 'response_p.inc'  ! dsebasti, for the super-group variables
C
      INTEGER    ITY
C     Variables
      DIMENSION  CAT(NSPLPO,2,M1SHL,NSX),
     &           ATRG(MMAXX,*),ATWFR(MMAXX,M1SHLX,*),
     &           GGNG(NSPLPO),GGNH(NSPLPO)
      COMPLEX*16 WORK(2*MMAXX,5)
      REAL*8     FINT(2*MMAXX),BSINT(2*MMAXX),GG(2*MMAXX),TEMP(MMAXX,3)
      POINTER    (IP_WORK,WORK),
     &           (IP_FINT,FINT),(IP_BSINT,BSINT),(IP_GG,GG),
     &           (IP_TEMP,TEMP)
      REAL*8     DISC,XMAX,RMIN,GMIN
      INTEGER    IS,MMAX,NWORK,N2,N22,IL,ISHELL,L,IR,IERR
      LOGICAL    SAVED
      LOGICAL IONODE
C     ==--------------------------------------------------------------==
      NBCUT=ITY
      IF(TPATH) THEN
        IONODE=GRANDPARENT
c dsebasti
      elseif(Tnmr) then
        ionode=nmr_superparent
c dsebasti
      ELSE
        IONODE=PARENT
      ENDIF
      NWORK=2*MMAXX
C     Allocation of local arrays
      CALL MEMORY(IP_WORK,2*(NWORK*5),'WORK')
      CALL MEMORY(IP_FINT,NWORK,'WORK')
      CALL MEMORY(IP_BSINT,NWORK,'BSINT')
      CALL MEMORY(IP_GG,NWORK,'GG')
      CALL MEMORY(IP_TEMP,3*MMAXX,'MMAXX')
C     ==--------------------------------------------------------------==
      CALL AZZERO(CAT,2*NSPLPO*M1SHL*NSX)
      DO IS=1,NSP
        MMAX=MESHAT(IS)
        XMAX=MMAX
        N2=NINT(LOG(XMAX)/LOG(2.D0)+0.499999D0)
        N22=2**N2
        RMIN=LOG(ATRG(1,IS))
        IF(ITY.EQ.1) THEN
          GMIN=LOG(SQRT(GCUT)*TPIBA)-(MMAX-1)*CLOGAT(IS)
        ELSE
          GMIN=LOG(SQRT(GCUTW+GCUTKA)*TPIBA)-(MMAX-1)*CLOGAT(IS)
        ENDIF
        DO IL=1,MMAX
          GG(IL)=(EXP(GMIN+(IL-1)*CLOGAT(IS))/TPIBA)**2
        ENDDO
        DO ISHELL=1,NSHELL(IS)
          SAVED=.FALSE.
          L=LSHELL(ISHELL,IS)
          CALL AZZERO(FINT,N22)
          DO IR=1,MMAX
            FINT(IR)=FPI*ATWFR(IR,ISHELL,IS)/ATRG(IR,IS)
          ENDDO
C         Fourier transformation
          CALL LSFBTR(FINT,BSINT,L,RMIN,GMIN,CLOGAT(IS),N2,SAVED,
     *              WORK(1,1),WORK(1,2),WORK(1,3),WORK(1,5),NWORK,DISC)
          IF(DISC.GT.1.D-5.AND.IONODE) THEN
            WRITE(*,*) ' WARNING! LSFBTR ACCURACY ONLY ',DISC
          ENDIF
          IF(ITY.EQ.1) THEN
            CALL TGRID(GG,MMAX,GGNH,NSPLPO,BSINT,
     *                 MMAXX,TEMP(1,1),TEMP(1,2),TEMP(1,3))
            CALL DCOPY(NSPLPO,BSINT(1),1,CAT(1,1,ISHELL,IS),1)
            IF(L.GT.0.AND.GGNH(1).LT.1.D-12) CAT(1,1,ISHELL,IS)=0.0D0
            CALL CURV1(NSPLPO,GGNH,CAT(1,1,ISHELL,IS),0.0D0,0.0D0,3,
     *                 CAT(1,2,ISHELL,IS),TEMP,0.0D0,IERR)
          ELSE
            CALL TGRID(GG,MMAX,GGNG,NSPLPO,BSINT,
     *                 MMAXX,TEMP(1,1),TEMP(1,2),TEMP(1,3))
            CALL DCOPY(NSPLPO,BSINT(1),1,CAT(1,1,ISHELL,IS),1)
            IF(L.GT.0.AND.GGNG(1).LT.1.D-12) CAT(1,1,ISHELL,IS)=0.0D0
            CALL CURV1(NSPLPO,GGNG,CAT(1,1,ISHELL,IS),0.0D0,0.0D0,3,
     *                 CAT(1,2,ISHELL,IS),TEMP,0.0D0,IERR)
          ENDIF
        ENDDO
      ENDDO
C     ==--------------------------------------------------------------==
C     Deallocation of local arrays
      CALL FREEM(IP_WORK)
      CALL FREEM(IP_FINT)
      CALL FREEM(IP_BSINT)
      CALL FREEM(IP_GG)
      CALL FREEM(IP_TEMP)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE STORPS(R,RWFN,MESH,N,L,ALPHA)
C     ==--------------------------------------------------------------==
C     == CALCULATE R*STO ON A RADIAL GRID                             ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      INTEGER MESH,N,L
      REAL*8  R(MESH),RWFN(MESH),ALPHA
C     Variables
      REAL*8    XRMIN
      PARAMETER (XRMIN=-400.D0)
      INTEGER IR
      REAL*8  AN,XR,FAC(0:14)
      DATA    FAC / 1.D0, 1.D0, 2.D0, 6.D0, 24.D0, 120.D0, 720.D0,
     &        5040.D0, 40320.D0, 362880.D0, 36288.D2, 399168.D2,
     &        4.790016D8, 6.2270208D9, 8.7178291D10/
C     ==--------------------------------------------------------------==
      AN=SQRT((2.D0*ALPHA)**(2*N+1)/FAC(2*N))
      DO IR=1,MESH
        XR=-ALPHA*R(IR)
        IF(XR.LT.XRMIN) THEN
          RWFN(IR) = 0.D0
        ELSE
          RWFN(IR) = AN*R(IR)**N * EXP(-ALPHA*R(IR))
        ENDIF
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE GTORPS(R,RWFN,MESH,L,GEXP,GCOE,NALP)
C     ==--------------------------------------------------------------==
C     == CALCULATE R*SUM(I)GTO_I ON A RADIAL GRID                     ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      INTEGER MESH,L,NALP
      REAL*8  R(MESH),RWFN(MESH),GEXP(NALP),GCOE(NALP)
C     Variables
      INTEGER IR,IC
      REAL*8  PI,AN,
     &        DFAC(1:4)
      DATA    DFAC / 1.D0,3.D0,15.D0,105.D0/
C     ==--------------------------------------------------------------==
      PI=ACOS(-1.D0)
      CALL AZZERO(RWFN,MESH)
      DO IC=1,NALP
        AN=2.D0**(L+2)*DFAC(L+1)**(-0.5D0)*(2.D0*PI)**(-0.25D0)*
     &         GEXP(IC)**((2.D0*L+3.D0)/4.D0)
        AN=AN*GCOE(IC)
        DO IR=1,MESH
          RWFN(IR) = RWFN(IR) + 
     &               AN*R(IR)**(L+1) * EXP(-GEXP(IC)*R(IR)*R(IR))
        ENDDO
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      FUNCTION SRULES(NATOM,NE,N,L)
C     ==--------------------------------------------------------------==
C     == Get Slater exponents from the Clementi-Raimondi table or     ==
C     == Calculate Slater exponents by Slaters rule                   ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      REAL*8  SRULES
      INTEGER NATOM,NE(4,7),N,L
C     Variables
      INTEGER L1,L2,M,M1,M2,I
      REAL*8  S,
     &        XNS(7),CR(2,3,18)
      DATA    CR  /1.0D0,5*0.0D0, 1.6875D0,5*0.0D0,
     &     2.6906D0,0.0D0,0.6396D0,3*0.0D0,
     *     3.6848D0,0.0D0,0.9560D0,3*0.0D0,
     &     4.6795D0,0.0D0,1.2881D0,1.2107D0,2*0.0D0,
     *     5.6727D0,0.0D0,1.6083D0,1.5679D0,2*0.0D0,
     &     6.6651D0,0.0D0,1.9237D0,1.9170D0,2*0.0D0,
     *     7.6579D0,0.0D0,2.2458D0,2.2266D0,2*0.0D0,
     &     8.6501D0,0.0D0,2.5638D0,2.5500D0,2*0.0D0,
     *     9.6421D0,0.0D0,2.8792D0,2.8792D0,2*0.0D0,
     *     10.6259D0,0.D0,3.2857D0,3.4009D0,0.8359D0,0.D0,
     *     11.6089D0,0.0D0,3.6960D0,3.9129D0,1.1025D0,0.0D0,
     *     12.5910D0,0.0D0,4.1068D0,4.4817D0,1.3724D0,1.3552D0,
     *     13.5724D0,0.0D0,5.5100D0,4.9725D0,1.6344D0,1.4284D0,
     *     14.5578D0,0.0D0,4.9125D0,5.4806D0,1.8806D0,1.6288D0,
     *     15.5409D0,0.0D0,5.3144D0,5.9885D0,2.1223D0,1.8273D0,
     *     16.5239D0,0.0D0,5.7152D0,6.4966D0,2.3561D0,2.0387D0,
     *     17.5075D0,0.0D0,6.1152D0,7.0041D0,2.5856D0,2.2547D0/
      DATA    XNS /1.0D0,2.0D0,3.0D0,3.7D0,4.0D0,4.2D0,4.4D0/
C     ==--------------------------------------------------------------==
C     Try the Clementi-Raimondi table
      IF(NATOM.LE.18.AND.L.LE.1) THEN
        SRULES=CR(L+1,N,NATOM)
        RETURN
      ENDIF
C     Calculate the shielding
      S=0.0D0
C     The complete shell
      L1=L+1
      IF(L1.EQ.1) L2=2
      IF(L1.EQ.2) L2=1
      IF(L1.EQ.3) L2=4
      IF(L1.EQ.4) L2=3
C     Rule a) no contribution from shells further out
C     Rule b) 0.35 (1s 0.3) from each other electron in the same shell
      IF(N.EQ.1) THEN
        M=NE(1,1)
        S=S+0.3D0*(M-1)
      ELSE
        M=NE(L1,N)+NE(L2,N)
        S=S+0.35D0*(M-1)
      ENDIF
C     Rule c) if (s,p) shell 0.85 from each electron with n-1, and 1.0
C          from all electrons further in
      IF(L1+L2.EQ.3) THEN
        IF(N.GT.1) THEN
          M1=NE(1,N-1)+NE(2,N-1)+NE(3,N-1)+NE(4,N-1)
          M2=0
          DO I=1,N-2
            M2=M2+NE(1,I)+NE(2,I)+NE(3,I)+NE(4,I)
          ENDDO
          S=S+0.85D0*M1+1.0D0*M2
        ENDIF
      ELSE
C       Rule d) if (d,f) shell 1.0 from each electron inside
        M=0
        DO I=1,N-1
          M=M+NE(1,I)+NE(2,I)+NE(3,I)+NE(4,I)
        ENDDO
        S=S+1.0D0*M
      ENDIF
C     Slater exponent is (Z-S)/NS
      SRULES = (DBLE(NATOM) - S)/XNS(N)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE READ_BASIS(IBTYPE)
C     ==--------------------------------------------------------------==
C     ==  THIS ROUTINE READS THE SECTION &BASIS &END ON UNIT IUNIT    ==
C     ==--------------------------------------------------------------==
C     ==  THE INPUT HAS TO BE IN THE FOLLOWING FORMAT                 ==
C     ==     &BASIS                                                   ==
C     ==        BASIS ATOM TYPE 1                                     ==
C     ==        ...                                                   ==
C     ==        BASIS ATOM TYPE N                                     ==
C     ==     &END                                                     ==
C     ==--------------------------------------------------------------==
C     ==  DEFINITION OF BASIS                                         ==
C     ==                                                              ==
C     ==  STO TYPE:                                                   ==
C     ==  ---------                                                   ==
C     ==      SLATER     nshell [OCCUPATION]                          ==
C     ==       n   l     exp                                          ==
C     ==       ...                                                    ==
C     ==       n   l     exp                                          ==
C     ==       [f1 f2 ... fn]                                         ==
C     ==                                                              ==
C     ==  NUMERICAL FUNCTIONS:                                        ==
C     ==  --------------------                                        ==
C     ==      *filename  nshell  [FORMAT=n]  [OCCUPATION]             ==
C     ==      l1 ... ln                                               ==
C     ==       [f1 f2 ... fn]                                         ==
C     ==                                                              ==
C     ==  GAUSSIAN BASIS FUNCTIONS:                                   ==
C     ==  -------------------------                                   ==
C     ==      *filename  nshell  GAUSSIAN [OCCUPATION]                ==
C     ==      l1 ... ln                                               ==
C     ==       [f1 f2 ... fn]                                         ==
C     ==                                                              ==
C     ==  PSEUDO ATOMIC ORBITALS:                                     ==
C     ==  -----------------------                                     ==
C     ==      PSEUDO AO  nshell  [OCCUPATION]                         ==
C     ==      l1 ... ln     lx=-1 --> skip                            ==
C     ==       [f1 f2 ... fn]                                         ==
C     ==                                                              ==
C     ==  SKIP ATOM TYPE:                                             ==
C     ==  ---------------                                             ==
C     ==      SKIP ATOM                                               ==
C     ==                                                              ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'atom.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'adat.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'atwf.inc'
      INCLUDE 'irat.inc'
      INCLUDE 'response_p.inc' !for tepr_hyp
      INCLUDE 'vdbp.inc'
C     Arguments
      INTEGER   IBTYPE(*)
C     VAriables
      DIMENSION ATRG(MMAXX,*),ATWFR(MMAXX,M1SHLX,*)
      DIMENSION ATRG_EPR(MMAXX,*),ATWFR_EPR(MMAXX,M1SHLX,*)
      INTEGER   IFNUM
      PARAMETER (IFNUM=21)
      REAL*8    ATRG2(MMAXX),RP(MMAXX),TEMP(MMAXX,3)
      POINTER   (IP_ATRG2,ATRG2),(IP_RP,RP),(IP_TEMP,TEMP)
      INTEGER   LSOLD(M1SHLX),NFMAX(4),NALP(4),NTT(4),
     &          IUNIT,IS,IERR,LENECP,NOLD,IA,IE,IOUT,I,IR,L,IAS,
     &          LGMAX,IL,J,IFORM,IAA,MESHAT2,IEOLD,IATOM,NPOINT,INS,
     &          INSCAN
      REAL*8    OCOLD(M1SHLX),GEXP(30,4),GCOE(30,5,4),
     &          DCLOG,RP1,RP2,CLOGAT2
      LOGICAL   EXISTS,ERREAD,TOCCUP
      CHARACTER LINE*80,ECPLIB*120,FILEN*200,SHLN(0:4)*1,FNAMES*200
      DATA SHLN /'S','P','D','F','G'/
C     ==--------------------------------------------------------------==
      IUNIT=5
      IERR=INSCAN(IUNIT,'&BASIS')
      IF(IERR.NE.0) RETURN
      IS=0
C     ==--------------------------------------------------------------==
C     Allocation of local variables
      CALL MEMORY(IP_ATRG2,MMAXX,'ATRG2')
      CALL MEMORY(IP_RP,MMAXX,'RP')
      CALL MEMORY(IP_TEMP,3*MMAXX,'TEMP')
C     ==--------------------------------------------------------------==
      CALL GET_PPLIB(ECPLIB,LENECP)
   10 CONTINUE
        READ(IUNIT,ERR=99,END=99,FMT='(A80)') LINE
        IF(INDEX(LINE,'&END').NE.0) GOTO 100
        IF(INDEX(LINE,'SLATER').NE.0) THEN
C         STO
          IS=IS+1
          NOLD=NSHELL(IS)
          CALL ICOPY(NOLD,LSHELL(1,IS),1,LSOLD,1)
          CALL DCOPY(NOLD,OC(1,IS),1,OCOLD(1),1)
          IF(IS.GT.NSP) CALL STOPGM('READ_BASIS','NSP')
          TOCCUP=.FALSE.
          IF(INDEX(LINE,'OCCUPATION').NE.0) TOCCUP=.TRUE.
C         Read STO
          CALL XSTRING(LINE,IA,IE)
C         Read NSHELL(IS)
          CALL READSI(LINE,IE+1,IOUT,NSHELL(IS),ERREAD)
          IF(ERREAD.OR.NSHELL(IS).LE.0) THEN
            WRITE(*,*) 'READ_BASIS! STO FOR IS=',IS
            CALL STOPGM('READ_BASIS','BAD VALUE FOR NSHELL')
          ENDIF
          DO I=1,NSHELL(IS)
            READ(IUNIT,END=99,ERR=99,FMT=*)
     *           NQSTO(I,IS),LSHELL(I,IS),STOEXP(I,IS)
          ENDDO
          MESHAT(IS)=256
          DCLOG=1.050D0
          CLOGAT(IS)=DLOG(DCLOG)
          ATRG(1,IS)=0.7142857D-03
          DO IR=2,MESHAT(IS)
            ATRG(IR,IS)=DCLOG*ATRG(IR-1,IS)
          ENDDO
          DO I=1,NSHELL(IS)
            L=LSHELL(I,IS)
            CALL STORPS(ATRG(1,IS),ATWFR(1,I,IS),MESHAT(IS),
     *                      NQSTO(I,IS),L,STOEXP(I,IS))
          ENDDO
          IF(TOCCUP) THEN
            READ(IUNIT,END=99,ERR=99,FMT=*) (OC(I,IS),I=1,NSHELL(IS))
          ELSE
            CALL FILLOC(NOLD,LSOLD,OCOLD,NSHELL(IS),
     *                  LSHELL(1,IS),OC(1,IS))
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'*').NE.0) THEN
C         Numerical AO or Gaussian AO
          IAS=INDEX(LINE,'*')
          LINE(IAS:IAS)=' '
          IS=IS+1
          IBTYPE(IS)=2
          NOLD=NSHELL(IS)
          CALL ICOPY(NOLD,LSHELL(1,IS),1,LSOLD,1)
          CALL DCOPY(NOLD,OC(1,IS),1,OCOLD(1),1)
          IF(IS.GT.NSP) CALL STOPGM('READ_BASIS','NSP')
          TOCCUP=.FALSE.
          IF(INDEX(LINE,'OCCUPATION').NE.0) TOCCUP=.TRUE.
C         Read *filename
          CALL XSTRING(LINE,IA,IE)
C         Read NSHELL(IS)
          CALL READSI(LINE,IE+1,IOUT,NSHELL(IS),ERREAD)
          IF(ERREAD.OR.NSHELL(IS).LE.0) THEN
            WRITE(*,*) 'READ_BASIS! ATOMIC ORBITAL FOR IS=',IS
            CALL STOPGM('READ_BASIS','BAD VALUE FOR NSHELL')
          ENDIF
          READ(IUNIT,*) (LSHELL(I,IS),I=1,NSHELL(IS))
          FILEN=ECPLIB(1:LENECP)//LINE(IA:IE)
          INQUIRE(FILE=FILEN,EXIST=EXISTS)
          IF(.NOT.EXISTS) THEN
            WRITE(*,*) ' READ_BASIS: FILE ',FILEN,' NOT FOUND'
            CALL STOPGM('READ_BASIS',' ')
          ENDIF
          OPEN(UNIT=IFNUM,FILE=FILEN,STATUS='UNKNOWN')
          REWIND(IFNUM)
          IF(INDEX(LINE,'GAUSS').NE.0) THEN
C           Gaussians
            READ(IFNUM,*) 
            READ(IFNUM,*) LGMAX
            DO IL=1,LGMAX
              READ(IFNUM,*)
              READ(IFNUM,*) NFMAX(IL),NALP(IL)
              READ(IFNUM,*)
              READ(IFNUM,*) (GEXP(I,IL),I=1,NALP(IL))
              DO J=1,NFMAX(IL)
                READ(IFNUM,*) (GCOE(I,J,IL),I=1,NALP(IL))
              ENDDO
            ENDDO
            MESHAT(IS)=256
            DCLOG=1.050D0
            CLOGAT(IS)=DLOG(DCLOG)
            ATRG(1,IS)=0.7142857D-03
            DO IR=2,MESHAT(IS)
              ATRG(IR,IS)=DCLOG*ATRG(IR-1,IS)
            ENDDO
            DO I=1,4
              NTT(I)=0
            ENDDO
            DO I=1,NSHELL(IS)
              L=LSHELL(I,IS)+1
              NTT(L)=NTT(L)+1
              CALL GTORPS(ATRG(1,IS),ATWFR(1,I,IS),MESHAT(IS),
     *                    L-1,GEXP(1,L),GCOE(1,NTT(L),L),NALP(L))
            ENDDO
          ELSE
C           Numerical
            IFORM=1
            IF(INDEX(LINE,'FORMAT=').NE.0) THEN
              IAA=INDEX(LINE,'FORMAT=')
              CALL READSI(LINE,IAA+7,IOUT,IFORM,ERREAD)
              IF(ERREAD) THEN
                CALL STOPGM('READ_BASIS','ERROR WHEN READING FORMAT')
              ENDIF
            ENDIF
            IF(IFORM.EQ.1) THEN
              READ(IFNUM,*) MESHAT(IS),CLOGAT(IS)
              IF(CLOGAT(IS).GT.1.0D0) CLOGAT(IS)=DLOG(CLOGAT(IS))
              DO IR=1,MESHAT(IS)
                READ(IFNUM,*) ATRG(IR,IS),
     *                          (ATWFR(IR,IL,IS),IL=1,NSHELL(IS))
              ENDDO
            ELSEIF(IFORM.EQ.2) THEN
              DO IL=1,NSHELL(IS)
                READ(IFNUM) MESHAT(IS),CLOGAT(IS),
     *           (ATRG(IR,IS),ATWFR(IR,IL,IS),IR=1,MESHAT(IS))
              ENDDO
              IF(CLOGAT(IS).GT.1.0D0) CLOGAT(IS)=DLOG(CLOGAT(IS))
            ELSEIF(IFORM.EQ.3) THEN
              READ(IFNUM,*) 
              DO IL=1,NSHELL(IS)
                READ(IFNUM,*) MESHAT(IS),CLOGAT(IS)
                DO IR=1,MESHAT(IS)
                   READ(IFNUM,*) ATRG(IR,IS),ATWFR(IR,IL,IS)
                ENDDO
              ENDDO
              IF(CLOGAT(IS).GT.1.0D0) CLOGAT(IS)=DLOG(CLOGAT(IS))
            ELSE
              WRITE(*,*) ' READ_BASIS: THIS FORMAT IS NOT PROGRAMMED'
              CALL STOPGM('READ_BASIS',' ')
            ENDIF
            CLOSE(IFNUM)
            MESHAT2=256
            RP1=ATRG(1,IS)
            RP2=ATRG(MESHAT(IS),IS)
            CALL CKGRID(RP1,RP2,ATRG2,MESHAT2,CLOGAT2)
            DO IL=1,NSHELL(IS)
              CALL TGRID(ATRG(1,IS),MESHAT(IS),ATRG2,
     *                   MESHAT2,ATWFR(1,IL,IS),
     &                   MMAXX,TEMP(1,1),TEMP(1,2),TEMP(1,3))
            ENDDO
            CALL DCOPY(MESHAT2,ATRG2(1),1,ATRG(1,IS),1)
            CLOGAT(IS)=CLOGAT2
            MESHAT(IS)=MESHAT2
          ENDIF
          IF(TOCCUP) THEN
            READ(IUNIT,END=99,ERR=99,FMT=*) (OC(I,IS),I=1,NSHELL(IS))
          ELSE
            CALL FILLOC(NOLD,LSOLD,OCOLD,NSHELL(IS),
     *                  LSHELL(1,IS),OC(1,IS))
          ENDIF
          GOTO 10
        ELSE IF( (INDEX(LINE,'PSEUDO').NE.0).AND.
     &            (INDEX(LINE,'AO').NE.0) ) THEN
C         Pseudo AO
          IS=IS+1
          IBTYPE(IS)=3
          NOLD=NSHELL(IS)
          CALL ICOPY(NOLD,LSHELL(1,IS),1,LSOLD,1)
          CALL DCOPY(NOLD,OC(1,IS),1,OCOLD(1),1)
          IF(IS.GT.NSP) CALL STOPGM('READ_BASIS','NSP')
          TOCCUP=.FALSE.
          IF(INDEX(LINE,'OCCUPATION').NE.0) TOCCUP=.TRUE.
C         Read PSEUDO
          CALL XSTRING(LINE,IA,IE)
          IEOLD=IE
C         Read AO
          CALL XSTRING(LINE(IE+1:80),IA,IE)
          IE=IEOLD+IE+1-1
C         Read NSHELL
          CALL READSI(LINE,IE+1,IOUT,NSHELL(IS),ERREAD)
          IF(ERREAD.OR.NSHELL(IS).LE.0) THEN
            WRITE(*,'(1X,A,I2)') 'READ_BASIS! PSEUDO AO FOR IS=',IS
            CALL STOPGM('READ_BASIS','BAD VALUE FOR NSHELL')
          ENDIF
          READ(IUNIT,*) (LSHELL(I,IS),I=1,NSHELL(IS))
          IATOM=IATYP(IS)
          FNAMES=ECPFILES(IS)
          CALL XSTRING(FNAMES,IA,IE)
C         Read also for USPP
          IF(TVAN(IS))THEN
             NPOINT=MESHVA(IS)-1
             DO IR=1,NPOINT
                ATRG(IR,IS)=VDB_R(IR+1,IS)
                DO IL=1,NSHELL(IS)
                  ATWFR(IR,IL,IS)=VDB_PAWF(IS,IR+1,IL)
                END DO
             END DO
          ELSE
             OPEN(UNIT=IFNUM,FILE=FNAMES(IA:IE),STATUS='UNKNOWN')
             IERR=INSCAN(IFNUM,'&WAVEFUNCTION')
            IF(IERR.NE.0)
     &         CALL STOPGM('READ_BASIS','SECTION WAVEFUNCTION')
            READ(IFNUM,*) NPOINT
            DO IR=1,NPOINT
              READ(IFNUM,ERR=99,FMT=*) ATRG(IR,IS),
     *              (ATWFR(IR,IL,IS),IL=1,NSHELL(IS))
            ENDDO
          END IF
          IF(TEPR_HYP) THEN
C RDeclerck
              MESH_EPR(IS)=NPOINT
              ATRG_EPR(1,IS)=1
              CALL DCOPY(MMAXX,ATRG(1,IS),1,
     *            ATRG_EPR(1,IS),1)
              CALL DCOPY(MMAXX*NSHELL(IS),ATWFR(1,1,IS),1,
     *            ATWFR_EPR(1,1,IS),1)
C RDeclerck
          ENDIF
          MESHAT(IS)=256
          CALL DCOPY(NPOINT,ATRG(1,IS),1,RP(1),1)
          RP1=RP(1)
          RP2=RP(NPOINT)
          CALL CKGRID(RP1,RP2,ATRG(1,IS),MESHAT(IS),CLOGAT(IS))
          DO IL=1,NSHELL(IS)
            CALL TGRID(RP,NPOINT,ATRG(1,IS),MESHAT(IS),
     *                 ATWFR(1,IL,IS),
     &                 MMAXX,TEMP(1,1),TEMP(1,2),TEMP(1,3))
          ENDDO
          INS=0
          DO IL=1,NSHELL(IS)
            IF(LSHELL(IL,IS).GE.0) THEN
              INS=INS+1
              IF(INS.NE.IL) THEN
                LSHELL(INS,IS)=LSHELL(IL,IS)
                CALL DCOPY(MESHAT(IS),ATWFR(1,IL,IS),1,
     *                                ATWFR(1,INS,IS),1)
              ENDIF
            ENDIF
          ENDDO
          NSHELL(IS)=INS
          CLOSE(IFNUM)
          IF(TOCCUP) THEN
            READ(IUNIT,END=99,ERR=99,FMT=*) (OC(I,IS),I=1,NSHELL(IS))
          ELSE
            CALL FILLOC(NOLD,LSOLD,OCOLD,NSHELL(IS),
     *                  LSHELL(1,IS),OC(1,IS))
          ENDIF
          GOTO 10
        ELSE IF(INDEX(LINE,'SKIP').NE.0) THEN
C         Skip this atom type
          IS=IS+1
          IF(IS.GT.NSP) CALL STOPGM('READ_BASIS','NSP')
          GOTO 10
        ELSE 
C         Dummy line
          GOTO 10
        ENDIF
C     ==--------------------------------------------------------------==
   99 CONTINUE
      WRITE(*,*) ' READ_BASIS  : ERROR IN READING INPUT FILE'
      CALL STOPGM('READ_BASIS',' ')
  100 CONTINUE
C     ==--------------------------------------------------------------==
C     Deallocation of local variables
      CALL FREEM(IP_ATRG2)
      CALL FREEM(IP_RP)
      CALL FREEM(IP_TEMP)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE FILLOC(NOLD,LSOLD,OCOLD,NSHELL,LSHELL,OC)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     Arguments
      INTEGER NOLD,LSOLD(NOLD),NSHELL,LSHELL(NSHELL)
      REAL*8  OCOLD(NOLD),OC(NSHELL)
C     Variables
      INTEGER IS,I,L,J
      REAL*8  F
C     ==--------------------------------------------------------------==
      DO IS=1,NSHELL
        OC(IS)=0.0D0
      ENDDO
      DO I=1,NOLD
        L=LSOLD(I)
        F=OCOLD(I)
        DO J=1,NSHELL
          IF(L.EQ.LSHELL(J).AND.OC(J).EQ.0.0D0) THEN
            OC(J)=F
            GOTO 10
          ENDIF
        ENDDO
   10   CONTINUE
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE LOADC(C0,FOC,LDC,NNGW,NDIM,IS,IAT,NATST)
C     ==--------------------------------------------------------------==
C     == Calculate atomic orbital in plane wave basis.                ==
C     == 
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'ions.inc'        !NAT
      INCLUDE 'atwf.inc'
      INCLUDE 'qspl.inc'
      INCLUDE 'sfac.inc'
      INCLUDE 'cppt.inc'
      INCLUDE 'geq0.inc'
C     Arguments
      INTEGER    NNGW,NDIM,NATST,IS,IAT,LDC
      COMPLEX*16 C0(LDC,NDIM)  
      REAL*8     FOC(*)
C     Variables
      DIMENSION  CAT(NSPLPO,2,M1SHL,NSX),GGNG(NSPLPO),GGNH(NSPLPO),
     &           EIGR(NGW,NAT)
      COMPLEX*16 CI,EI123
      DIMENSION  EIGRB(NHG,NAT)
      REAL*8     VOL,CC,
     &           CURV2,YLMR, FNL(*),DFNL(*)
      INTEGER    ISUB,LXX,ISH,L,LL,IV,LY,IG,
     &           LPP(5)
      DATA       LPP /0,1,4,9,16/
C     ==--------------------------------------------------------------==
      CALL TEST_SCR('LOADC','NNGW',LDC,NNGW)
      CALL TISET('     LOADC',ISUB)
      VOL=1.D0/SQRT(OMEGA)
      LXX=0
      DO ISH=1,NSHELL(IS)
        L=LSHELL(ISH,IS)
        CI=(0.0D0,1.0D0)**L
        LL=2*L+1
        DO IV=1,LL
          CALL TEST_SCR('LOADC','NDIM',NDIM,LXX+1)
          LXX=LXX+1
          CALL ZAZZERO(C0(1,LXX),LDC)
          LY=LPP(L+1)+IV
          IF(NBCUT.EQ.1) THEN
            IF(BIGMEM) THEN
!$OMP     parallel do private(IG,CC) shared(LY,NSPLPO)
#ifdef __SR8000
*poption parallel
#endif
              DO IG=1,NNGW
                CC=CURV2(HG(IG),NSPLPO,GGNH(1),CAT(1,1,ISH,IS),
     *             CAT(1,2,ISH,IS),0.0D0)*VOL
                C0(IG,LXX)=CI*YLMR(LY,IG,GK(1,1))*CC*EIGRB(IG,IAT)
              ENDDO
            ELSE
!$OMP     parallel do private(IG,CC,EI123) shared(LY,NSPLPO)
#ifdef __SR8000
*poption parallel
#endif
              DO IG=1,NNGW
                CC=CURV2(HG(IG),NSPLPO,GGNH(1),CAT(1,1,ISH,IS),
     *             CAT(1,2,ISH,IS),0.0D0)*VOL
                EI123=EI1(IAT,INYH(1,IG))*EI2(IAT,INYH(2,IG))*
     *                EI3(IAT,INYH(3,IG))
                C0(IG,LXX)=CI*YLMR(LY,IG,GK(1,1))*CC*EI123
              ENDDO
            ENDIF
          ELSEIF(NBCUT.EQ.0) THEN
            IF(NNGW.GT.NGW) CALL STOPGM('LOADC','NGW')
!$OMP     parallel do private(IG,CC) shared(LY,NSPLPO)
#ifdef __SR8000
*poption parallel
#endif
            DO IG=1,NNGW
              CC=CURV2(HG(IG),NSPLPO,GGNG(1),CAT(1,1,ISH,IS),
     *           CAT(1,2,ISH,IS),0.0D0)*VOL
              C0(IG,LXX)=CI*YLMR(LY,IG,GK(1,1))*CC*EIGR(IG,IAT)
            ENDDO
          ELSE
            CALL STOPGM('LOADC','NBCUT')
          ENDIF
          FOC(LXX)=OC(ISH,IS)/DBLE(LL)
        ENDDO
      ENDDO
      NATST=LXX
      CALL TIHALT('     LOADC',ISUB)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE DBASIS
C     ==--------------------------------------------------------------==
C     == UNUSED ROUTINE       (call once)                             ==
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
