subroutine restricted_correlation_individual_energy(rung,DFA,LDA_centered,nEns,wEns,nGrid,weight,rhow,drhow,rho,drho,Ec)

! Compute the correlation energy of individual states

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: rung
  character(len=12),intent(in)  :: DFA
  logical,intent(in)            :: LDA_centered
  integer,intent(in)            :: nEns
  double precision,intent(in)   :: wEns(nEns)
  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  double precision,intent(in)   :: rhow(nGrid)
  double precision,intent(in)   :: drhow(ncart,nGrid)
  double precision,intent(in)   :: rho(nGrid)
  double precision,intent(in)   :: drho(ncart,nGrid)

! Local variables

  double precision              :: EcLDA
  double precision              :: EcGGA
  double precision              :: aC

! Output variables

  double precision,intent(out)  :: Ec

  select case (rung)

!   Hartree calculation

    case(0) 

      Ec = 0d0

!   LDA functionals

    case(1) 

      call restricted_lda_correlation_individual_energy(DFA,LDA_centered,nEns,wEns(:),nGrid,weight(:),rhow(:),rho(:),Ec)

!   GGA functionals

    case(2) 

      call print_warning('!!! Individual energies NYI for GGAs !!!')
      stop

!   Hybrid functionals

    case(4) 

      call print_warning('!!! Individual energies NYI for hybrids !!!')
      stop

      aC = 0.81d0

!   Hartree-Fock calculation

    case(666) 

      Ec = 0d0

  end select
 
end subroutine restricted_correlation_individual_energy
