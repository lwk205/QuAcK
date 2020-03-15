subroutine lda_exchange_potential(DFA,nEns,wEns,nGrid,weight,nBas,AO,rho,Fx)

! Select LDA correlation potential

  implicit none

  include 'parameters.h'

! Input variables

  character(len=12),intent(in)  :: DFA
  integer,intent(in)            :: nEns
  double precision,intent(in)   :: wEns(nEns)
  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  integer,intent(in)            :: nBas
  double precision,intent(in)   :: AO(nBas,nGrid)
  double precision,intent(in)   :: rho(nGrid)

! Output variables

  double precision,intent(out)  :: Fx(nBas,nBas)

! Select exchange functional

  select case (DFA)

!   Restricted version of Slater's LDA correlation functional

    case ('RS51')

      call RS51_lda_exchange_potential(nGrid,weight,nBas,AO,rho,Fx)

!   Slater's LDA correlation functional

    case ('S51')

      call S51_lda_exchange_potential(nGrid,weight,nBas,AO,rho,Fx)

!   Restricted version of the weight-dependent Marut-Fromager-Loos 2020 functional

    case ('RMFL20')

      call RMFL20_lda_exchange_potential(nEns,wEns,nGrid,weight,nBas,AO,rho,Fx)

    case default

      call print_warning('!!! LDA exchange functional not available !!!')
      stop

  end select

end subroutine lda_exchange_potential
