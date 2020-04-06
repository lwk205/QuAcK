subroutine RGIC_lda_exchange_derivative_discontinuity(nEns,wEns,nGrid,weight,rhow,ExDD)

! Compute the restricted version of the GIC exchange individual energy

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nEns
  double precision,intent(in)   :: wEns(nEns)
  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  double precision,intent(in)   :: rhow(nGrid)

! Local variables

  integer                       :: iEns,jEns
  integer                       :: iG
  double precision              :: r
  double precision              :: dExdw(nEns)
  double precision,external     :: Kronecker_delta

  double precision              :: a,b,c,w
  double precision              :: dCxGICdw

! Output variables

  double precision,intent(out)  :: ExDD(nEns)

! Compute correlation energy for ground- and doubly-excited states

  a = + 0.5751782560799208d0
  b = - 0.021108186591137282d0
  c = - 0.36718902716347124d0

  w = wEns(2)
  dCxGICdw = (0.5d0*b + (2d0*a + 0.5d0*c)*(w - 0.5d0) - (1d0 - w)*w*(3d0*b + 4d0*c*(w - 0.5d0)))
  dCxGICdw = CxLDA*dCxGICdw

  dExdw(:) = 0d0

  do iG=1,nGrid
    
    r = max(0d0,rhow(iG))
    
    if(r > threshold) then
 
      dExdw(1) = 0d0
      dExdw(2) = dExdw(2) + weight(iG)*dCxGICdw*r**(4d0/3d0)

    end if
     
  end do 

  do iEns=1,nEns
    do jEns=2,nEns

      ExDD(iEns) = ExDD(iEns) + (Kronecker_delta(iEns,jEns) - wEns(jEns))*dExdw(jEns)

    end do
  end do

end subroutine RGIC_lda_exchange_derivative_discontinuity