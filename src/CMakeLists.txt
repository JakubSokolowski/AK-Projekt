set(CRYPTOGRAPHY_FILES
    cryptography/base64.h
    cryptography/base64.s
    cryptography/print.h
    cryptography/print.s
    cryptography/tea.h
    cryptography/tea.s
)

set_source_files_properties(${CRYPTOGRAPHY_FILES} PROPERTIES COMPILE_FLAGS "-x assembler-with-cpp")

add_library(crypto ${CRYPTOGRAPHY_FILES})
add_executable(AK2_PROJEKT main.c)
target_link_libraries(AK2_PROJEKT crypto)
target_link_libraries(AK2_PROJEKT rt)