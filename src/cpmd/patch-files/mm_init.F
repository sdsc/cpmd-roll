C     ==================================================================
      SUBROUTINE MM_INIT
C     ==--------------------------------------------------------------==
      IMPLICIT NONE

      INCLUDE 'system.h'
      INCLUDE 'irat.inc'
      INCLUDE 'coor.inc'
      INCLUDE 'rmas.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'store.inc'
      INCLUDE 'isos.inc'
      INCLUDE 'cotr.inc'
c     QM/MM. see. below for compatibility init for normal QM runs.
#if defined (__GROMOS)
cMcB
      INTEGER NPM,NSM,NTX,IG,NTXO
      COMMON /MSTART/ NPM,NSM,NTX,IG,NTXO
      include 'fileopen.inc'
      include 'adat.inc'
cMcB
      include 'cell.inc'
      include 'mm_dim.inc'
      include 'mm_input.inc'
      include 'mm_ion_dens.inc'
c  locals
      integer NSX_s
      integer i,ia,is,iis,NRTOT,NATTOT
      integer NSPq_s,NAq_s,ia2,is2,diffe1,diffe2
      DIMENSION LVELINI(*)
      real*8 dum(3),XM(3)
      real*8 xmax,ymax,zmax,xmin,ymin,zmin
      real*8 diffesto,diffevol
      integer MSGLEN
      logical ferror
C     ==--------------------------------------------------------------==
C     == INITIALIZATION                                               ==
C     ==--------------------------------------------------------------==

      mm_stat=.true.

      if(.not. qmmm) then
        CALL MM_COMPAT_INIT
        return
      endif

      NSX_s=NSX
      call allocate_gromos

      IF (MMPARENT) THEN
        call mm_setup(NRPT,NSOLV)
        if(tflexsol)then
          call mm_flex_solv(NRPT,NSOLV)
        endif
        if(cap_H .or. N_carbon.gt.0)then
          call mm_add_dummy(NRPT,NSOLV)
        endif
        if(N_carbon.gt.0)then
          call mm_add_hydrogen
        endif
        if(cap_H)then
          call mm_CAP_H( NRPT, NSOLV)
        endif
        NRTOT=NRPT+NSOLV
! define new NAX and NSX
        call mm_get_NSX(NSPq,NRPT,NSOLV)
        if(.not.classical) then
          call mm_quantum_topo(NSPq,NRPT,NSOLV)
        endif
      endif
!!!!!!!!!!!!!!!!!!!!!!!!!!!
      MSGLEN=8/IRAT
      CALL MY_BCAST(NAX,MSGLEN,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NSX,MSGLEN,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NRPT,MSGLEN,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NSOLV,MSGLEN,MMSOURCE,QMMMGRP)
      NRTOT=NRPT+NSOLV
C FIXME: AK 2005/05/24. memory allocates real*8 words, if we would
C use (NRTOT+1)/IRAT to significantly reduce the memory requirements for 
C all integer arrays based on NRTOT on systems with IRAT=2 (i.e. most current
C platforms). this will be especially useful for systems with a large MM part.
      CALL MEMORY(ip_cpat,NRTOT,'cpat')
      CALL MEMORY(ip_cpsp,NRTOT,'cpsp')
      CALL MEMORY(IP_NAm,NSX,'NAm')
      CALL MEMORY(IP_NAq,NSX,'NAq')
C FIMXE: AK 2005/05/24 gratom can become especially big.
C we should try to get rid of it. it is rarely used, too.
C -> mm_nlist.F/mm_short_range_classic.F
      CALL MEMORY(ip_gratom,NAX*NSX,'gratom')
      CALL MEMORY(ip_NAT_cpmd,NRTOT+NDAT+1,'NAT_cpmd')
      CALL MEMORY(ip_NAT_grm,NRTOT+1,'NAT_grm')
      if(MMPARENT) then
        call mm_detit(cpat,cpsp,NAT_cpmd,NAT_grm,gratom,
     c          NAq,NSPq,NAm,NSPm,NATq,NAXq,NATm,NRPT,NSOLV)
      endif
C check wether the exclusions are valid
      ferror=.false.
      DO i=1,NCe
        ia=atom_qm_excl(i)
        IF((ia.gt.NATm).or.(ia.lt.1))THEN
          IF(MMPARENT) THEN
            write(*,200) i,'QM ATOM',ia,'IS NOT A VALID ATOM'
            ferror=.true.
          ENDIF
        ENDIF
        IF(NAT_cpmd(ia).gt.NATq) THEN
          IF(MMPARENT) THEN
            write(*,200) i,'   ATOM',ia,'IS NOT A QM ATOM'
            ferror=.true.
          ENDIF
        ENDIF
        ia=atom_mm_excl(i)
        IF((ia.gt.NATm).or.(ia.lt.1))THEN
          IF(MMPARENT) THEN
            write(*,200) i,'MM ATOM',ia,'IS NOT A VALID ATOM'
            ferror=.true.
          ENDIF
        ENDIF
        IF(NAT_cpmd(ia).le.NATq) THEN
          IF(MMPARENT) THEN
            write(*,200) i,'   ATOM',ia,'IS NOT AN MM ATOM'
            ferror=.true.
          ENDIF
        ENDIF
      ENDDO
  200 FORMAT (1X,'MM_INIT| EXCLUSION ',I5,':',2X,A,I8,1X,A)
      IF(ferror) CALL STOPGM('MM_INIT','ERROR IN EXCLUSION LIST')
      IF(MAXWRITEATOM.GT.NATm) MAXWRITEATOM=NATm

      CALL MY_BCAST(NAq, 8/IRAT*NSX,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NAm, 8/IRAT*NSX,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NSPm,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NSPq,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NATq,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NAXq,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NATm,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(MAXWRITEATOM,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(cpat,8/IRAT*NRTOT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(cpsp,8/IRAT*NRTOT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NAT_cpmd,8/IRAT*(NRTOT+NDAT+1),MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NAT_grm,8/IRAT*(NRTOT+1),MMSOURCE,QMMMGRP)
      CALL MY_BCAST(gratom,8/IRAT*NAX*NSX,MMSOURCE,QMMMGRP)
! 
cmb      ALLOCATE(mm_charge(NAX,NSX))
      CALL MEMORY(ip_mm_charge,NAX*NSX,'mm_charge')
      CALL MEMORY(ip_INC_l,NAX*NSX,'ip_INC')
      IF (MMPARENT) THEN 
        call  mm_pardef(PMA,PMA0,PMAT0,PMATOT,
     c          mm_charge,box_au,INC_l,NCAG_l,
     c          NRAM_gr,NCONS_gr,
     c          IATYP,mm_RAGGIO,
     c          NRPT,NSOLV,NAX,cpat,cpsp,NSPm,NAm)
      ENDIF
      CALL MY_BCAST(PMAT0,8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(PMATOT,8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(PMA,MAXSP*8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(PMA0,MAXSP*8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(mm_charge,NAX*NSX*8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(box_au,3*8,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(INC_l,NAX*NSX*8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NCAG_l,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NRAM_gr,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(NCONS_gr,8/IRAT,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(mm_RAGGIO,8*MAXSP,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(iatyp,MAXSP*8/IRAT,MMSOURCE,QMMMGRP)
!
! set initial positions; no initial velocities allowed
!
      CALL FREEM(IP_TAU0)
      CALL FREEM(IP_VELP)
      CALL MEMORY(IP_TAU0,3*NAX*NSX,'TAU0')
      CALL MEMORY(IP_VELP,3*NAX*NSX,'VELP')
      IF(MMPARENT) THEN
        call mm_readgromos(NAX,NSX,TAU0)
! the quantum system can be split in two pieces due to pbc. 
! First take the minimal image with respect the position of the first atom

        IF(tcent)THEN
! Beware, changed (F Gervasio): now it loops on all atoms
! To look for the minimal image with the smaller rmax-rmin (r=x,y,z)
          call mm_best(TAU0,NAX,NSX,XM,VELP,diffe1,diffe2,diffevol)
          CALL mm_min_im(TAU0,VELP,NAX,NSX,XM) 
          CALL DCOPY(3*NAX*NSX,VELP(1,1,1),1,TAU0(1,1,1),1)
! The cdm of the quantum system is translated to the center of the quantum cell
          CALL mm_center(TAU0,XM,.FALSE.)
          WRITE(*,*) "Cell Volume",VOLCEL 
! The minimal image with respect to the center of the quantum cell is taken
          XM(1)=0.5D0*CELLDM(1)
          XM(2)=0.5D0*CELLDM(2)*CELLDM(1)
          XM(3)=0.5D0*CELLDM(3)*CELLDM(1)
          CALL mm_min_im(TAU0,VELP,NAX,NSX,XM)
          CALL DCOPY(3*NAX*NSX,VELP(1,1,1),1,TAU0(1,1,1),1)
        ENDIF
      ENDIF

      CALL MY_BCAST(TAU0,3*NAX*NSX*8,MMSOURCE,QMMMGRP)

cMcB
      CALL AZZERO(VELP,3*NAX*NSX)  !no initial velocity!!!

      IF ( MMPARENT ) THEN
         NTX_vel=0
         IF ( NTX.EQ.2 ) THEN
            NTX_vel=1
c          ... load GROMOS velocities ...
            call mm_readgromos_vel(NAX,NSX,VELP)
         ENDIF
      ENDIF

      MSGLEN=8/IRAT
      CALL MY_BCAST(NTX_vel,MSGLEN,MMSOURCE,QMMMGRP)
      CALL MY_BCAST(VELP,3*NAX*NSX*8,MMSOURCE,QMMMGRP)
cMcB
      CALL FREEM(IP_LVELINI)
      CALL MEMORY(IP_LVELINI,(NAX+1)*NSX,'LVELINI')
      DO IS=1,NSX
        IIS=(IS-1)*(NAX+1)
        DO IA=1,NAX+1
          LVELINI(IIS+IA)=.FALSE.
        ENDDO
      ENDDO
      NSX=NSX_s
cMcB      
C     write table of the internal ordering.
      CALL FILEOPEN(17,'QMMM_ORDER',FO_DEF,FERROR)
      WRITE(17,'(''#'')')
      WRITE(17,'(''# NRTOT ='',i8,3x,''NATq ='',i8)') NRTOT,NATq
      WRITE(17,'(''#'')')
      WRITE(17,'(''#__GROMOS_____CPMD_______is_______ia___SYMBOL_'')')
      i=0 
      DO is=1,NSPm
        DO ia=1,NAm(is)
          i=i+1
          WRITE(17,'(4(1x,i8),7x,a2)') NAT_grm(i),i,is,ia,EL(iatyp(is))
        ENDDO   
      ENDDO                           
      WRITE(17,'(''#---------------------------------------------'')')
      CALL FILECLOSE(17)
cMcB      
      RETURN
#else /* !__GROMOS */
C     directly call stub version for non-QM/MM compile.
      CALL MM_COMPAT_INIT
      RETURN
#endif
      END
#if defined (__GROMOS)
c     ==================================================================
      SUBROUTINE MM_BEST(TAU0,NAX,NSX,XM,VELP,diffe1,diffe2,diffevol)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      integer NAX,NSX
      real*8  TAU0(3,NAX,*),VELP(3,NAX,*)
      real*8  XM(3)
      include  'mm_dim.inc'
      include  'cell.inc'
!  locals
      real*8 diffesto,diffevol
      integer IA,IS,diffe1,diffe2,I
      diffesto=1.0D09

      DO IS=1,NSPq
        DO IA=1,NAq(IS)   
          XM(1)=TAU0(1,IA,IS)
          XM(2)=TAU0(2,IA,IS)
          XM(3)=TAU0(3,IA,IS)
          CALL mm_min_im(TAU0,VELP,NAX,NSX,XM) 
          CALL DCOPY(3*NAX*NSX,VELP(1,1,1),1,TAU0(1,1,1),1)
! The cdm of the quantum system is translated to the center of the quantum cell
          CALL mm_center(TAU0,XM,.FALSE.)
! Here it checks if the new minimal image has
! the smallest rmax-rmin
          diffevol=VOLCEL
          IF (diffesto.gt.diffevol.and.diffevol.ne.0) THEN
             diffe1=IA
             diffe2=IS      
             diffesto=diffevol
             WRITE(*,*) 'best',IA,IS,diffevol
          ENDIF
        ENDDO
      ENDDO
      XM(1)=TAU0(1,diffe1,diffe2)
      XM(2)=TAU0(2,diffe1,diffe2)
      XM(3)=TAU0(3,diffe1,diffe2)
      RETURN
      END
C     ==================================================================
#endif

C     this subroutine sets up some arrays and variable introduced with the
C     QM/MM code to normal-QM compatible stub versions. the purpose of this
C     is to limit the amount of special case code and thus improve manageability.
C     AK 2005/05/25.
      SUBROUTINE MM_COMPAT_INIT
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'irat.inc'
      INCLUDE 'ions.inc'
      INCLUDE 'store.inc'
      INCLUDE 'mm_dim.inc'
      INCLUDE 'mm_input.inc'
      INCLUDE 'cotr.inc'

      INTEGER I,IS,IA,MSGLEN

      mm_stat=.true.       ! we are (and stay) in QM dimensions.
      qmmm_verbose=.false. ! no verbose QM/MM output.

C     Initialize QM/MM energies
      eqm=0.0d0
      eqmmm=0D0
      eqmmm0=0D0
      eqmmm_cl=0D0
      emm=0D0
      eext0=0D0
      eexcl=0D0

C     initialize NAT_cpmd to have an 1:1 atom index mapping 
C     for normal inputs and outputs.
      NATm=0
!$OMP parallel do private(IS) reduction(+:NATm)
      DO IS=1,NSX
        NATm=NATm+NA(IS)
      END DO
      NATq=NATm
      NAXq=NAX
      IF(MAXWRITEATOM.GT.NATm) MAXWRITEATOM=NATm

      MSGLEN=8/IRAT
      CALL MY_BCAST(NATm,MSGLEN,SOURCE,ALLGRP)
      CALL MY_BCAST(NATq,MSGLEN,SOURCE,ALLGRP)
      CALL MY_BCAST(NAXq,MSGLEN,SOURCE,ALLGRP)
      CALL MY_BCAST(MAXWRITEATOM,MSGLEN,SOURCE,ALLGRP)

      I=(NATm+NDAT+2)/IRAT
      CALL MEMORY(ip_NAT_cpmd,I,'NAT_cpmd')
      CALL MEMORY(ip_NAT_grm,I,'NAT_grm')
      CALL MEMORY(ip_cpsp,I,'cpsp')
      CALL MEMORY(ip_cpat,I,'cpat')
      CALL MEMORY(ip_gratom,NAX*NSX,'gratom')
      CALL IAZZERO(gratom,NAX*NSX)
!$OMP parallel do private(I)
#ifdef __SR11000
*poption parallel, tlocal(I)
#endif
      DO I=0,NATm
        NAT_cpmd(I)=I
        NAT_grm(I)=I
      END DO
C     Dummy atoms are included in NAT_cpmd
      IF(NDAT.GT.0)THEN
        IF(PARENT) THEN
          WRITE(6,'(/,A)')' DUMMY ATOMS INDICES: #DUM,  INDEX' 
        ENDIF
        IA=0
        DO I=NATm+1,NATm+NDAT
          IA=IA+1
          NAT_cpmd(I)=I
          NAT_grm(I)=I
          IF(PARENT) THEN
            WRITE(6,'(20X,I5,I8)') IA, I
          ENDIF
        END DO
      END IF
      I=1
      DO IS=1,NSX
        DO IA=1,NA(IS)
          cpat(I)=IA
          cpsp(I)=IS
          gratom((IS-1)*NAX+IA)=I
          I=I+1
        END DO
      END DO
      MSGLEN=8/IRAT*(NATm+1+NDAT)
      CALL MY_BCAST(NAT_cpmd,MSGLEN,SOURCE,ALLGRP)
      MSGLEN=8/IRAT*(NATm+1)
      CALL MY_BCAST(NAT_grm,MSGLEN,SOURCE,ALLGRP)
      CALL MY_BCAST(cpsp,MSGLEN,SOURCE,ALLGRP)
      CALL MY_BCAST(cpat,MSGLEN,SOURCE,ALLGRP)
      MSGLEN=8/IRAT*NAX*NSX
      CALL MY_BCAST(gratom,MSGLEN,SOURCE,ALLGRP)
      RETURN
      END
