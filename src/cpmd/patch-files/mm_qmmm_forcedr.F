C     ==================================================================
      SUBROUTINE mm_qmmm_forcedr(C0,C2,SC0,RHOE,PSI,TAU,FION,
     *             EIGV,SCR,LSCR,NSTATE,IL_RHOE,LPROJ,update_pot,
     *             update_files)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
!
      include 'system.h'
      include 'ener.inc'
      include 'irat.inc'
      include 'ropt.inc'
      include 'bsym.inc'
!
      include 'mm_input.inc'
      include 'mm_dim.inc'

      REAL*8     TAU(3,NAX,*)
      REAL*8     FION(3,NAX,*)
      COMPLEX*16 C0(NGW,*),C2(NGW,*),SC0(NGW,*)
      REAL*8     RHOE(*),SCR(*),EIGV(*),epot_mm,elstat_inten
      COMPLEX*16 PSI(*) 
      INTEGER    LSCR,NSTATE,IL_RHOE,i_do
      LOGICAL    status,statusdummy,LPROJ,update_pot
cmb -> temporary solution to be eliminated at the time
cmb -> of SAMPLE keyword and timestep printout rewrite
      LOGICAL    update_files ! cmb - temporary solution
!
      REAL*8  mm_FION(3,NAX,NSX)
      POINTER (IP_mm_FION,mm_FION)
      INTEGER i,is,ig,ix,ia
      REAL*8  TIMEF1,TIMEF2,TIMEEI1,TIMEEI2
      REAL*8  TIMEG1,TIMEG2,TIMEF,time_rho
      EXTERNAL TIMEF
      REAL*8  c_trans(3)
      REAL*8  e_fix
      SAVE e_fix
C
C     For Vanderbilt PPs
      REAL*8  QMMM_XMAT1(NSTATE*NSTATE,*),QMMM_XMAT2(*)
      POINTER (IP_QMMM_XMAT1,QMMM_XMAT1),(IP_QMMM_XMAT2,QMMM_XMAT2)
      INTEGER QMMM_ICON,NUMX,IPX
      DATA    QMMM_ICON /0/
      SAVE    QMMM_ICON,IP_QMMM_XMAT1,IP_QMMM_XMAT2
!
#if defined (__GROMOS)
      call my_sync(QMMMGRP)
      time_rho=0.d0
      call mm_dim(mm_go_mm,status)
      CALL MEMORY(IP_mm_FION,3*NAX*NSX,'mm_FION')
      if(N_CG.ne.0)update_pot=.true. ! the potential changes also during a quench BO

      call my_bcast(TAU,3*NAX*NSX*8,QMMMSOURCE,QMMMGRP)

      CALL AZZERO(mm_FION,3*NAX*NSX)
      CALL AZZERO(FION,3*NAX*NSX)
      elstat_inten=0.d0
      if(coupl_model.ge.1)then
        TIMEEI1=TIMEF()
        if(qmnode) then 
C
C         Added for Vanderbilt PPs
          IF(QMMM_ICON.EQ.0 .AND. NONORT .AND. PARENT) THEN
            NUMX=1
            IF(BSYMM)NUMX=2
            CALL MEMORY(IP_QMMM_XMAT1,NSTATE*NSTATE*NUMX,'QMMM_XMAT1')
            CALL MEMORY(IP_QMMM_XMAT2,NSTATE*NSTATE,'QMMM_XMAT2')
            DO I=1,NUMX
                CALL UNITMX(QMMM_XMAT1(1,I),NSTATE)
            ENDDO
            QMMM_ICON=1
          END IF
C
C         Calculate the electronic density
          IF(NONORT)THEN
            IF(BSYMM)THEN
              IPX=BSCLCS
            ELSE
              IPX=1
            END IF
C           Calculate electronic density for nonorthogonal basis
            call mm_dim(mm_go_qm,statusdummy)
            CALL NORHOE(C0,SC0,EIGV,RHOE,PSI,QMMM_XMAT1(1,IPX),
     &                   QMMM_XMAT2,SCR,LSCR,NSTATE)
            call mm_dim(mm_go_mm,statusdummy)
          ELSE
C           Calculate electronic density for orthogonal basis
            call mm_dim(mm_go_qm,statusdummy)
            CALL RHOOFR(C0,RHOE,PSI,SCR,LSCR,NSTATE)
            call mm_dim(mm_go_mm,statusdummy)
          END IF
! physical sign to RHOE
!$OMP parallel do private(i)
#ifdef _vpp_
!OCL NOALIAS
#endif
          DO i=1,NNR1
            RHOE(i)= -RHOE(i)
          ENDDO
        endif
        TIMEEI2=TIMEF()
        time_rho=(TIMEEI2-TIMEEI1)/1000.d0
      endif
      if(update_pot .and. coupl_model.ge.1)then
        TIMEEI1=TIMEF()
        call mm_elstat(TAU,mm_FION,rhoe,SCR,LSCR,
     .       elstat_inten,MAXNAT_el,update_files)
!      MMnode adds the long range contribution to mm_fion
! parent has the short range  contribution

        TIMEEI2=TIMEF()
      else
        TIMEEI1=0.D0
        TIMEEI2=0.D0
      endif

      if(coupl_model.ge.1)then
        if(qmnode) then 
!$OMP parallel do private(i)
#ifdef _vpp_
!OCL NOALIAS
#endif
          do i=1,NNR1
            RHOE(i)= -RHOE(i)
          enddo
        endif
      endif 

      call mm_dim(mm_go_qm,statusdummy)
      if(qmnode) then 
        TIMEF1=TIMEF()
        if(classical)then
          EKIN=0.d0
          ETOT=0.D0
          CALL AZZERO(C2,2*NGW*NSTATE)
          CALL AZZERO(FION,3*NAX*NSX)
        else
          CALL FORCEDR(C0,C2,SC0,RHOE,PSI,TAU,FION,EIGV,SCR,LSCR,
     *             NSTATE,1,LPROJ,.TRUE.)
        endif
        TIMEF2=TIMEF()
      endif  

      call mm_dim(mm_go_mm,statusdummy)
      if(parent.and. .not.classical)then
        CALL DAXPY(3*NAX*NSX,1.0d0,FION(1,1,1),1,mm_FION(1,1,1),1)
! parent has the short range  contribution + the QM forces; if parent.eq.mmnode, has also lr
      endif  

      TIMEG1=0.D0
      TIMEG2=0.D0
      epot_mm=0.D0
      if(update_pot .and. mmnode) then
        TIMEG1=TIMEF()
        call mm_force(NAX,NSX,TAU,mm_FION,epot_mm)
        TIMEG2=TIMEF()
      endif
      call my_bcast(TIMEG1,8,MMSOURCE,QMMMGRP)
      call my_bcast(TIMEG2,8,MMSOURCE,QMMMGRP)

      IF(PARENT.and.update_pot.and.qmmm_verbose) THEN
        WRITE(*,'(A,F20.10)') 'eqmmm_cl',eqmmm_cl
        WRITE(*,'(A,F20.10,/)') 'eqmmm_cl-eexcl',eqmmm_cl-eexcl
      ENDIF

      IF(PARENT.and.qmmm_time) THEN
        WRITE(6,'(A35,F8.4,A2)')
     &      'QM forces needed ',(timef2-timef1)/1000+time_rho,' s'
        WRITE(6,'(A35,F8.4,A2)')
     &            'electrostatic interaction needed ',
     &                     (timeei2-timeei1)/1000,' s'
        WRITE(6,'(A35,F8.4,A2)')
     &       'MM forces needed ',(timeg2-timeg1)/1000,' s'
      ENDIF

! parent .ne. mmnode:    parent has QM, sr in mm_FION; mmnode has lr+MM in mm_FION  
! parent .eq. mmnode:    parent has QM + sr + lr + MM in mm_FION
! we combine mm_fion into fion
      call my_combine(mm_fion,fion,3*NAX*NSX*8,1,QMMMGRP)
      call my_bcast(epot_mm,8,MMSOURCE,QMMMGRP)

      IF(qmnode) THEN
        if(update_pot)then
          eqm=ETOT
          IF(PARENT) THEN
             emm=epot_mm-eqmmm_cl ! qmmm_cl written in mm_elstat at first step
             eqmmm=eqmmm0         ! eqmmm0  written in mm_elstat at first step
          ENDIF
          ETOT=ETOT+epot_mm
          IF(PARENT.and.qmmm_verbose)
     &        WRITE(6,'(A,F15.10)') 'epot_mm',epot_mm
          IF(coupl_model.ge.1) THEN
             ETOT=ETOT+elstat_inten
          ENDIF
          e_fix=elstat_inten+epot_mm-EEXT
          eext0=EEXT
        else
          eqm=ETOT
c         emm is unchanged
          IF(parent) THEN
            eqmmm=eqmmm0+EEXT-eext0
          ENDIF
          ETOT=ETOT+EEXT+e_fix
        endif
      ENDIF

      IF(parent) THEN
        CALL TAUCL(FION)  
        IF(qmmm_verbose) THEN
          write(6,'('' EPOT_MM ='',f20.8)') epot_mm ! cmb
          write(6,'('' ELSTAT_INTEN ='',f20.8)') elstat_inten ! cmb
        ENDIF
      ENDIF

      call freem(IP_mm_fion)
      call mm_dim(mm_revert,status)

#endif
      RETURN
      END
