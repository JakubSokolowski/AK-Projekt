
find_package (Boost COMPONENTS system filesystem unit_test_framework REQUIRED)
include_directories (
    ${AK2_SOURCE_DIR}/src
    ${AK2_SOURCE_DIR}/src/cryptography
    ${Boost_INCLUDE_DIRS}
)
add_executable (Test test.cpp)
set_target_properties(Test PROPERTIES LINKER_LANGUAGE ASM)
target_link_libraries (
    Test
    crypto
    ${Boost_FILESYSTEM_LIBRARY}
    ${Boost_SYSTEM_LIBRARY}
    ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}
    
)
ADD_DEFINITIONS(-DBOOST_TEST_DYN_LINK) 