function (setCRAY)
  message("Setting paths for Cray")
  set(HDF5_USE_STATIC_LIBRARIES "ON" CACHE INTERNAL "HDF5_Static" )
# set( OMPFLAG "-openmp" PARENT_SCOPE )
  if( NOT DEFINED ENV{COREPATH} )
    set(COREPATH "/gpfs/hps/nco/ops/nwprod/lib" PARENT_SCOPE )
  else()
    set(COREPATH $ENV{COREPATH} PARENT_SCOPE )
  endif()
  if( NOT DEFINED ENV{CRTM_INC} )
    set(CRTM_BASE "/gpfs/hps/nco/ops/nwprod/lib/crtm" PARENT_SCOPE )
  endif()
  if( NOT DEFINED ENV{WRFPATH} )
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
      set(WRFPATH "/gpfs/hps/nco/ops/nwprod/wrf_shared.v1.1.0-intel" PARENT_SCOPE )
    else()
      set(WRFPATH "/gpfs/hps/nco/ops/nwprod/wrf_shared.v1.1.0-cray" PARENT_SCOPE )
    endif()
  else()
    set(WRFPATH $ENV{WRFPATH} PARENT_SCOPE )
  endif()
  if( NOT DEFINED ENV{NETCDF_VER} )
    set(NETCDF_VER "3.6.3" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{BACIO_VER} )
    set(BACIO_VER "2.0.1" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{BUFR_VER} )
    set(BUFR_VER "11.0.1" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{CRTM_VER} )
    set(CRTM_VER "2.2.3" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{NEMSIO_VER} )
    set(NEMSIO_VER "2.2.2" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{SFCIO_VER} )
    set(SFCIO_VER "1.0.0" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{SIGIO_VER} )
    set(SIGIO_VER "2.0.1" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{SP_VER} )
    set(SP_VER "2.0.2" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{W3EMC_VER} )
    set(W3EMC_VER "2.2.0" PARENT_SCOPE)
  endif()
  if( NOT DEFINED ENV{W3NCO_VER} )
    set(W3NCO_VER "2.0.6" PARENT_SCOPE)
  endif()
endfunction()
