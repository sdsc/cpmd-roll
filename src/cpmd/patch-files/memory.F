C     ==================================================================
      SUBROUTINE MEMORY(IP_POINT,LENGTH,TAG)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'memc.inc'
      INCLUDE 'irat.inc'
C     Arguments
      REAL*8    POINTDUMMY
      POINTER   (IP_POINT,POINTDUMMY)
      INTEGER   LENGTH
      CHARACTER TAG*(*)
C     Variables
#if defined(POINTER8)
      INTEGER*8 I_AD1,I_AD2
      INTEGER*8 MALLOC
#elif defined(__NEC)
      INTEGER   I_AD1,I_AD2
      INTEGER   MALLOCW
#else
      INTEGER   I_AD1,I_AD2
      INTEGER   MALLOC
#endif
      REAL*8    XM(0:*)
      POINTER   (IP_XM,XM)
#ifdef CRAY
      INTEGER   IERR1,IERR2
#endif
#ifdef MALLOC8
C     The argument of malloc is INTEGER*8.
      INTEGER*8 LEN
#else
C     The argument of malloc is INTEGER.
      INTEGER   LEN
#endif
      CHARACTER LINE*100
      INTEGER   I,IERROR,IA,IE,
     &          I_FIRST
      DATA      I_FIRST /0/
      SAVE      I_FIRST
C     ==--------------------------------------------------------------==
C     ==  ALLOCATION OF LENGTH * REAL*8 WORDS OF MEMORY               ==
C     ==--------------------------------------------------------------==
      IF(I_FIRST.EQ.0) THEN
        I_BLOCK=0
        I_FIRST=1
        LB_MIN=0
        IB_MIN=1
        DO I=1,MBM
          I_LENB(I)=0
        ENDDO
        NUMPEAK=0
        RMEMPEAK=0.D0
        RMEMTOT=0.D0
        MEMCHK=TMEMCHK
      ENDIF
      IERROR=0
      LEN=LENGTH+4
      IF(LEN.LT.0) THEN
        WRITE(*,*) ' MEMORY| MEMORY REQUIRED:',LEN,' WORDS'
        CALL STOPGM('MEMORY','NEGATIVE OR TOO BIG VALUE')
      ENDIF
#if defined(CRAYX1)
      LEN = 8 * LEN
      IP_XM=MALLOC(LEN)
      IF(IP_XM.LE.0) IERROR=1
#elif CRAY
C     Integer=integer*8
      CALL HPALLOC(IP_XM,LEN,IERR1,0)
      IF(IERR1.NE.0) THEN
        CALL HPSHRINK
        CALL HPALLOC(IP_XM,LEN,IERR2,0)
        IF(IERR2.NE.0) THEN
          IERROR=1
        ENDIF
      ENDIF
#elif defined(__NEC)
C     Integer=integer*8
      LEN=MAX(LEN,400)
      IP_XM=MALLOCW(LEN)
      IF(IP_XM.EQ.0) THEN
C       Allocation error
        IERROR=1
      ENDIF
#else
#if !defined(MALLOC8)
C     Check if 8 * LEN is in the range of integer.
      IF(IRAT.EQ.2) THEN
C       Integer=integer*4 : 2^31=-2147483647 (signed int!), 2^28=268435456
        IF(LEN.GE.(2**28-1)) THEN
          WRITE(*,*) ' MEMORY| MEMORY REQUIRED:',LEN,' WORDS'
          CALL STOPGM('MEMORY','TOO BIG VALUE')
        ENDIF
      ENDIF
#endif
      LEN = 8 * LEN
      LEN=MAX(LEN,400)
#if defined(__IBM) || defined(__SR2201) || defined(__OSX) || defined(__H1)
      IP_XM=MALLOC(%VAL(LEN))
#else
      IP_XM=MALLOC(LEN)
#endif
C detect malloc failure. comparing a pointer with a possibly signed integer
C may be a problem. on some machines the 'heap' grows down so successful
C allocations may result in a 'negative' value.
C we are being careful here. on the following machines a failed malloc _is_
C indicated by a NULL pointer, for the rest we fail on negative as well.
C AK 2005/04/16.
#if defined(__HP) || defined(__Linux) || defined(__alpha) || defined(__OSX) || defined(__OSX_IFC) || defined(__WINNT) || defined(_BGP)
      IF(IP_XM.EQ.0) THEN
        IERROR=1
      ENDIF
#else
      IF(IP_XM.LE.0) THEN
        IERROR=1
      ENDIF
#endif
#endif
      IF(IERROR.NE.0) THEN
        WRITE(*,'(/,1X,64("*"))')
        WRITE(*,'(1X,A9,I6,A14,I12,A23)') 'PROCESSOR',ME,
     *             ' ALLOCATION OF',LENGTH,' WORDS OF MEMORY FAILED'
        WRITE(*,'(1X,64("*"),/)')
        CALL PRMEM('    MEMORY')
        CALL PMAXMEM
        CALL XSTRING(TAG,IA,IE)
        WRITE(LINE,'(A,A,A)') 'ALLOCATION FAILED (',TAG(IA:IE),')'
        IE=IE+19+1
        CALL STOPGM('MEMORY',LINE(1:IE))
      ENDIF
      CALL GET_ADDR(IP_POINT,XM(2))
C..Statistics and memory checks
      XM(0)=ZFIRST
      XM(LENGTH+3)=ZLAST
      I_BLOCK=I_BLOCK+1
      IF(I_BLOCK.GT.MEM_LEN) THEN
        I_BLOCK=MEM_LEN
      ENDIF
      IF(NUMPEAK.LT.I_BLOCK) THEN
        NUMPEAK=I_BLOCK
      ENDIF
      CALL GET_ADDR(I_AD1(I_BLOCK),XM(0))
      CALL GET_ADDR(I_AD2(I_BLOCK),XM(LENGTH+3))
      I_LEN(I_BLOCK)=LENGTH
      I_TAG(I_BLOCK)=TAG
      RMEMTOT=RMEMTOT+DBLE(LENGTH)
      IF(RMEMPEAK.LT.RMEMTOT) THEN
        RMEMPEAK=RMEMTOT
      ENDIF
      IF(LENGTH.GT.LB_MIN) THEN
        I_LENB(IB_MIN)=LENGTH
        IB_TAG(IB_MIN)=TAG
        LB_MIN=LENGTH
        DO I=MBM,1,-1
          IF(LB_MIN.GE.I_LENB(I)) THEN
            LB_MIN=I_LENB(I)
            IB_MIN=I
          ENDIF
        ENDDO
      ENDIF
C     Debugging
      IF(MEMDEB) THEN
        WRITE(*,'(A,I4,A,A10,A,I10,A,I16)')
     &       ' DEBUGMEM! ALLOCAT[',I_BLOCK,']: ',I_TAG(I_BLOCK),
     &       ' LEN=',LENGTH,
     &       ' ADDR=',I_AD1(I_BLOCK)
      ENDIF
      IF(MEMCHK) THEN
        CALL MEMORY_CHECK
      ENDIF
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
