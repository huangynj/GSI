module stplcbasmod

!$$$ module documentation block
!           .      .    .                                       .
! module:   stplcbasmod    module for stplcbas_search and stplcbas
!  prgmmr:
!
! abstract: module for stplcbas_search and stplcbas
!
! program history log:
!   2012-01-23  zhu
!   2016-05-18  guo     - replaced ob_type with polymorphic obsNode through type casting
!   2019-08-26  kbathmann - split into stplcbas_search and stplcbas
!
! subroutines included:
!   sub stplcbas_search,stplcbas
!
! attributes:
!   language: f90
!   machine:
!
!$$$ end documentation block

use kinds, only: r_kind,i_kind,r_quad
use qcmod, only: nlnqc_iter,varqc_iter
use constants, only: half,one,two,tiny_r_kind,cg_term,zero_quad
use m_obsNode  , only: obsNode
use m_lcbasNode, only: lcbasNode
use m_lcbasNode, only: lcbasNode_typecast
use m_lcbasNode, only: lcbasNode_nextcast
implicit none

PRIVATE
PUBLIC stplcbas_search,stplcbas

contains

subroutine stplcbas_search(lcbashead,rval,out,sges,nstep)
!$$$  subprogram documentation block
!                .      .    .                                       .
! subprogram: stplcbas_search calculate search direction, penalty and contribution to stepsize
!   prgmmr: zhu           org: np23                date: 2012-01-23
!
! abstract: calculate search direction, penalty and contribution to stepsize for surface pressure
!            with addition of nonlinear qc
!
! program history log:
!   2019-08-26 kbathmann- split computation of val into its own subroutine
!
!   input argument list:
!     lcbashead
!     rlcbas     - search direction for lcbas
!     sges     - step size estimate (nstep)
!     nstep    - number of stepsizes  (==0 means use outer iteration values)
!                                         
!   output argument list:         
!     out(1:nstep)   - contribution to penalty for conventional lcbas - sges(1:nstep)
!
! attributes:
!   language: f90
!   machine:  ibm RS/6000 SP
!
!$$$

  use gsi_bundlemod, only: gsi_bundle
  use gsi_bundlemod, only: gsi_bundlegetpointer
  implicit none

! Declare passed variables
  class(obsNode),pointer              ,intent(in   ) :: lcbashead
  integer(i_kind)                     ,intent(in   ) :: nstep
  real(r_quad),dimension(max(1,nstep)),intent(inout) :: out
  type(gsi_bundle)                    ,intent(in   ) :: rval
  real(r_kind),dimension(max(1,nstep)),intent(in   ) :: sges

! Declare local variables  
  integer(i_kind) j1,j2,j3,j4,kk,ier,istatus
  real(r_kind) w1,w2,w3,w4
  real(r_kind) cg_lcbas,lcbas,wgross,wnotgross
  real(r_kind),dimension(max(1,nstep)):: pen
  real(r_kind) pg_lcbas
  real(r_kind),pointer,dimension(:) :: rlcbas
  type(lcbasNode), pointer :: lcbasptr

  out=zero_quad

! If no lcbas data return
  if(.not. associated(lcbashead))return

! Retrieve pointers
! Simply return if any pointer not found
  ier=0
  call gsi_bundlegetpointer(rval,'lcbas',rlcbas,istatus);ier=istatus+ier
  if(ier/=0)return

  lcbasptr => lcbasNode_typecast(lcbashead)
  do while (associated(lcbasptr))
     if(lcbasptr%luse)then
        j1=lcbasptr%ij(1)
        j2=lcbasptr%ij(2)
        j3=lcbasptr%ij(3)
        j4=lcbasptr%ij(4)
        w1=lcbasptr%wij(1)
        w2=lcbasptr%wij(2)
        w3=lcbasptr%wij(3)
        w4=lcbasptr%wij(4)

        lcbasptr%val =w1*rlcbas(j1)+w2*rlcbas(j2)+w3*rlcbas(j3)+w4*rlcbas(j4)

        do kk=1,nstep
           lcbas=lcbasptr%val2+sges(kk)*lcbasptr%val
           pen(kk)= lcbas*lcbas*lcbasptr%err2
        end do
 
!  Modify penalty term if nonlinear QC
        if (nlnqc_iter .and. lcbasptr%pg > tiny_r_kind .and.  &
                             lcbasptr%b  > tiny_r_kind) then
           pg_lcbas=lcbasptr%pg*varqc_iter
           cg_lcbas=cg_term/lcbasptr%b
           wnotgross= one-pg_lcbas
           wgross = pg_lcbas*cg_lcbas/wnotgross
           do kk=1,max(1,nstep)
              pen(kk)= -two*log((exp(-half*pen(kk)) + wgross)/(one+wgross))
           end do
        endif

        out(1) = out(1)+pen(1)*lcbasptr%raterr2
        do kk=2,nstep
           out(kk) = out(kk)+(pen(kk)-pen(1))*lcbasptr%raterr2
        end do
     end if !luse

     lcbasptr => lcbasNode_nextcast(lcbasptr)

  end do !while associated(lcbasptr)
  
  return
end subroutine stplcbas_search

subroutine stplcbas(lcbashead,out,sges,nstep)
!$$$  subprogram documentation block
!                .      .    .                                       .
! subprogram:    stplcbas      calculate penalty and contribution to stepsize
!   prgmmr: zhu           org: np23                date: 2012-01-23
!
! abstract: calculate penalty and contribution to stepsize for surface pressure
!            with addition of nonlinear qc
!
! program history log:
!   2012-01-23  zhu
!
!   input argument list:
!     lcbashead
!     sges     - step size estimate (nstep)
!     nstep    - number of stepsizes  (==0 means use outer iteration values)
!
!   output argument list:
!     out(1:nstep)   - contribution to penalty for conventional lcbas -
!     sges(1:nstep)
!
! attributes:
!   language: f90
!   machine:  ibm RS/6000 SP
!
!$$$

  implicit none
! Declare passed variables
  class(obsNode),pointer              ,intent(in   ) :: lcbashead
  integer(i_kind)                     ,intent(in   ) :: nstep
  real(r_quad),dimension(max(1,nstep)),intent(inout) :: out
  real(r_kind),dimension(max(1,nstep)),intent(in   ) :: sges

! Declare local variables
  integer(i_kind) kk
  real(r_kind),dimension(max(1,nstep)):: pen
  real(r_kind) pg_lcbas
  real(r_kind) cg_lcbas,lcbas,wgross,wnotgross 
  type(lcbasNode), pointer :: lcbasptr

  out=zero_quad

! If no lcbas data return
  if(.not. associated(lcbashead))return

  lcbasptr => lcbasNode_typecast(lcbashead)
  do while (associated(lcbasptr))
     if(lcbasptr%luse)then
        if(nstep > 0)then
           do kk=1,nstep
              lcbas=lcbasptr%val2+sges(kk)*lcbasptr%val
              pen(kk)= lcbas*lcbas*lcbasptr%err2
           end do
        else
           pen(1)=lcbasptr%res*lcbasptr%res*lcbasptr%err2
        end if

!  Modify penalty term if nonlinear QC
        if (nlnqc_iter .and. lcbasptr%pg > tiny_r_kind .and.  &
                             lcbasptr%b  > tiny_r_kind) then
           pg_lcbas=lcbasptr%pg*varqc_iter
           cg_lcbas=cg_term/lcbasptr%b
           wnotgross= one-pg_lcbas
           wgross = pg_lcbas*cg_lcbas/wnotgross
           do kk=1,max(1,nstep)
              pen(kk)= -two*log((exp(-half*pen(kk)) + wgross)/(one+wgross))
           end do
        endif

        out(1) = out(1)+pen(1)*lcbasptr%raterr2
        do kk=2,nstep
           out(kk) = out(kk)+(pen(kk)-pen(1))*lcbasptr%raterr2
        end do
     end if !luse

     lcbasptr => lcbasNode_nextcast(lcbasptr)

  end do !while associated(lcbasptr)

  return
end subroutine stplcbas

end module stplcbasmod
