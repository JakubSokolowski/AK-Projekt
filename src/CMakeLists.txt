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

set(COM_FILES
    coms/message.h
    coms/message.c
    coms/util.h
)

add_library(coms ${COM_FILES})
target_include_directories(coms PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(AK2_PROJEKT main.c)
target_link_libraries(AK2_PROJEKT coms)
target_link_libraries(AK2_PROJEKT crypto)
target_link_libraries(AK2_PROJEKT rt)

add_executable(alice coms/alice.c)
target_include_directories(alice PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/cryptography)
target_link_libraries(alice rt)
target_link_libraries(alice coms)
target_link_libraries(alice crypto)



add_executable(bob coms/bob.c)
target_include_directories(bob PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/cryptography)
target_link_libraries(bob coms)
target_link_libraries(bob crypto)
target_link_libraries(bob rt)


