subroutine drCCD(maxSCF,thresh,max_diis,nBas,nEl,ERI,ENuc,ERHF,eHF)

! Direct ring CCD module

  implicit none

! Input variables

  integer,intent(in)            :: maxSCF
  integer,intent(in)            :: max_diis
  double precision,intent(in)   :: thresh

  integer,intent(in)            :: nBas,nEl
  double precision,intent(in)   :: ENuc,ERHF
  double precision,intent(in)   :: eHF(nBas)
  double precision,intent(in)   :: ERI(nBas,nBas,nBas,nBas)

! Local variables

  integer                       :: nBas2
  integer                       :: nO
  integer                       :: nV
  integer                       :: nSCF
  double precision              :: Conv
  double precision              :: EcMP2,EcMP3,EcMP4
  double precision              :: ECCD,EcCCD
  double precision,allocatable  :: seHF(:)
  double precision,allocatable  :: sERI(:,:,:,:)

  double precision,allocatable  :: eO(:)
  double precision,allocatable  :: eV(:)
  double precision,allocatable  :: delta_OOVV(:,:,:,:)

  double precision,allocatable  :: OOOO(:,:,:,:)
  double precision,allocatable  :: OOVV(:,:,:,:)
  double precision,allocatable  :: OVVO(:,:,:,:)
  double precision,allocatable  :: VVVV(:,:,:,:)

  double precision,allocatable  :: X1(:,:,:,:)
  double precision,allocatable  :: X2(:,:)
  double precision,allocatable  :: X3(:,:)
  double precision,allocatable  :: X4(:,:,:,:)

  double precision,allocatable  :: u(:,:,:,:)
  double precision,allocatable  :: v(:,:,:,:)

  double precision,allocatable  :: r2(:,:,:,:)
  double precision,allocatable  :: t2(:,:,:,:)

! Hello world

  write(*,*)
  write(*,*)'**************************************'
  write(*,*)'|     direct ring CCD calculation    |'
  write(*,*)'**************************************'
  write(*,*)

! Spatial to spin orbitals

  nBas2 = 2*nBas

  allocate(seHF(nBas2),sERI(nBas2,nBas2,nBas2,nBas2))

  call spatial_to_spin_MO_energy(nBas,eHF,nBas2,seHF)
  call spatial_to_spin_ERI(nBas,ERI,nBas2,sERI)

! Antysymmetrize ERIs

! Define occupied and virtual spaces

  nO = 2*nEl
  nV = nBas2 - nO

! Form energy denominator

  allocate(eO(nO),eV(nV))
  allocate(delta_OOVV(nO,nO,nV,nV))

  eO(:) = seHF(1:nO)
  eV(:) = seHF(nO+1:nBas2)

  call form_delta_OOVV(nO,nV,eO,eV,delta_OOVV)

  deallocate(seHF)

! Create integral batches

  allocate(OOOO(nO,nO,nO,nO),OOVV(nO,nO,nV,nV),OVVO(nO,nV,nV,nO),VVVV(nV,nV,nV,nV))

  OOOO(:,:,:,:) = sERI(   1:nO   ,   1:nO   ,   1:nO   ,   1:nO   )
  OOVV(:,:,:,:) = sERI(   1:nO   ,   1:nO   ,nO+1:nBas2,nO+1:nBas2)
  OVVO(:,:,:,:) = sERI(   1:nO   ,nO+1:nBas2,nO+1:nBas2,   1:nO   )
  VVVV(:,:,:,:) = sERI(nO+1:nBas2,nO+1:nBas2,nO+1:nBas2,nO+1:nBas2)
 
  deallocate(sERI)

! MP2 guess amplitudes

  allocate(t2(nO,nO,nV,nV))

  t2(:,:,:,:) = -OOVV(:,:,:,:)/delta_OOVV(:,:,:,:)

  EcMP2 = 0.25d0*dot_product(pack(OOVV,.true.),pack(t2,.true.))
  EcMP4 = 0d0

! Initialization

  allocate(r2(nO,nO,nV,nV),u(nO,nO,nV,nV),v(nO,nO,nV,nV))
  allocate(X1(nO,nO,nO,nO),X2(nV,nV),X3(nO,nO),X4(nO,nO,nV,nV))

  Conv = 1d0
  nSCF = 0

!------------------------------------------------------------------------
! Main SCF loop
!------------------------------------------------------------------------
  write(*,*)
  write(*,*)'----------------------------------------------------'
  write(*,*)'| direct ring CCD calculation                      |'
  write(*,*)'----------------------------------------------------'
  write(*,'(1X,A1,1X,A3,1X,A1,1X,A16,1X,A1,1X,A10,1X,A1,1X,A10,1X,A1,1X)') &
            '|','#','|','E(CCD)','|','Ec(CCD)','|','Conv','|'
  write(*,*)'----------------------------------------------------'

  do while(Conv > thresh .and. nSCF < maxSCF)

!   Increment 

    nSCF = nSCF + 1

!   Compute residual

    call form_ring_r(nO,nV,OVVO,OOVV,t2,r2)

    r2(:,:,:,:) = OOVV(:,:,:,:) + delta_OOVV(:,:,:,:)*t2(:,:,:,:) + r2(:,:,:,:) 

!   Check convergence 

    Conv = maxval(abs(r2(:,:,:,:)))
  
!   Update amplitudes

    t2(:,:,:,:) = t2(:,:,:,:) - r2(:,:,:,:)/delta_OOVV(:,:,:,:)

!   Compute correlation energy

    EcCCD = 0.5d0*dot_product(pack(OOVV,.true.),pack(t2,.true.))

    if(nSCF == 1) EcMP3 = 0.25d0*dot_product(pack(OOVV,.true.),pack(t2 + v/delta_OOVV,.true.))

!   Dump results

    ECCD = ERHF + EcCCD

    write(*,'(1X,A1,1X,I3,1X,A1,1X,F16.10,1X,A1,1X,F10.6,1X,A1,1X,F10.6,1X,A1,1X)') &
      '|',nSCF,'|',ECCD+ENuc,'|',EcCCD,'|',Conv,'|'

  enddo
  write(*,*)'----------------------------------------------------'
!------------------------------------------------------------------------
! End of SCF loop
!------------------------------------------------------------------------

! Did it actually converge?

  if(nSCF == maxSCF) then

    write(*,*)
    write(*,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    write(*,*)'                 Convergence failed                 '
    write(*,*)'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    write(*,*)

    stop

  endif

  write(*,*)
  write(*,*)'----------------------------------------------------'
  write(*,*)'              direct ring CCD energy                '
  write(*,*)'----------------------------------------------------'
  write(*,'(1X,A30,1X,F15.10)')' E(drCCD) = ',ECCD  
  write(*,'(1X,A30,1X,F15.10)')' Ec(drCCD) = ',EcCCD 
  write(*,*)'----------------------------------------------------'
  write(*,*)

end subroutine drCCD
