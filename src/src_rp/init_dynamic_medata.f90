!***************************************************************************
! init_dynamic_medata.f90
! -----------------------
! Copyright (C) 2007-2011, Eco2s team, Gerardo Fratini
! Copyright (C) 2011-2019, LI-COR Biosciences, Inc.  All Rights Reserved.
! Author: Gerardo Fratini
!
! This file is part of EddyPro®.
!
! NON-COMMERCIAL RESEARCH PURPOSES ONLY - EDDYPRO® is licensed for 
! non-commercial academic and government research purposes only, 
! as provided in the EDDYPRO® End User License Agreement. 
! EDDYPRO® may only be used as provided in the End User License Agreement
! and may not be used or accessed for any commercial purposes.
! You may view a copy of the End User License Agreement in the file
! EULA_NON_COMMERCIAL.rtf.
!
! Commercial companies that are LI-COR flux system customers 
! are encouraged to contact LI-COR directly for our commercial 
! EDDYPRO® End User License Agreement.
!
! EDDYPRO® contains Open Source Components (as defined in the 
! End User License Agreement). The licenses and/or notices for the 
! Open Source Components can be found in the file LIBRARIES-ENGINE.txt.
!
! EddyPro® is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!
!*******************************************************************************
!
! \brief       Read dynamic metadata file and figure out available parameters
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
!*******************************************************************************
subroutine InitDynamicMetadata(N)
    use m_rp_global_var
    implicit none
    !> In/out variables
    integer, intent(out) :: N
    !> Local variables
    integer :: open_status
    integer :: io_status


    write(*, '(a)', advance = 'no') ' Initializing dynamic metadata usage..'

    !> Open file
    open(udf, file = AuxFile%DynMD, status = 'old', iostat = open_status)

    !> Interpret dynamic metadata file header and control in case of error
    if (open_status == 0) then
        call ReadDynamicMetadataHeader(udf)
    else
        call ExceptionHandler(68)
        EddyProProj%use_dynmd_file = .false.
    end if

    !> Count number of rows in the file (all of them, no matter if well formed),
    !> to give a maximum number to calibration data arrays
    N = 0
    countloop: do
        read(udf, *, iostat = io_status)
        if (io_status < 0 .or. io_status == 5001 .or. io_status == 5008) exit
        N = N + 1
    end do countloop
    close(udf)

    write(*, '(a)') ' Done.'
end subroutine InitDynamicMetadata

!***************************************************************************
!
! \brief       Reads and interprets file header, searching for knwon variables
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
!***************************************************************************
subroutine ReadDynamicMetadataHeader(unt)
    use m_rp_global_var
    implicit none
    !> in/out variables
    integer, intent(in) :: unt
    !> local variables
    character(LongInstringLen) :: dataline
    character(64) :: Headerlabels(NumStdDynMDVars)
    integer :: read_status
    integer :: sepa
    integer :: cnt
    integer :: i
    integer :: j


    read(unt, '(a)', iostat = read_status) dataline
    cnt = 0
    do
        sepa = index(dataline, ',')
        if (sepa == 0) sepa = len_trim(dataline) + 1
        if (len_trim(dataline) == 0) exit
        cnt = cnt + 1
        Headerlabels(cnt) = dataline(1:sepa - 1)
        dataline = dataline(sepa + 1: len_trim(dataline))
    end do

    DynamicMetadataOrder = nint(error)
    do i = 1, cnt
        do j = 1, NumStdDynMDVars
        if(trim(adjustl(StdDynMDVars(j))) &
            == trim(adjustl(Headerlabels(i)))) then
            DynamicMetadataOrder(j) = i
            exit
        end if
        end do
    end do
end subroutine ReadDynamicMetadataHeader
