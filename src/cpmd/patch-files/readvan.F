C     ==================================================================
      SUBROUTINE READVAN(IS,FILENAME)
C     ==--------------------------------------------------------------==
C     READ ULTRASOFT VANDERBILT PSEUDOPOTENTIALS
C     ==--------------------------------------------------------------==
C
C     ==--------------------------------------------------------------==
C     explanatory comments
C     ==--------------------------------------------------------------==
C
C     title    name of chemical element (character*20)
C     z        atomic number of element
C     zv       pseudo atomic number (net charge of bare ion core)
C     exfact   encodes type of exchange-correlation to use
C                if (exfact.eq.-1.) xctit='              wigner'
C                if (exfact.eq.-2.) xctit='     hedin-lundqvist'
C                if (exfact.eq.-3.) xctit=' gunnarson-lundqvist'
C                if (exfact.gt.0.)  xctit='      slater x-alpha'
C     nvales   number of l states to include
C                nvales=1  -->  s
C                nvales=2  -->  s,p
C                nvales=3  -->  s,p,d
C     mesh     number of radial mesh points
C     etot     total energy of pseudo atom in reference config
C     nnlz       100 s place --> n quantum number
C                 10 s place --> l quantum number
C                  1 s place --> (m quantum number) (really always 0)
C     wwnl     occupation
C     ee       eigenvalue
C
C     Note: nnlz,wwnl,ee give info on pseudo eigenstates; these are
C           always listed in the order s, p, d in current version
C
C     mesh     number of radial mesh points
C     keyps    encoding of type of pseudopotential:
C                0 --> standard hsc pseudopotential with exponent 4.0
C                1 --> standard hsc pseudopotential with exponent 3.5
C                2 --> vanderbilt modifications using defaults
C                3 --> new generalized eigenvalue pseudopotentials
C                4 --> frozen core all-electron case
C     ifpcor   1 if "nonlinear core correction" of louie, froyen,
C                and cohen to be used; 0 otherwise
C     rinner   radius at which to cut off partial core or q_ij
C
C     For true frozen core case, use keyps=4, ifpcor=1, rinner=0.
C     For keyps=3:
C
C     rc       cutoff radii for s,p,d respectively
C     nbeta    number of beta functions (sum over all l)
C     kkbeta   last radial mesh point used to describe functions
C                 which vanish outside core
C     lll      lll(j) is l quantum number of j th beta function
C     eee      energy at which construction was done
C     betar    beta function
C     dion     bare pseudopotential matrix (ionic and screening
C                parts subtracted out)
C     ddd      screened pseudopotential matrix (reference config)
C     qqq      Q_ij matrix
C     qfunc    Q_ij(r) function
C     qfcoef   coefficients to pseudize qfunc for different total
C                angular momentum (see below)
C     rcloc    cutoff radius used to construct local potential
C     rucore   bare local potential (see note below)
C     rscore   partial core charge
C     ru       screened local potential (see note below)
C     rsatom   charge density of pseudo atom (reference config)
C
C     Note: For consistency with HSC pseudopotentials etc., the
C           program carries a bare local potential rucore for
C           each l value.  For keyps=3 they are all the same.
C           In general, ru is the screened s potential (again
C           for keyps=3 it doesn t matter).
C
C     ------------------------------------------------------
C     Important:
C     ------------------------------------------------------
C     potentials, e.g. rucore, are really r*v(r)
C     wave funcs, e.g. snl, are really proportional to r*psi(r)
C       and are normalized so int dr (snl**2) = 1
C     thus psi(r-vec)=(1/r)*snl(r)*y_lm(theta,phi)
C     conventions carry over to beta, etc
C     charge dens, e.g. rscore, really 4*pi*r**2*rho
C     ------------------------------------------------------
C
C     ------------------------------------------------------
C     Notes on qfunc and qfcoef:
C     ------------------------------------------------------
C     Since Q_ij(r) is the product of two orbitals like
C     psi_{l1,m1}^star * psi_{l2,m2}, it can be decomposed by
C     total angular momentum L, where L runs over | l1-l2 | ,
C     | l1-l2 | +2 , ... , l1+l2.  (L=0 is the only component
C     needed by the atomic program, which assumes spherical
C     charge symmetry.)
C
C     Recall  qfunc(r) = y1(r) * y2(r)  where y1 and y2 are the
C     radial parts of the wave functions defined according to
C
C       psi(r-vec) = (1/r) * y(r) * Y_lm(r-hat)  .
C
C     For each total angular momentum L, we pseudize qfunc(r)
C     inside rc as:
C
C       qfunc(r) = r**(L+2) * [ a_1 + a_2*r**2 + a_3*r**4 ]
C
C     in such a way as to match qfunc and its 1 st derivative at
C     rc, and to preserve
C
C       integral dr r**L * qfunc(r)   ,
C
C     i.e., to preserve the L th moment of the charge.  The array
C     qfunc has been set inside rc to correspond to this pseudized
C     version using the minimal L, namely L = | l1-l2 | (e.g., L=0
C     for diagonal elements).  The coefficients a_i (i=1,2,3)
C     are stored in the array qfcoef(i,L+1,j,k) for each L so that
C     the correctly pseudized versions of qfunc can be reconstructed
C     for each L.  (Note that for given l1 and l2, only the values
C     L = | l1-l2 | , | l1-l2 | +2 , ... , l1+l2 are ever used.)
C     ------------------------------------------------------
C
C     Note that some of the variables included in the pseudo
C     file (e.g. rc, wwnl) will not be used by the solid state
C     program, but are included to help identify the pseudopo-
C     tential (i.e. they are printed out in subroutine psrprt).
C
C     Also arrays like ru, ddd, and rsatom are non-essential,
C     but are provided so that they can be used for generating
C     a starting guess at the potential.
C
C     ==--------------------------------------------------------------==
C
      IMPLICIT NONE
      include 'system.h'
      include 'atom.inc'
      include 'pslo.inc'
      include 'vdbp.inc'
      include 'ions.inc'
      include 'vdbt.inc'
C     Arguments
      INTEGER   IS
      CHARACTER FILENAME*(*),TESTERR*80
C     Variables
      LOGICAL   EXISTS
      CHARACTER TITLE*20,XCTYPE*20
      INTEGER   I,I2,IB,IT,IFIP2,IFN,IQF,IV,JV,J,K,LP,NBLOCK,
     &          IVER(3),IDMY(3),XC_FLAG,NNLZ(5),KEYPS,NANG,LLOC,IFQOPT,
     &          NQF,IREL,NLC,KEY(3),LLL(NBRX),IPTYPE(NBRX),NPF,
     &          TESTBETA(0:4),TESTLMAX,NATWF
      REAL*8    Z,EXFACT,ETOT,WWNL(5),EE(5),RINNER(5),ELOC,QTRYC,AA,
     &          AAA(3),EEE(NBRX),DDD(NBRX,NBRX),QFCOEF(13,5,NBRX,NBRX),
     &          PTRYC,RCLOC,RPCOR,DELTAX,RR,QF
C
C     ==--------------------------------------------------------------==
      DO I=1,3
        RC(IS,I) = 0.D0
      ENDDO
C     ==--------------------------------------------------------------==
      IFN=22
      INQUIRE(FILE=FILENAME,EXIST=EXISTS)
      IF (.NOT.EXISTS) THEN
        WRITE(*,*) ' READVAN: FILE NOT FOUND ',FILENAME
        CALL STOPGM(' READVAN',' ')
      ENDIF
C
      IF (.not.TBIN(IS)) GOTO 100
C
C     ==--------------------------------------------------------------==
C     READ UNFORMATTED INPUT PSEUDOPOTENTIAL FILE
C     ==--------------------------------------------------------------==
      OPEN(UNIT=IFN,FILE=FILENAME,STATUS='UNKNOWN',FORM='UNFORMATTED')
      REWIND(IFN)
C     ==--------------------------------------------------------------==
      READ(IFN) (IVER(I),I=1,3),(IDMY(I),I=1,3)
      TLOG(IS) = (IVER(1).GT.2)
C     ==--------------------------------------------------------------==
      READ(IFN) TITLE,Z,ZV(IS),EXFACT,NVALES(IS),MESHVA(IS),ETOT
      IATYP(IS) = NINT(Z)
      XC_FLAG = NINT(EXFACT)
      IF (MESHVA(IS).GT.MMAXX) 
     &  CALL STOPGM(' READVAN: ','mesh.gt.mmaxx ')
      IF (NVALES(IS).GT.5)
     &  CALL STOPGM(' READVAN: ','nvales.gt.5 ')
      READ(IFN) (NNLZ(I),WWNL(I),EE(I),I=1,NVALES(IS))
      READ(IFN) KEYPS,IFPCOR(IS),RINNER(1)
      IF (IVER(1).GE.3) THEN
        READ(IFN) NANG,LLOC,ELOC,IFQOPT,NQF,QTRYC
        IF (NQF.GT.13)
     &    CALL STOPGM(' READVAN: ','nqf.gt.13 ')
        IF ( (IFQOPT.GE.2) .AND. (IVER(1).LT.5) )
     &    CALL STOPGM(' READVAN: ','unsupported qfcoef')
      ENDIF
C     ==--------------------------------------------------------------==
      if (10*iver(1)+iver(2).ge.51) then
        read(ifn) (rinner(i),i=1,2*nang-1)
      else
        if (nang.gt.1) then
          do i=2,2*nang-1
            rinner(i) = rinner(1)
          enddo
        endif
      endif
      if (iver(1).ge.4) read(ifn) irel
C     ==--------------------------------------------------------------==
C     set the number of angular momentum terms in q_ij to read in
      IF (IVER(1).EQ.1) THEN
C       no distinction between nang and nvalps
        NANG = NVALES(IS)
C       no optimisation of q_ij so 3 term taylor series
        NQF = 3
        NLC = 5
      ELSEIF (IVER(1).EQ.2) THEN
C       no distinction between nang and nvalps
        NANG = NVALES(IS)
C       no optimisation of q_ij so 3 term taylor series
        NQF = 3
        NLC = 2*NVALES(IS)-1
      ELSE
        NLC = 2*NANG-1
      ENDIF
      IF (NLC.GT.5)
     &  CALL STOPGM(' READVAN: ','NLC.gt.5 ')
C     ==--------------------------------------------------------------==
      IF(KEYPS.LE.2) THEN
        READ(IFN) AA,KEY,AAA,(RC(IS,I),I=1,NVALES(IS))
        READ(IFN) ((RUCORE(I,LP,IS),I=1,MESHVA(IS)),LP=1,NVALES(IS))
      ELSEIF(KEYPS.EQ.3) THEN
        READ(IFN) (RC(IS,I),I=1,NANG)
        READ(IFN) NBETA(IS),KKBETA(IS)
        IF (NBETA(IS).GT.NBRX)
     &    CALL STOPGM(' READVAN: ','nbeta.gt.NBRX')
        DO J=1,NBETA(IS)
          READ(IFN) LLL(J),EEE(J),(BETAR(I,J,IS),I=1,KKBETA(IS))
          DO K=J,NBETA(IS)
            READ(IFN) DION(J,K,IS),DDD(J,K),QQQ(J,K,IS),
     &                (QFUNC(I,J,K,IS),I=1,KKBETA(IS)),
     &                ((QFCOEF(I,LP,J,K),I=1,NQF),LP=1,NLC)
            DION(K,J,IS) = DION(J,K,IS)
            DDD(K,J) = DDD(J,K)
            QQQ(K,J,IS) = QQQ(J,K,IS)
            DO I=1,nqf
              DO LP=1,nlc
                QFCOEF(I,LP,K,J) = QFCOEF(I,LP,J,K)
              ENDDO
            ENDDO
            DO I=1,KKBETA(IS)
              QFUNC(I,K,J,IS) = QFUNC(I,J,K,IS)
            ENDDO
          ENDDO
        ENDDO
        IF (10*IVER(1)+IVER(2).GE.72) THEN
          READ(IFN) (IPTYPE(J),J=1,NBETA(IS)),NPF,PTRYC
        ENDIF
        READ(IFN) RCLOC,(RUCORE(I,1,IS),I=1,MESHVA(IS))
      ELSEIF (KEYPS.EQ.4) THEN
        READ(IFN) ((RUCORE(I,LP,IS),I=1,MESHVA(IS)),LP=1,NVALES(IS))
      ELSE
        CALL STOPGM(' READVAN','KEYPS')
      ENDIF
cold
c      IF(IFPCOR(IS).GT.0) READ(IFN) (RSCORE(I,IS),I=1,MESHVA(IS))
cold
      IF (IFPCOR(IS).GT.0) THEN
        READ(IFN) RPCOR
        READ(IFN) (RSCORE(I,IS),I=1,MESHVA(IS))
      ENDIF
      READ(IFN) (RU(I,IS),I=1,MESHVA(IS))
      READ(IFN) (RSATOM(I,IS),I=1,MESHVA(IS))
C     ==--------------------------------------------------------------==
C     possible further read in of information in log meshva(is) case
      if ( tlog(is) ) then
        read(ifn) (r(i,is),i=1,meshva(is))
C
        do i=1,meshva(is)
           vdb_r(i,is)=r(i,is)
        end do
C
        read(ifn) (rab(i,is),i=1,meshva(is))
      endif
C     Read in pseudo atomic wavefunction
      if (iver(1) .ge. 6) then
       natwf = nvales(is)
       if (iver(1) .ge. 7) read (ifn) natwf
       read (ifn) ((vdb_pawf(is,i,j), i=1,meshva(is)),j=1,natwf)
      end if
C
C     ==--------------------------------------------------------------==
      CLOSE(IFN)
      GOTO 200
C
  100 CONTINUE
C     ==--------------------------------------------------------------==
C     READ PSEUDOPOTENTIAL FILE (FREE ASCII FORMAT)
C     ==--------------------------------------------------------------==
      OPEN(UNIT=IFN,FILE=FILENAME,STATUS='UNKNOWN',FORM='FORMATTED')
      REWIND(IFN)
C     ==--------------------------------------------------------------==
      READ(IFN,*) (IVER(I),I=1,3),(IDMY(I),I=1,3)
      TLOG(IS) = (IVER(1).GT.2)
C     ==--------------------------------------------------------------==
      READ(IFN,'(A20,3F15.9/2I5,1PE19.11)') TITLE,Z,ZV(IS),EXFACT,
     &                                    NVALES(IS),MESHVA(IS),ETOT
      IATYP(IS) = NINT(Z)
      XC_FLAG = NINT(EXFACT)
      IF (MESHVA(IS).GT.MMAXX) 
     &  CALL STOPGM(' READVAN: ','mesh.gt.mmaxx ')
      IF (NVALES(IS).GT.5)
     &  CALL STOPGM(' READVAN: ','nvales.gt.5 ')
      READ(IFN,*) (NNLZ(I),WWNL(I),EE(I),I=1,NVALES(IS))
      READ(IFN,*) KEYPS,IFPCOR(IS),RINNER(1)
      IF (IVER(1).GE.3) THEN
        READ(IFN,*) NANG,LLOC,ELOC,IFQOPT,NQF,QTRYC
        IF (NQF.GT.13)
     &    CALL STOPGM(' READVAN: ','nqf.gt.13 ')
        IF ( (IFQOPT.GE.2) .AND. (IVER(1).LT.5) )
     &    CALL STOPGM(' READVAN: ','unsupported qfcoef')
      ENDIF
C     ==--------------------------------------------------------------==
      if (10*iver(1)+iver(2).ge.51) then
        read(ifn,*) (rinner(i),i=1,2*nang-1)
      else
        if (nang.gt.1) then
          do i=2,2*nang-1
            rinner(i) = rinner(1)
          enddo
        endif
      endif
      if (iver(1).ge.4) read(IFN,*) irel
C     ==--------------------------------------------------------------==
C     set the number of angular momentum terms in q_ij to read in
      IF (IVER(1).EQ.1) THEN
C       no distinction between nang and nvalps
        NANG = NVALES(IS)
C       no optimisation of q_ij so 3 term taylor series
        NQF = 3
        NLC = 5
      ELSEIF (IVER(1).EQ.2) THEN
C       no distinction between nang and nvalps
        NANG = NVALES(IS)
C       no optimisation of q_ij so 3 term taylor series
        NQF = 3
        NLC = 2*NVALES(IS)-1
      ELSE
        NLC = 2*NANG-1
      ENDIF
      IF (NLC.GT.5)
     &  CALL STOPGM(' READVAN: ','NLC.gt.5 ')
C     ==--------------------------------------------------------------==
      IF(KEYPS.LE.2) THEN
        READ(IFN,*) AA,KEY,AAA,(RC(IS,I),I=1,NVALES(IS))
        READ(IFN,*) ((RUCORE(I,LP,IS),I=1,MESHVA(IS)),LP=1,NVALES(IS))
      ELSEIF(KEYPS.EQ.3) THEN
        READ(IFN,*) (RC(IS,I),I=1,NANG)
        READ(IFN,*) NBETA(IS),KKBETA(IS)
        IF (NBETA(IS).GT.NBRX)
     &    CALL STOPGM(' READVAN: ','nbeta.gt.NBRX')
        DO J=1,NBETA(IS)
          READ(IFN,*) LLL(J),EEE(J),(BETAR(I,J,IS),I=1,KKBETA(IS))
          DO K=J,NBETA(IS)
            READ(IFN,*) DION(J,K,IS),DDD(J,K),QQQ(J,K,IS),
     &                (QFUNC(I,J,K,IS),I=1,KKBETA(IS)),
     &                ((QFCOEF(I,LP,J,K),I=1,NQF),LP=1,NLC)
            DION(K,J,IS) = DION(J,K,IS)
            DDD(K,J) = DDD(J,K)
            QQQ(K,J,IS) = QQQ(J,K,IS)
            DO I=1,nqf
              DO LP=1,nlc
                QFCOEF(I,LP,K,J) = QFCOEF(I,LP,J,K)
              ENDDO
            ENDDO
            DO I=1,KKBETA(IS)
              QFUNC(I,K,J,IS) = QFUNC(I,J,K,IS)
            ENDDO
          ENDDO
        ENDDO
        IF (10*IVER(1)+IVER(2).GE.72) THEN
          READ(IFN,*) (IPTYPE(J),J=1,NBETA(IS)),NPF,PTRYC
        ENDIF
        READ(IFN,*) RCLOC,(RUCORE(I,1,IS),I=1,MESHVA(IS))
      ELSEIF (KEYPS.EQ.4) THEN
        READ(IFN,*) ((RUCORE(I,LP,IS),I=1,MESHVA(IS)),LP=1,NVALES(IS))
      ELSE
        CALL STOPGM(' READVAN','KEYPS')
      ENDIF
cold
c      IF(IFPCOR(IS).GT.0) READ(IFN,*) (RSCORE(I,IS),I=1,MESHVA(IS))
cold
      IF (IFPCOR(IS).GT.0) THEN
        READ(IFN,*) RPCOR
        READ(IFN,*) (RSCORE(I,IS),I=1,MESHVA(IS))
      ENDIF
      READ(IFN,*) (RU(I,IS),I=1,MESHVA(IS))
      READ(IFN,*) (RSATOM(I,IS),I=1,MESHVA(IS))
C     ==--------------------------------------------------------------==
c     possible further read in of information in log meshva(is) case
      if ( tlog(is) ) then
        read(ifn,*) (r(i,is),i=1,meshva(is))
        do i=1,meshva(is)
           vdb_r(i,is)=r(i,is)
        end do
        read(ifn,*) (rab(i,is),i=1,meshva(is))
      endif
C     Read in pseudo atomic wavefunction
      if (iver(1) .ge. 6) then
       natwf = nvales(is)
       if (iver(1) .ge. 7) read (ifn,*) natwf
       read (ifn,*) ((vdb_pawf(is,i,j), i=1,meshva(is)),j=1,natwf)
      end if
C     ==--------------------------------------------------------------==
      CLOSE(IFN)
C
  200 CONTINUE
C
C     ==--------------------------------------------------------------==
C     ==  G E N E R A T E  H E R M A N  S K I L L M A N  M E S H      ==
C     ==--------------------------------------------------------------==
      if ( .not. tlog(is) ) then
        nblock = (meshva(is))/40
        i = 1
        r(i,is) = 0.0D0
        cmesh(is) = 0.88534138d0/z**(1.d0/3.d0)
        deltax = 0.0025d0*cmesh(is)
        do j=1,nblock
          do k=1,40
            i = i+1
            r(i,is) = r(i-1,is) + deltax
          enddo
          deltax = deltax + deltax
        enddo
      endif
C     ==--------------------------------------------------------------==
C     == SMOOTHING
C     ==--------------------------------------------------------------==
      TPSEU(IS) = .FALSE.
      IF ( (IVER(1).GT.5) .AND. (IFQOPT.GE.2) ) TPSEU(IS) = .TRUE.
C
      IF (TPSEU(IS)) THEN
c
        DO LP=1,NLC
c
          do i2 = kkbeta(is),1,-1
            if (r(i2,is) .lt. rinner(LP)) goto 300
          enddo
          call STOPGM(' READVAN','rinner too small')
  300     continue
c
          DO IV=1,NBETA(IS)
            DO JV=IV,NBETA(IS)
c
              DO I=1,KKBETA(IS)
                QRL(I,IV,JV,LP,IS) = QFUNC(I,IV,JV,IS)
              ENDDO
              DO I=1,I2
                RR = R(I,IS)*R(I,IS)
                QF = QFCOEF(1,LP,IV,JV)
                do IQF =2,NQF
                  QF = QF + QFCOEF(IQF,LP,IV,JV)*RR**(IQF-1)
                enddo
                QRL(I,IV,JV,LP,IS) = QF*R(I,IS)**(LP+1)
              ENDDO
              DO I=1,KKBETA(IS)
                QRL(I,JV,IV,LP,IS) = QRL(I,IV,JV,LP,IS)
              ENDDO
c
            ENDDO
          ENDDO
c
        ENDDO
c
      ENDIF
C     ==--------------------------------------------------------------==
C     ==       P S E U D O P O T E N T I A L  R E P O R T             ==
C     ==--------------------------------------------------------------==
c
      xctype = ' '
      if (xc_flag.eq. 0) xctype = '      ceperley-alder'
      if (xc_flag.eq.-1) xctype = '              wigner'
      if (xc_flag.eq.-2) xctype = '     hedin-lundqvist'
      if (xc_flag.eq.-3) xctype = ' gunnarson-lundqvist'
      if (xc_flag.eq. 1) xctype = ' C-A + B88gx + LYPgc'
      if (xc_flag.eq. 2) xctype = ' C-A + B88gx        '
      if (xc_flag.eq. 3) xctype = ' C-A + B88gx + P86gc'
      if (xc_flag.eq. 4) xctype = ' Perdew Wang 1991   '
      if (xc_flag.eq. 5) xctype = ' PBE - GGA          '
      if (xc_flag.gt.99) then
        write(xctype,'(5x,I6)') xc_flag
      endif
C     ==--------------------------------------------------------------==
      IT=1
      WRITE(VDBTI(IT,IS),'(3X,60("="))')
      IT=IT+1
      write(VDBTI(IT,IS),1000) (iver(i),i=1,3),idmy(2),idmy(1),idmy(3)
 1000 format(3x,'|  pseudopotential report: version',i3,
     &       '.',i1,'.',i1,' date',i3,'-',i2,'-',i4,2x,'|')
      IT=IT+1
      WRITE(VDBTI(IT,IS),'(3X,60("-"))')
      IT=IT+1
      write(VDBTI(IT,IS),1010) title,xctype
 1010 format(3x,'|  ',2a20,' exchange-corr  |')
      IT=IT+1
      write(VDBTI(IT,IS),1020) z,zv(is),exfact
 1020 format(3x,'|  z =',f7.2,2x,'zv =',f7.2,2x,'exfact =',f10.5,
     &       13x,'|')
      IT=IT+1
      write(VDBTI(IT,IS),1030) etot
 1030 format(3x,'|     ',9x,'    ',9x,' etot  =',f10.5,13x,'|')
      IT=IT+1
      write(VDBTI(IT,IS),1040)
 1040 format(3x,'|  index    orbital      occupation    energy',14x,'|')
      DO I=1,nvales(is)
        IT=IT+1
        write(VDBTI(IT,IS),1050) i,nnlz(i),wwnl(i),ee(i)
      ENDDO
 1050 format(3x,'|',i5,i11,5x,f10.2,f12.2,15x,'|')
c
      IT=IT+1
      IF (10*iver(1)+iver(2).ge.51) then
        WRITE(VDBTI(IT,IS),1061) keyps,ifpcor(is)
 1061   format(3x,'|  keyps =',i2,5x,'ifpcor =',i2,32x,'|')
        do i = 1,2*nang-1
          IT=IT+1
          WRITE(VDBTI(IT,IS),1065) rinner(i),i
        enddo
 1065   format(3x,'|  rinner =',f10.2,5x,'for L=',i5,22x,'|')
      else
        WRITE(VDBTI(IT,IS),1060) keyps,ifpcor(is),rinner(1)
 1060   format(3x,'|  keyps =',i2,5x,'ifpcor =',i2,5x,'rinner =',
     &         f10.4,9x,'|')
      endif
C     ==--------------------------------------------------------------==
      if (keyps.le.2) then
C     ==--------------------------------------------------------------==
      elseif (keyps.eq.3) then
c       new scheme
        IT=IT+1
        write(VDBTI(IT,IS),1120)
 1120   format(3x,'|    new generation scheme:',32x,'|')
        IT=IT+1
        write(VDBTI(IT,IS),1130) nbeta(is),kkbeta(is),rcloc
 1130   format(3x,'|    nbeta = ',i2,5x,'kkbeta =',i5,5x,
     &         'rcloc =',f10.4,4x,'|')
        IT=IT+1
        write(VDBTI(IT,IS),1135)
 1135   format(3x,'|    ibeta     l     epsilon   rcut iptype',17x,'|')
        call iazzero(testbeta(0),5)
        testlmax=-1
        do ib=1,nbeta(is)
          lp=lll(ib)+1
          IT=IT+1
          if(lll(ib).gt.testlmax) testlmax=lll(ib)
          testbeta(lll(ib))=testbeta(lll(ib))+1
          if (10*iver(1)+iver(2).lt.72) iptype(ib)=-1
c           -1 means iptype was not recorded and is unknown
          write(VDBTI(IT,IS),1150) ib,lll(ib),eee(ib),rc(is,lp),
     &                             iptype(ib)
        enddo
 1150   format(3x,'|',6x,i2,5x,i2,4x,2f7.2,6x,i1,18x,'|')

c     AK: the current (28.05.2004) vanderbilt implementation requires
c         the same number of projectors for all angular momentums and
c         does not allow to skip one. check this.
        do ib=1,testlmax
          if(testbeta(ib).ne.testbeta(0)) then
            if(parent) then
              call xstring(filename,i,i2)
              testerr = filename(i:i2) // ' INCOMPATIBLE WITH CPMD'
              call stopgm('READVAN', testerr)
            endif
          endif
        enddo
c
        if (10*iver(1)+iver(2).ge.72) then
          ifip2=0
          do ib=1,nbeta(is)
            if (iptype(ib).eq.2) ifip2=1
          enddo
          if (ifip2.eq.1) then
            IT=IT+1
            write(VDBTI(IT,IS),1155) npf,ptryc
 1155       format(3x,'|  npf    =',i2,'  ptryc =',f8.3,29x,'|')
          endif
        endif
c 
        if (iver(1).gt.2) then
          IT=IT+1
          write(VDBTI(IT,IS),1160) lloc,eloc
 1160     format(3x,'|  lloc   =',i2,'  eloc   =',f8.3,28x,'|')
          IT=IT+1
          write(VDBTI(IT,IS),1170) ifqopt,nqf,qtryc
 1170     format(3x,'|  ifqopt =',i2,'  nqf    =',i2,'  qtryc =',f8.3,
     &           17x,'|')
        endif
c
        IT=IT+1
        if ( (iver(1).gt.3) .and. (irel.eq.2) ) then
          write(VDBTI(IT,IS),1180) 'koelling-harmon equation'
        else
          write(VDBTI(IT,IS),1180) 'schroedinger equation   '
        endif
 1180   format(3x,'|',2x,'all electron calculation used ',a24,2x,'|')
c
        IT=IT+1
        if ( .not. tlog(is) ) then
          write(VDBTI(IT,IS),2000) 'herman skillman mesh'
        else
          write(VDBTI(IT,IS),2000) '**logarithmic mesh**'
        endif
 2000   format(3x,'|',9x,10('*'),a20,10('*'),9x,'|')
C     ==--------------------------------------------------------------==
      elseif (keyps.eq.4) then
c       frozen core
c       write (*,2500)
c       2500   format(3x,'|    frozen core all-electron case',25x,'|')
      endif
C     ==--------------------------------------------------------------==
      IT=IT+1
      write(VDBTI(IT,IS),3000)
 3000 format(3x,60("="))
      ITMAX(IS) = IT
      NVALES(IS) = NANG
C     ==--------------------------------------------------------------==
      RETURN
      END
