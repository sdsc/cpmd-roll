C     ==================================================================
      SUBROUTINE WFOPTS
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'elct.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'pslo.inc'
      INCLUDE 'nlps.inc'
      INCLUDE 'atwf.inc'        !NUMAORMAX
      INCLUDE 'kpts.inc'
      INCLUDE 'kpnt.inc'
      INCLUDE 'clas.inc'
      INCLUDE 'sfac.inc'        ! ip_eigr
      INCLUDE 'coor.inc'        ! TAU0
      INCLUDE 'soft.inc'        ! EXSOFT
      INCLUDE 'bsym.inc'        ! BSFAC
      INCLUDE 'ddip.inc'
      INCLUDE 'cplngs.inc'      ! TCPL,TCPLLR
      INCLUDE 'spin.inc'        ! TLSE
C     Variables
      COMPLEX*16 C0(*),C2(*)
      REAL*8     PME(*),GDE(*),VPP(*),EIGV(*),SC0(*)
      POINTER    (IP_C0,C0),(IP_C2,C2),(IP_PME,PME),
     &           (IP_GDE,GDE),(IP_VPP,VPP),(IP_EIGV,EIGV),
     &           (IP_SC0,SC0)
      INTEGER    NSTATE,NC0,NC2,NCE,IUNIT,NPME,NGDE,NSC0,
     &           NEIG,NVPP,NXX
#ifdef PARALLEL
      INTEGER    NXXFUN
      EXTERNAL   NXXFUN
#endif
C     Dummy variables
      real*8     fnl,dfnl
C     ==--------------------------------------------------------------==
C     ==  MEMORY ALLOCATION                                           ==
C     ==--------------------------------------------------------------==
C     ==  C0    : WAVEFUNCTIONS                                       ==
C     ==  C2    : GRADIENTS                                           ==
C     ==  SC0   : S**(-1/2)*C0 (nonorthogonal orbitals)               ==
C     ==  PME   : DIIS WF         HNM1 (for CG)  CSCR (for DIAG)      ==
C     ==  GDE   : DIIS GRADIENTS                 CR   (for DIAG)      ==
C     ==  VPP   : WF HESSIAN                                          ==
C     ==  EIGV  : ORBITAL ENERGIES                                    ==
C     ==--------------------------------------------------------------==
C     ==--------------------------------------------------------------==
      NSTATE=N
C     Minimum requirements for all methods
      NC0  = 2*NGWK*NSTATE*NKPNT+8
      NC2  = 2*NGWK*MAX(NUMAORMAX,NSTATE)+8
      NSC0 = 1
      NVPP = 1
      NPME = 1
      NGDE = 1
      NEIG = NSTATE
C     Special requirements for diagonalization of wavefunction
      IF(TDIAG.OR.TDIAGOPT) THEN
        IF(TDAVI) THEN
          IF(NDAVV.EQ.0) THEN
            NDAVV=2*NSTATE
          ELSE
            NDAVV=MIN(NDAVV+NSTATE,2*NSTATE)
          ENDIF
          NC0  = MAX (NC0,  2*NGWK*NDAVV*NKPNT+8)
          NC2  = MAX (NC2,  2*NGWK*NDAVV+8)
          NVPP = MAX (NVPP, NGWK)
          NPME = MAX (NPME, 2*NGWK*NDAVV)
          NGDE = MAX (NGDE, 2*NGWK*NDAVV)
          NEIG = MAX (NEIG, NDAVV)
        ELSE
          IF(TFRSBLK) THEN 
            NCE = 2*NGWK*MAX(NSTATE,(NKRY_MAX+1)*NKRY_BLOCK)
          ELSE
            NCE = 2*NGWK*MAX(NSTATE,NKRY_MAX*NKRY_BLOCK)
          ENDIF
          NPME = MAX (NPME, NCE)
          NVPP = MAX (NVPP, NGW)
          NEIG = MAX (NEIG, NSTATE*NKPTS)
        ENDIF
      ENDIF
C     Minimum scratch space if used at all
      IF(TIVAN.OR.NONORT.OR.(PCG.AND.PCGMIN).OR.DIIS) THEN
        NSC0 = MAX (NSC0, 2*NGWK*NSTATE)
        IF(TDAVI)NSC0=MAX(NSC0,2*NGWK*NDAVV)
      ENDIF
      IF(TDIPD) THEN
#ifdef PARALLEL
        LENBK=NXXFUN(NSTATE)
        NXX=MAX(2*LENBK*NPROC,NC2)
#else
        NXX=NC2
#endif
        NSC0=MAX(NXX,NSC0)
        NC2=MAX(NXX,NC2)
      ENDIF
C     Special requirements for optimization of wavefunction
      IF(.NOT.TDIAG) THEN
        NEIG = MAX (NEIG, NSTATE*NKPTS)
        IF(NONORT) THEN
          NSC0 = MAX (NSC0, 2*NGWK*NSTATE*NKPNT)
        ELSEIF(TKPNT) THEN
          NSC0 = MAX (NSC0, NC2)
        ENDIF
        IF(TSDE) THEN
          NVPP = MAX (NVPP, NGWK)
        ELSE IF(DIIS) THEN
          NPME = MAX (NPME, (NGWK*NSTATE+8)*MDIIS*NKPNT) 
          NGDE = MAX (NGDE, ((NGWK*NSTATE+8)*MDIIS*NKPNT)/4)
          NVPP = MAX (NVPP, NGWK)
        ELSE IF(PCG) THEN
          NPME = MAX (NPME, 2*NGWK*NSTATE*NKPNT)
          NVPP = MAX (NVPP, NGWK)
        ELSE
          WRITE(*,*) ' WRONG OPTION FOR WAVEFUNCTION OPTIMIZATION'
          CALL STOPGM('WFOPTS',' OPTION      ')
        ENDIF
      ENDIF
C     Broken symmetry state
      IF(BSYMM) THEN
        NC0 = 2*NC0 
        NEIG = 2*NEIG
      ENDIF
C     Linear response needs KS matrix for LSE (no canonical states)
      IF(TLSE.AND.TCPL.AND.TCPLLR) NEIG = NSTATE*NSTATE*NKPTS
C     Allocate the memory
      CALL MEMORY(IP_C0,NC0,'C0')
      CALL MEMORY(IP_C2,NC2,'C2')
      CALL MEMORY(IP_SC0,NSC0,'SC0')
      CALL MEMORY(IP_PME,NPME,'PME')
      CALL MEMORY(IP_GDE,NGDE,'GDE')
      CALL MEMORY(IP_VPP,NVPP,'VPP')
      CALL MEMORY(IP_EIGV,NEIG,'EIGV')
      CALL AZZERO(EIGV,NEIG)
C     ==--------------------------------------------------------------==
      IF(TCLAS) THEN
        IUNIT=5
        CALL CL_INIT(IUNIT)
      ENDIF
      IF(TDAVI) NSTATE=NDAVV
C     FNL and DFNL
      CALL FNLALLOC(NSTATE,.TRUE.,TPRES)
      IF(PARENT) CALL PRMEM('    WFOPTS')
C     ==--------------------------------------------------------------==
      IF(TCPL) THEN
        IF(TCPLLR) CALL LR_IN
      ENDIF
C     ==--------------------------------------------------------------==
C CB
      if (.not.BSYMM) then 
        CALL RWFOPT(C0,C2,SC0,PME,GDE,VPP,EIGV)
      else
        call BS_WFO(C0,C2,SC0,PME,GDE,VPP,EIGV)
      endif
C     ==--------------------------------------------------------------==

      IF(TMEMCHK) CALL PRINT_MEMORY
      CALL FREEM(IP_EIGV)
      CALL FREEM(IP_SC0)
      CALL FREEM(IP_PME)
      CALL FREEM(IP_GDE)
      CALL FREEM(IP_VPP)

C     The following is due to a bad placing of the EIGR
C     arrays in memory: By deallocating and re-allocating,
C     they are placed at the first available memory location.
      if (TRESPONSE .AND. .NOT. EXSOFT) then
        CALL FREEM(IP_EIGR)
        CALL MEMORY(IP_EIGR,2*NGW*NAT,'EIGR')
        IF(BIGMEM) THEN
          CALL FREEM(IP_EIGRB)
          CALL MEMORY(IP_EIGRB,2*NHG*NAT,'EIGRB')
        ENDIF
        CALL PHFAC(TAU0)

        call do_perturbation(c0,c2,nstate)
      endif

      CALL FNLDEALLOC(.TRUE.,TPRES)
      CALL FREEM(IP_C0)
      CALL FREEM(IP_C2)
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
