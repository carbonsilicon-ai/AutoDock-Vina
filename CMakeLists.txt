cmake_minimum_required(VERSION "3.0.0" FATAL_ERROR)
project(cuvina)

find_program(CCACHE "ccache")
if (CCACHE)
    message(STATUS "ccache found at ${CCACHE}")
    set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE})
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE})
    set(CMAKE_CUDA_COMPILER_LAUNCHER ${CCACHE})
endif()

################################################################################
# Options
# USE double instead of float in vina calculation
option(OPT_USE_DOUBLE "using double instead of float in calc" ON)
# DEBUG option, BFGS will use CPU instead of GPU even GPU device is enabled
option(DBG_BFGS_USE_CPU "BFGS using CPU instead of GPU" OFF)
################################################################################


################################################################################
# Flags
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -w -std=c++14 -DUSE_CUDA -DDLIB_NO_GUI_SUPPORT -arch=sm_75 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_86,code=sm_86)
#set(CUDA_NVCC_FLAGS ${NVCC_FLAGS_RELEASE} ${CUDA_NVCC_FLAGS} -arch=sm_75 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 
#    -gencode arch=compute_61,code=sm_61 -gencode arch=compute_75,code=compute_75 -gencode arch=compute_72,code=sm_72 -gencode arch=compute_86,code=sm_86; 
#    --use_fast_math)
if(CMAKE_BUILD_TYPE AND (CMAKE_BUILD_TYPE STREQUAL "Debug"))
    set(NVCC_FLAGS_DEBUG -DNDEBUG -O0 -g -G)
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} ${NVCC_FLAGS_DEBUG})
else()
    set(NVCC_FLAGS_RELEASE -DNDEBUG -O3 --use_fast_math)
    set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} ${NVCC_FLAGS_RELEASE})
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -std=c++14 -DUSE_CUDA -DDLIB_NO_GUI_SUPPORT")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -fno-strict-aliasing -Wno-deprecated-declarations -Wno-unused-local-typedefs -Wno-parentheses -Wno-catch-value")
set(CMAKE_CXX_FLAGS_DEBUG   " ${CMAKE_CXX_FLAGS} -DDEBUG -g -O0")
set(CMAKE_CXX_FLAGS_RELEASE " ${CMAKE_CXX_FLAGS} -DNDEBUG -O3")
################################################################################


################################################################################
# libcuvina static Library compiling
find_package(CUDA ${CUDA_VERSION} REQUIRED)
list(APPEND INCLUDE_PATHS ${CUDA_INCLUDE_DIRS})
list(APPEND LINK_LIBS 
    ${CUDA_LIBRARIES}
    #${CUDA_CUFFT_LIBRARIES}
    # ${CUDA_CUBLAS_LIBRARIES}
    #${CUDA_cupti_LIBRARY}
    #${CUDA_curand_LIBRARY}
    #${CUDA_cusparse_LIBRARY}
    #${CUDA_npp_LIBRARY}
    #${CUDA_nppc_LIBRARY}
    #${CUDA_nppi_LIBRARY}
    #${CUDA_npps_LIBRARY}
    #${CUDA_nvcuvenc_LIBRARY}
    # ${CUDA_nvcuvid_LIBRARY}
)

set(SRC ${PROJECT_SOURCE_DIR}/src)
set(VINA_DIR ${SRC}/lib)
set(CUVINA_DIR ${SRC}/cuvina)
list(APPEND VINA_SRC
    ${CUVINA_DIR}/cuvina.cpp
    ${CUVINA_DIR}/bfgs.cu
    # ${CUVINA_DIR}/vinasrv.cpp
    ${VINA_DIR}/ad4cache.cpp
    ${VINA_DIR}/cache.cpp
    ${VINA_DIR}/conf_independent.cpp
    ${VINA_DIR}/coords.cpp
    ${VINA_DIR}/grid.cpp
    ${VINA_DIR}/model.cpp
    ${VINA_DIR}/monte_carlo.cpp
    ${VINA_DIR}/mutate.cpp
    ${VINA_DIR}/non_cache.cpp
    ${VINA_DIR}/parallel_mc.cpp
    ${VINA_DIR}/parallel_progress.cpp
    ${VINA_DIR}/parse_pdbqt.cpp
    ${VINA_DIR}/quasi_newton.cpp
    ${VINA_DIR}/quaternion.cpp
    ${VINA_DIR}/random.cpp
    ${VINA_DIR}/szv_grid.cpp
    ${VINA_DIR}/utils.cpp
    ${VINA_DIR}/vina.cpp
    ${VINA_DIR}/log.cpp
)
list(APPEND SRC_FILES 
        ${VINA_SRC}
)
list(APPEND LINK_LIBS
    boost_system
    boost_thread
    boost_serialization
    boost_filesystem
    boost_program_options
)

list(APPEND INCLUDE_PATHS ${SRC})
include_directories(${INCLUDE_PATHS})
cuda_add_library(${PROJECT_NAME} STATIC ${SRC_FILES})
target_link_libraries(${PROJECT_NAME} ${LINK_LIBS} -lpthread)   
# cuda_add_cublas_to_target (${PROJECT_NAME})

if (OPT_USE_DOUBLE)
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_DOUBLE=1)
else()
    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_DOUBLE=0)
endif()
if (DBG_BFGS_USE_CPU)
    target_compile_definitions(${PROJECT_NAME} PRIVATE BFGS_CPU=1)
else()
    target_compile_definitions(${PROJECT_NAME} PRIVATE BFGS_CPU=0)
endif()
target_compile_definitions(${PROJECT_NAME} PRIVATE USE_CUDA_VINA=1)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
################################################################################


################################################################################
# vina executable
cuda_add_executable(vina ${SRC}/main/main.cpp)
TARGET_LINK_LIBRARIES(vina pthread ${PROJECT_NAME} ${LNK_LIBS} )
install(TARGETS ${ONE_TEST_TARGET} RUNTIME DESTINATION bin/)
################################################################################


