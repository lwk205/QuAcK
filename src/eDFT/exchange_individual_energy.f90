subroutine exchange_individual_energy(rung,DFA,LDA_centered,nEns,wEns,nGrid,weight,nBas, & 
                                      ERI,Pw,P,rhow,drhow,rho,drho,Ex)

! Compute the exchange individual energy

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
  integer,intent(in)            :: nBas
  double precision,intent(in)   :: ERI(nBas,nBas,nBas,nBas)
  double precision,intent(in)   :: Pw(nBas,nBas)
  double precision,intent(in)   :: P(nBas,nBas)
  double precision,intent(in)   :: rhow(nGrid)
  double precision,intent(in)   :: drhow(ncart,nGrid)
  double precision,intent(in)   :: rho(nGrid)
  double precision,intent(in)   :: drho(ncart,nGrid)

! Local variables

  double precision              :: ExLDA
  double precision              :: ExGGA
  double precision              :: ExHF

! Output variables

  double precision,intent(out)  :: Ex

  select case (rung)

!   Hartree calculation

    case(0) 

      Ex = 0d0

!   LDA functionals

    case(1) 

      call lda_exchange_individual_energy(DFA,LDA_centered,nEns,wEns,nGrid,weight,rhow,rho,ExLDA)

      Ex = ExLDA

!   GGA functionals

    case(2) 

      call gga_exchange_individual_energy(DFA,nEns,wEns,nGrid,weight,rhow,drhow,rho,drho,ExGGA)

      Ex = ExGGA

!   Hybrid functionals

    case(4) 

      call print_warning('!!! Individual energies NYI for Hybrids !!!')
      stop

!   Hartree-Fock calculation

    case(666) 

      call fock_exchange_individual_energy(nBas,Pw,P,ERI,ExHF)

      Ex = ExHF

  end select
 
end subroutine exchange_individual_energy
