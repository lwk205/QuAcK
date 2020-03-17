subroutine RS51_lda_exchange_energy(nGrid,weight,rho,Ex)

! Compute restriced version of Slater's LDA exchange energy

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  double precision,intent(in)   :: rho(nGrid)

! Local variables

  integer                       :: iG
  double precision              :: r
  double precision              :: Cx

! Output variables

  double precision              :: Ex

! Cx coefficient for Slater LDA exchange

  Cx = -(3d0/4d0)*(3d0/pi)**(1d0/3d0)

! Compute LDA exchange energy

  Ex = 0d0
  do iG=1,nGrid

    r = max(0d0,rho(iG))

    if(r > threshold) then

      Ex = Ex + weight(iG)*Cx*r**(4d0/3d0)

    endif

  enddo

end subroutine RS51_lda_exchange_energy
