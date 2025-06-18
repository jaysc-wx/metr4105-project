! Title: METR 4105: Meteorological Computer Applications final project
! Author: Jay Campbell
! Last Updated: May 6, 2025 (and hopefully never again after)
! #################################
! In short, this has been a harrowing experience. A fun one, as I probably used every trick in the book that I both know,
! and every trick that I felt comfortable incorporating, to create some really clean and efficient code. 
! It will still be about 800 lines or so but that's the nature of the beast when working with scientific computing. 
! ##################################
! Special thanks to Roger and Dr. Davenport for the class and the support y'all have provided on our homework assignments
! as well as listening to all of my somewhat silly, incessant questions. It's helped me out a lot, so thank you for that.
! Special thanks to the fortls language server and the Modern Fortran extension on Visual Studio Code 
! that made this project 1000000 times easier to complete – no really.
! I don't know how I would've finished this without it catching my compile errors while still in the editor.
! Or without it showing me the types of my variables on hover, or the arguments for my functions while I typed them,
! and the autocomplete was pretty cool. 
! Special thanks Matthew, Kali, Foxx, everyone in class, who were invaluable in listening to my tangents and frustrations and lending support along the way.
! ##################################
! This program reads in five sounding files, as well as five NWS climatological summaries, and processes them into arrays for further calculations.
! It reads in all sounding data and the date, liquid precipitation, and maximum wind gust from the climatological summary and
! calculates the following:
!       Sounding
!           Bulk shear from 0-500m, 0-1000m, and 0-6000m.
!           Precipitable water for the entire column.
!           K-Index
!           Total Totals Index
!           SWEAT Index
!       Climatological Summary
!           Mean daily rainfall
!           Mean daily maximum wind gust
!       Statistical indices
!           Mean (average)
!           Standard deviation of a sample


program final_project

implicit none

! #################################
! ###### Declaration Section ######
! #################################

! Sounding data
character(len=15) :: date(5)           ! Date and time of the sounding
real, allocatable :: p(:)              ! Pressure (hPa)
integer, allocatable :: z(:)           ! Height (m)
real, allocatable :: t(:)              ! Temperature (K)
real, allocatable :: t_d(:)            ! Dew point (K)
integer, allocatable :: r(:)           ! Relative humidity (%)
real, allocatable :: w(:)              ! Mixing ratio (g/kg)
integer, allocatable :: wn_spd(:)      ! Wind speed (kts)
integer, allocatable :: wn_dir(:)      ! Wind direction (degrees)

! Monthly climatological summary data
character(len=9) :: months(5)           ! Month of the climatological summary
character(len=4) :: years(5)            ! Year of the climatological summary
integer, allocatable :: day(:)          ! Number of days in month
real, allocatable :: rain(:)            ! Total rainfall (in)
real, allocatable :: gust(:)            ! Wind gusts (mph)
integer :: ndays

! Counters, other stuff
integer :: nlines                       ! Number of lines in the sounding
integer :: i                            ! Counter

! Precipitable water variables
real :: pwat(5)                        ! Precipitable water (mm)

! Bulk shear
real :: shr_500(5), shr_1000(5), shr_6000(5)     ! Holds the bulk shear for the 0-500m, 0-1000m, and 0-6000m layers

! Severe weather indices
real :: ki(5)                           ! K Index
real :: tt(5)                           ! Total Totals Index
real :: sweat(5)                        ! SWEAT Index


! Standard deviations
! Climatological summary data
real :: stdev_rain(5)                   ! Daily rainfall
real :: stdev_gust(5)                   ! Daily maximum wind gust

! Sounding data
real :: stdev_ki                        ! K-Index
real :: stdev_tt                        ! Total Totals Index
real :: stdev_sweat                     ! SWEAT Index
real :: stdev_pwat                      ! Precipitable water
real :: stdev_500shr                    ! 0-500m shear
real :: stdev_1000shr                   ! 0-1000m shear
real :: stdev_6000shr                   ! 0-6000m shear

! Averages
! Climatological summary data
real :: average_rain(5)                 ! Daily rainfall
real :: average_gust(5)                 ! Mean daily maximum wind gust

! Sounding data
real :: average_ki                      ! K-Index
real :: average_tt                      ! Total Totals Index
real :: average_sweat                   ! SWEAT Index
real :: average_pwat                    ! Precipitable water
real :: average_500shr                  ! 0-500m shear
real :: average_1000shr                 ! 0-1000m shear
real :: average_6000shr                 ! 0-6000m shear

! I/O
! Defines variables that store the input soundings and input climatological reports.
character(len=256) :: input_sounding(5)
character(len=256) :: input_cf6(5)

! Defines the 5 soundings that are used in the analysis.
input_sounding(1) = '06 Aug 2024 12Z.txt'
input_sounding(2) = '30 Aug 2023 00Z.txt'
input_sounding(3) = '30 Sep 2022 12Z.txt'
input_sounding(4) = '15 Sep 2018 00Z.txt'
input_sounding(5) = '08 Oct 2016 00Z.txt'

! Defines the 5 climatological reports that are used in the analysis.
input_cf6(1) = 'CF6 Aug 2024.txt'
input_cf6(2) = 'CF6 Aug 2023.txt'
input_cf6(3) = 'CF6 Sep 2022.txt'
input_cf6(4) = 'CF6 Sep 2018.txt'
input_cf6(5) = 'CF6 Oct 2016.txt'

! ###############################
! ###### Execution Section ######
! ###############################

do i = 1, 5

    ! Loads the sounding for calculation
    call load_sounding(date(i), p, z, t, t_d, r, w, wn_dir, wn_spd, nlines, input_sounding(i))

    ! Loads the climatological summary for calculation
    call climate_summary(months(i), years(i), day, rain, gust, ndays, input_cf6(i))

    ! Calculates precipitable water
    pwat(i) = precipitable_water(p, w, nlines)

    ! Calculates the shear in the 0-500m, 0-1000m, and 0-6000m layers.
    call bulk_shear(z, wn_spd, wn_dir, shr_500(i), shr_1000(i), shr_6000(i), nlines)

    ! Calculates the K Index, Total Totals, and SWEAT Index
    ki(i) = k_index(p, t, t_d, nlines)
    tt(i) = total_totals(p, t, t_d, nlines)
    sweat(i) = sweat_index(p, t_d, tt(i), wn_dir, wn_spd, nlines)

    ! Calculates the standard deviation and average rainfall and maximum wind gusts over the month.
    stdev_rain(i) = standard_deviation(ndays, rain)
    average_rain(i) = average(ndays, rain)
    stdev_gust(i) = standard_deviation(ndays, gust)
    average_gust(i) = average(ndays, gust)

    deallocate(p, z, t, t_d, r, w, wn_dir, wn_spd)
    deallocate(day, rain, gust)

end do

! Calculates standard deviation for all other sounding metrics
stdev_ki = standard_deviation(5, ki)
stdev_tt = standard_deviation(5, tt)
stdev_sweat = standard_deviation(5, sweat)
stdev_pwat = standard_deviation(5, pwat)
stdev_500shr = standard_deviation(5, shr_500)
stdev_1000shr = standard_deviation(5, shr_1000)
stdev_6000shr = standard_deviation(5, shr_6000)

! Calculates average for all other sounding metrics 
average_ki = average(5, ki)
average_tt = average(5, tt)
average_sweat = average(5, sweat)
average_pwat = average(5, pwat)
average_500shr = average(5, shr_500)
average_1000shr = average(5, shr_1000)
average_6000shr = average(5, shr_6000)

! ###########################
! ###### Output Format ######
! ###########################

! This block handles printing the output of the calculations to a textfile called analysis.txt (in the executable directory). 

! Opens the file for writing
open(unit=20, file='analysis.txt', status='unknown', action='write')

! Lays out the skeletin of the text file with formatted write statements.
50 format("")
60 format("--------------------------------------------------------------------------------")
100 format("Charleston, SC Tropical Cyclone Analysis")
110 format("===================================BULK SHEAR===================================")
120 format("Date and Time", 8x, "0-500m Shear", 6x, "0-1000m Shear", 6x, "0-6000m Shear")
121 format(A15, 7x, f4.1, " kts", 11x, f4.1, " kts", 11x, f4.1, " kts")
122 format("Average: ", 13x, f4.1, " kts", 11x, f4.1, " kts", 11x, f4.1, " kts")
123 format("Standard Deviation: ", 2x, f4.1, " kts", 11x, f4.1, " kts", 11x, f4.1, " kts")
200 format("================================FLOODING INDICES================================")
210 format("Date and Time", 8x, "Precipitable Water", 20x)
211 format(A15, 9x, f5.2, " mm")
212 format("Average: ", 15x, f5.2, " mm")
213 format("Standard Deviation: ", 4x, f5.2, " mm")
300 format("==============================SEVERE WEATHER INDICES============================")
310 format("Date and Time", 8x, "K Index", 5x, "Total Totals", 5x, "SWEAT Index")
311 format(A15, 7x, f5.2, 10x, f5.2, 10x, f6.1)
312 format("Average:", 14x, f5.2, 10x, f5.2, 10x, f6.1)
313 format("Standard Deviation: ", 2x, f5.2, 10x, f5.2, 10x, f6.1)
400 format("============================CLIMATOLOGICAL SUMMARY==============================")
410 format("Month and Year", 8x, "Mean Rainfall", 2x, "Standard Deviation", 2x, "Mean Max Wind Gust", 2x, "Standard Deviation")
411 format(A9, 1x, A4, 12x, f4.2, " in", 9x, f4.2, " in", 13x, f4.1, " mph", 12x, f5.2, " mph")

! This handles all of the writing of the code. There are loops where appropriate to print the sounding and climatological data
! out from the arrays to make it a bit easier to read. Formatted writes are just going to be a little messy though.
write(20,100)
write(20,50)
write(20,110)
write(20,120)
do i=1, 5
    write(20,121) date(i), shr_500(i), shr_1000(i), shr_6000(i)
end do
write(20,60)
write(20,122) average_500shr, average_1000shr, average_6000shr
write(20,123) stdev_500shr, stdev_1000shr, stdev_6000shr
write(20,50)
write(20,200)
write(20,210) 
do i=1, 5
    write(20,211) date(i), pwat(i)
end do
write(20,60)
write(20,212) average_pwat
write(20,213) stdev_pwat
write(20,50)
write(20,300)
write(20,310) 
do i=1, 5
    write(20,311) date(i), ki(i), tt(i), sweat(i)
end do
write(20,60)
write(20,312) average_ki, average_tt, average_sweat
write(20,313) stdev_ki, stdev_tt, stdev_sweat
write(20,50)
write(20,400)
write(20,410)
do i=1, 5
    write(20,411) months(i), years(i), average_rain(i), stdev_rain(i), average_gust(i), stdev_gust(i)
end do

close(20)

! ===== Subroutines =====

contains

    subroutine load_sounding(sounding_dt, pres, hgt, temp, dwpt, rh, mixr, drkt, stkt, n, input)

        ! This handles reading the sounding file in and allocating and loading the arrays corresponding to
        ! the sounding's information. In general, it first opens the file and then counts the number of lines
        ! in the sounding, after the six header lines. Afterwards, it rewinds to the beginning and reads in the
        ! date and time of the sounding, and then uses a formatted read to read in the entire sounding.
        ! I also designed it like this so I could give it a text file and not have to think about individual cases, it should be *mostly* working.
        ! Or at least work with what I gave it. Some cases I had to ignore and select a different time because 
        ! I simply did not have the time to actually account for it (such as when MSLP is less than 1000.0 hPa).

        implicit none

        character(len=*) :: sounding_dt                 ! Date and time of the sounding
        real, allocatable, intent(out) :: pres(:)       ! Pressure (hPa)
        integer, allocatable, intent(out) :: hgt(:)     ! Height (m)
        real, allocatable, intent(out) :: temp(:)       ! Temperature (deg C)
        real, allocatable, intent(out) :: dwpt(:)       ! Dew point (deg C)
        integer, allocatable, intent(out) :: rh(:)      ! Relative humidity (%)
        real, allocatable, intent(out) :: mixr(:)       ! Mixing ratio (g/kg)
        integer, allocatable, intent(out) :: drkt(:)    ! Wind direction (degrees)
        integer, allocatable, intent(out) :: stkt(:)    ! Wind speed (kts)
        character(len=*) :: input                       ! Input txt file
        integer :: k                                    ! Counting variable
        integer, intent(out) :: n                       ! Number of lines
        integer :: ios                                  ! Error checking


        ! Opens the input file
        open(unit=10, file=input, status='unknown', action='read')

        ! Skips the first 5 header lines
        do k=1,5
            read(10,*) 
        end do

        n = 0

        ! Starts from line 6, and then reads through to count how many valid data lines there are. Stores it in n
        do
            read(10,*,iostat=ios)
            if(ios .ne. 0) exit         ! iostat = 0 when valid data is found, otherwise it exits
            n = n + 1                   ! Counts per line
        end do

        ! Rewinds to the start of the file
        rewind(10)

        ! Reads in the date/time line
        20 format(37x, A15)
        read(10, 20) sounding_dt

        ! Skips the 4 lines for the header
        do k=2, 5
            read(10,*)
        end do

        ! Allocates the arrays based on the line count counted above
        allocate(pres(n), hgt(n), temp(n), dwpt(n), rh(n), mixr(n), drkt(n), stkt(n))

        ! Formatted read
        25 format(1x, f6.1, 2x, i5, 2x, f5.1, 2x, f5.1, 4x, i3, 2x, f5.2, 4x, i3, 5x, i2)

        ! Reads in the file and stores the values to the arrays. Very basic error handling here.
        do k=1, n
            read(10,25,iostat=ios) pres(k), hgt(k), temp(k), dwpt(k), rh(k), mixr(k), drkt(k), stkt(k)
            if(ios .ne. 0) then
                write(*,*) "Failed to read line ", k, " from file"
                exit
            end if
        end do
        
        ! Closes the file
        close(10)

    end subroutine load_sounding

    subroutine climate_summary(month, year, days, rainfall, wind_gust, n, input)

        ! This subroutine handles loading in the monthly preliminary climatological summary each NWS WFO produces.
        ! In general, it will skip the 18 line header and then count the number of valid date rows, checking for valid dats
        ! that fits a 2 digit wide integer. Text generally is not an integer, so it will exit the loop and store the number of days
        ! it counted in a variable. Next, it then skips the hesder to lines 7 and 8, where it reads the month and year from the file
        ! and will store that into a variable sent into the main program. Lastly, it skips down to the actual data, reading in
        ! the date, daily precipitation, and daily maximum wind gust.

        implicit none

        character(len=9), intent(out) :: month                      ! Month of the climate summary
        character(len=4), intent(out) :: year                       ! Year of the climate summary
        integer, allocatable, intent(out) :: days(:)                ! Day of the month
        real, allocatable, intent(out) :: rainfall(:)               ! Rainfall (in)
        real, allocatable, intent(out) :: wind_gust(:)              ! Maximum daily wind gust (mph)
        character(len=*) :: input                                   ! Input file
        integer, intent(out) :: n                                   ! Number of days in the month
        integer :: k                                                ! Counter
        integer :: check                                            ! Used in checking for valid data
        integer :: ios                                              ! Error handling

        ! Opens the input file 
        open(unit=30, file=input, status='unknown', action='read')

        ! Skips the first 18 header lines
        do k=1,18
            read(30, *)
        end do

        n = 0

        ! Sets formatting to check for valid data
        30 format(i2)

        ! Starts from line 19 and then counts the number of valid data values
        do
            read(30,30,iostat=ios) check    ! Reads the value into the check var
            if(ios .ne. 0) exit             ! Breaks if iostat isn't 0, indicating bad data
            n = n + 1                       ! Counts per line
        end do

        ! Rewinds to the start of the file
        rewind(30)

        ! Skips the header again
        do k=1, 6
            read(30,*)
        end do

        ! Reads in the month and year
        31 format(53x, A9)
        32 format(53x, A4)

        read(30,31) month
        read(30,32) year

        ! Skips the next 10 lines
        do k=1, 10
            read(30,*)
        end do
        
        ! Allocates the arrays based on the number of lines counted above
        allocate(days(n), rainfall(n), wind_gust(n))
        
        ! Formatted read
        35 format(i2, 25x, f4.2, 43x, f2.0)

        ! Reads in the file and stores the values in the arrays. Very basic error handling for garbage data.
        do k=1, n
            read(30,35,iostat=ios) days(k), rainfall(k), wind_gust(k)
            if(ios .ne. 0) then
                write(*,*) "Failed to read line ", k, " from file"
                exit
            end if
        end do

        close(30)

    end subroutine climate_summary

    subroutine bulk_shear(hght, wspd, wdir, shr500, shr1000, shr6000, n)

        ! This subroutine will calculate the bulk shear for three layers, 0-500m, 0-1000m, and 0-3000m. 

        implicit none

        integer, intent(in) :: hght(:)                  ! Height (m)
        integer, intent(in) :: wspd(:)                  ! Wind speed (kts)
        integer, intent(in) :: wdir(:)                  ! Wind direction (degrees)
        real, intent(out) :: shr500, shr1000, shr6000   ! Shear maginitude (kts)
        integer, intent(in) :: n                        ! Number of vertical sounding points
        integer :: hght500, hght1000, hght6000          ! Stores point where each height is reached
        real :: windu(n), windv(n)                      ! u and v components of win (kts)
        real :: udiff, vdiff                            ! Difference in u and v component between bottom and top of layer
        integer :: k                                    ! Counter

        ! Searches for the first instance where the height is above 500m and stores the point in hght500
        do k=1, n
            if(hght(k) .gt. 500.0) then
                hght500 = k
                exit
            end if
        end do

        ! Searches for the first instance where the height is above 1000m and stores the point in hght1000
        do k=1, n
            if(hght(k) .gt. 1000.0) then
                hght1000 = k
                exit
            end if
        end do

        ! Searches for the first instance where the height is above 6000m and stores the point in hght6000
        do k=1, n
            if(hght(k) .gt. 6000.0) then
                hght6000 = k
                exit
            end if
        end do

        ! Calls a subroutine that will convert the wind speed and direction into u and v components
        do k=1, n
            call wind_components(wdir(k), wspd(k), windu(k), windv(k))
        end do

        ! Calculates the 0-500m wind shear magnitude.
        udiff = windu(hght500) - windu(1)               ! Difference in u between sfc and 500m.
        vdiff = windv(hght500) - windv(1)               ! Difference in v between sfc and 500m.
        shr500 = sqrt((udiff**2) + (vdiff**2))          ! Takes magnitude of the u and v vectors combined.

        ! Calculates the 0-1000m wind shear magnitude. See above.
        udiff = windu(hght1000) - windu(1)
        vdiff = windv(hght1000) - windv(1)
        shr1000 = sqrt((udiff**2) + (vdiff**2))

        ! Calculates the 0-6000m wind shear magnitude. See above.
        udiff = windu(hght6000) - windu(1)
        vdiff = windv(hght6000) - windv(1)
        shr6000 = sqrt((udiff**2) + (vdiff**2))
   
    end subroutine bulk_shear
    
    subroutine wind_components(wdir, wspd, wind_u, wind_v)
        ! This subroutine breaks the wind direction and wind speed for a given point into its u and v components.
    
        implicit none

        integer, intent(in) :: wdir         ! Wind direction (degrees)
        integer, intent(in) :: wspd         ! Wind speed (kts)
        real, intent(out) :: wind_u         ! u component of speed (kts)
        real, intent(out) :: wind_v         ! v component of speed (kts)
        real :: pi                          ! Constant pi
        real :: wdir_rad                    ! Wind direction (radians)

        pi = 4 * ATAN(1.0)                  ! Uses arctan definition of pi

        wdir_rad = wdir * ( pi / 180.0 )    ! Converts the wind direction from degrees to radians

        ! Uses trigonometry to breaks the wind speed and direction into u and v components.
        wind_u = (-1.0 * wspd) * sin (wdir_rad)
        wind_v = (-1.0 * wspd) * cos (wdir_rad)
    
    end subroutine wind_components

! ===== Functions =====

    real function precipitable_water(pres,mixr,n)

        ! This function calculates precipitable water through the sounding by numerically integrating the total mixing ratio across the entire sounding.
        ! It employs the trapezoidal rule, a very accurate and simple way to numerically integrate over unequal intervals.
        ! References        https://en.wikipedia.org/wiki/Trapezoidal_rule
        !                   https://glossary.ametsoc.org/wiki/Precipitable_water


        implicit none

        real, intent(in) :: pres(:)         ! Atmospheric pressure (hPa)
        real, intent(in) :: mixr(:)         ! Mixing ratio (g/kg)
        integer :: n, k                     ! n = number of lines in the file, k is for counting
        real :: w_sum                       ! Sum of the mixing ratio across two points
        real :: dp                          ! Change in pressure across the same two points
        real :: trap_sum                    ! Sum of the integration for the mixing ratio provided by the trapezoidal rule
        real :: g                           ! Gravity (m/s^2)

        g = 9.81                            ! Gravitational constant
        trap_sum = 0.0                      ! Initalize at 0.

        ! This is the main loop that employs the trapezoidal rule, it loops through the full column in the sounding and interatively
        ! sums the mixing ratios up across the entire column.
        do k = 1, n-1                       
            w_sum = (mixr(k + 1) + mixr(k)) / 1000.0                ! Sums mixing ratio (and converts to units of kg/kg) across two points 
            dp = (abs(pres(k + 1)-pres(k))) * 100.0                 ! Takes the change in pressure between the two points
            trap_sum = trap_sum + ((0.5) * (w_sum * dp))            ! Uses dp as dx from the trapezoidal rule and w_sum as (f(x_1) + f(x)) / 2
        end do

        precipitable_water = trap_sum / g                           ! Divides by gravity to get the precipitable water, in units of mm
        
        return

    end function precipitable_water

    real function k_index(pres, temp, dwpt, n)

        ! Implements the K-Index, which is defined as such: K = (T_850 - T_500) + Td_850 - (T_700 - Td_700).
        ! Where T is temperature, Td is dew point, and the number is a given pressure layer. 
        ! Source:           https://en.wikipedia.org/wiki/K-index_(meteorology)


        implicit none

        real, intent(in) :: pres(:)                 ! Pressure (hPa_)
        real, intent(in) :: temp(:)                 ! Temperature (deg C)
        real, intent(in) :: dwpt(:)                 ! Dew point (deg C)
        integer :: k                                ! Counter
        integer :: n                                ! Number of vertical points
        integer :: idx_850, idx_700, idx_500        ! Variables storing index at 850, 700, and 500 hPa.

        ! Searches for where the pressure is equal to 850 hPa and sets the value of k to the index, and then breaks the loop.
        do k = 1, n
            if(pres(k) .eq. 850.0) then
                idx_850 = k
                exit
            end if
        end do

        ! Searches for where the pressure is equal to 700 hPa and sets the value of k to the index, and then breaks the loop.
        do k = 1, n
            if(pres(k) .eq. 700.0) then
                idx_700 = k
                exit
            end if
        end do

        ! Searches for where the pressure is equal to 500 hPa and sets the value of k to the index, and then breaks the loop.
        do k = 1, n
            if(pres(k) .eq. 500.0) then
                idx_500 = k
                exit
            end if
        end do

        ! Calculates the K-Index using the above formula.
        k_index = (temp(idx_850) - temp(idx_500)) + (dwpt(idx_850)) - (temp(idx_700) - temp(idx_700))

        return
    end function k_index

    real function total_totals(pres, temp, dwpt, n)

        ! Implements the Total Totals Index, which is given by the formula: TT = T_850 + Td_850 - (2 * T_500)
        ! Where T is temperature, Td is dew point, and the number is a given pressure layer. 
        ! Source:           https://www.weather.gov/lmk/indices

        implicit none

        real, intent(in) :: pres(:)             ! Pressure (hPa)
        real, intent(in) :: temp(:)             ! Teperature (deg C)
        real, intent(in) :: dwpt(:)             ! Dew point (deg C)
        integer :: k                            ! Counter
        integer :: n                            ! Number of vertical points
        integer :: idx_850, idx_500             ! Variables storing index at 850 hPa and 500 hPa.

        ! Loops through to find the point in the sounding where the pressure is equal to 850 hPa and stores the index, and breaks the loop.
        do k=1, n
            if(pres(k) .eq. 850.0) then
                idx_850 = k
                exit
            end if
        end do

        ! Loops through to find the point in the sounding where the pressure is equal to 500 hPa and stores the index, and breaks the loop.
        do k=1, n
            if(pres(k) .eq. 500.0) then
                idx_500 = k
                exit
            end if
        end do

        ! Calculates the Total Totals with the formula at the top of the function.
        total_totals = (temp(idx_850) + dwpt(idx_850)) - (2 * temp(idx_500))

        return
    end function total_totals

    real function sweat_index(pres, dwpt, tti, wdir, wspd, n)

        ! This function calculates the Severe Weather Threat Index, also known as the SWEAT Index using the following formula:
        ! SWEAT = (12 * Td_850) + (20 * (TT - 49)) + (2 * vv_850) + (vv_500) + (125 * (sin(dd_500 - dd_850) - 0.2))
        ! Where: Td = dew point, TT = total totals, vv = wind speed, dd = wind direction, and numbers represent pressure points.
        ! Source:       Dr. Eastin's notes

        implicit none

        real :: pres(:)             ! Pressure (hPa)
        real :: dwpt(:)             ! Dew point (deg C)
        real :: tti                 ! Total Totals
        integer :: wdir(:)          ! Wind direction (degrees)
        integer :: wspd(:)          ! Wind speed (kts)
        integer :: k                ! Counter
        integer :: n                ! Number of vertical points
        integer :: idx_850, idx_500 ! Variables to store index at 850 and 500 hPa
        logical :: cond1, cond2, cond3, cond4               ! Stores the conditions that must be met
        real :: term1, term2, term3, term4, term5           ! Terms to make calculations easier to carry out

        ! Searches for where the pressure equals 850 hPa and sets an index to it.
        do k=1, n
            if(pres(k) .eq. 850.0) then
                idx_850 = k
                exit
            end if
        end do

        ! Searches for where the pressure equals 500 hPa and sets an index to it.
        do k=1, n
            if(pres(k) .eq. 500.0) then
                idx_500 = k
                exit
            end if
        end do

        ! No term in the SWEAT Index can be negative, this sets those terms to zero if applicable.

        ! The dew point must be at or above 0 degrees C, otherwise, it sets term1 to the dew point at 850 hPa.
        if(dwpt(idx_850) .eq. 0.0) then
            term1 = 0.0
        else
            term1 = dwpt(idx_850)
        end if

        ! The Total Totals must be at or above 0, otherwise, it sets term2 to the Total Totals - 49.
        if(tti .lt. 49.0) then
            term2 = 0.0
        else
            term2 = tti - 49
        end if

        ! This can never (hopefully!) be negative. So terms 3 and 4 are set to the wind speed at 850 and 500 hPa.
        term3 = wspd(idx_850)
        term4 = wspd(idx_500)

        ! The final term requires all four conditions to be met. If not, the entire term is zeroed out.
        cond1 = (wdir(idx_850) .gt. 130.0 .and. wdir(idx_850) .lt. 250.0)           ! Direction at 850 hPa must be between 130 and 210 degrees.
        cond2 = (wdir(idx_500) .gt. 210.0 .and. wdir(idx_500) .lt. 310.0)           ! Direction at 500 hPa must be between 210 and 310 degrees.
        cond3 = ((wdir(idx_500) - wdir(idx_850)) .gt. 0 )                           ! Winds must be veering with height.
        cond4 = (wspd(idx_850) .gt. 15 .and. wspd(idx_500) .gt. 15)                 ! There has to be significant (>15 kt) winds.

        ! If ANY condition above is not met, the last term is set to zero. Otherwise, it computes the last term.
        if(.not. (cond1 .and. cond2 .and. cond3 .and. cond4)) then
            term5 = 0.0
        else
            term5 = 125 * ( sind(real(wdir(idx_500)) - real(wdir(idx_850))) + 0.2 )
        end if

        ! Calculates the sweat index using the constants to calculate the rest. 
        sweat_index = (12 * term1) + (20 * term2) + (2 * term3) + (term4) + (term5)

        return
    end function sweat_index

    real function standard_deviation(n, values)

        ! This function calculates the standard deviation of a sample with a given set of values and the total number of values.

        implicit none

        integer, intent(in) :: n            ! Total number of values provided.
        integer :: k                        ! Counter
        real, intent(in) :: values(:)       ! Set of values provided for calclulation.
        real :: mean                        ! Mean of the set of values.
        real :: deviation                   ! Deviation for a single point relative to the mean.

        mean = average(n, values)           ! Uses the average function below to calculate the mean of the dataset.

        deviation = 0.0                     ! Initalizes the deviation to zero.

        ! Loops through the data and calculates the deviations for each data point and sums it up.
        do k=1, n
            deviation = ((values(k) - mean) ** 2) + deviation
        end do

        ! Calculates the standard deviation by taking the square root of the deviation divided by the number of sample points minus one
        standard_deviation = sqrt(deviation / (n - 1) )

        return
    end function standard_deviation

    real function average(n, values)

        ! Calculates the average of a set of values with a given n

        implicit none

        integer :: k, n                 ! Counter and the number of values
        real :: values(:)               ! Array of values
        real :: sum                     ! Running sum of the values

        sum = 0.0                       ! Initalize the sum to 0.0

        ! Loops through to tally up the total sum of the values provided.
        do k=1, n
            sum = sum + values(k)
        end do

        ! Divides the sum calculated above by the number of values provided.
        average = sum / real(n)

        return
    end function average

end program final_project
