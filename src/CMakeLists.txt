set(CRYPTOGRAPHY_FILES
    cryptography/base64.h
    cryptography/base64.s
    cryptography/print.h
    cryptography/print.s
    cryptography/tea.h
    cryptography/tea.s
    cryptography/dhexchange.h
    cryptography/dhexchange.s
)

set_source_files_properties(${CRYPTOGRAPHY_FILES} PROPERTIES COMPILE_FLAGS "-x assembler-with-cpp")

add_library(crypto ${CRYPTOGRAPHY_FILES})
target_include_directories(crypto PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
add_executable(AK2_PROJEKT main.c)
target_link_libraries(AK2_PROJEKT crypto)
target_link_libraries(AK2_PROJEKT rt)
