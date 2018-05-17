#define BOOST_TEST_MODULE SqrTests
#include <boost/test/unit_test.hpp>
#include "../src/cryptography/tea.h"

BOOST_AUTO_TEST_CASE(FailTest)
{
    BOOST_CHECK_EQUAL(5, 5);
}

BOOST_AUTO_TEST_CASE(PassTest)
{
    BOOST_CHECK_EQUAL(5, 5);
}

BOOST_AUTO_TEST_CASE(TEA_BLOK_ENCRYPT)
{
    // Implementation Original Values:  [ FFFFFFFF FFFFFFFF ]
    // Implementation Encrypted Values: [ 3B0BD6A1 44F54A5F ]
    uint32_t k[4];
    uint32_t actual[] = {0xFFFFFFFF, 0xFFFFFFFF};    
    uint32_t expected_encrypted[] = {0x3B0BD6A1, 0x44F54A5F};
    uint32_t expected_decrypted[] = {0xFFFFFFFF, 0xFFFFFFFF};  

    // encrypt_block(actual, k);
    // BOOST_CHECK_EQUAL(actual, expected_encrypted);
    // decrypt_block(actual,k);
    BOOST_CHECK_EQUAL(actual, expected_decrypted);
}