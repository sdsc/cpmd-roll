C     ==================================================================
      SUBROUTINE EKINPP(EKINP,VELP)
C     ==--------------------------------------------------------------==
      IMPLICIT NONE
      INCLUDE 'system.h' 
      INCLUDE 'ions.inc' 
      INCLUDE 'rmas.inc' 
C     Arguments
      REAL*8  EKINP,VELP(3,NAX,*)
C     Variables
      REAL*8  CONST
      INTEGER I,K,J
C     ==--------------------------------------------------------------==
C     ==  CALCULATE KINETIC ENERGY OF THE IONS                        ==
C     ==--------------------------------------------------------------==
      EKINP=0.D0
      DO K=1,NSP
        CONST=0.5D0*PMA(K)
        DO J=1,NA(K)
          EKINP=EKINP+CONST*(VELP(1,J,K)**2+
     .                       VELP(2,J,K)**2+
     .                       VELP(3,J,K)**2) 
        ENDDO
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
      SUBROUTINE S_EKINPP(EKINP,VELP,IP)
      IMPLICIT NONE
      INCLUDE 'system.h'
      INCLUDE 'ions.inc'
      INCLUDE 'rmas.inc'
      INCLUDE 'pimd.inc'
C     Arguments
      REAL*8  EKINP,VELP(3,NAX,*)
      INTEGER IP
C     Variables
      REAL*8  CONST
      INTEGER I,IS,IA
C     ==--------------------------------------------------------------==
C     ==  CALCULATE KINETIC ENERGY OF THE IONS                        ==
C     ==--------------------------------------------------------------==
      EKINP=0.D0
      DO IS=1,NSP
        CONST=0.5D0*PMA0S(IS,IP)
        DO IA=1,NA(IS)
          EKINP=EKINP+CONST*(VELP(1,IA,IS)**2+
     .                       VELP(2,IA,IS)**2+
     .                       VELP(3,IA,IS)**2) 
        ENDDO
      ENDDO
C     ==--------------------------------------------------------------==
      RETURN
      END
C     ==================================================================
