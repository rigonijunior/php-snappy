
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "ext/standard/info.h"
#include "php_snappy.h"

/* snappy */
#include "snappy-c.h"

static PHP_FUNCTION(snappy_compress);
static PHP_FUNCTION(snappy_uncompress);

ZEND_BEGIN_ARG_INFO_EX(arginfo_snappy_compress, 0, 0, 1)
    ZEND_ARG_INFO(0, data)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_snappy_uncompress, 0, 0, 1)
    ZEND_ARG_INFO(0, data)
ZEND_END_ARG_INFO()

static const zend_function_entry snappy_functions[] = {
    PHP_FE(snappy_compress, arginfo_snappy_compress)
    PHP_FE(snappy_uncompress, arginfo_snappy_uncompress)
    {NULL, NULL, NULL}
};

PHP_MINFO_FUNCTION(snappy)
{
    php_info_print_table_start();
    php_info_print_table_row(2, "Snappy support", "enabled");
    php_info_print_table_row(2, "Extension Version", SNAPPY_EXTENSION_VERSION);
    php_info_print_table_end();
}

zend_module_entry snappy_module_entry = {
#if ZEND_MODULE_API_NO >= 20010901
    STANDARD_MODULE_HEADER,
#endif
    "snappy",
    snappy_functions,
    NULL,
    NULL,
    NULL,
    NULL,
    PHP_MINFO(snappy),
#if ZEND_MODULE_API_NO >= 20010901
    SNAPPY_EXTENSION_VERSION,
#endif
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_SNAPPY
ZEND_GET_MODULE(snappy)
#endif

static PHP_FUNCTION(snappy_compress)
{
    int data_len;
    size_t output_len;
    char *data, *output;

    if (zend_parse_parameters(
            ZEND_NUM_ARGS() TSRMLS_CC, "s", &data, &data_len) == FAILURE)
    {
        return;
    }

    output_len = snappy_max_compressed_length(data_len);
    output = (char *)emalloc(output_len);
    if (!output)
    {
        zend_error(E_WARNING, "snappy_compress : memory error");
        RETURN_FALSE;
    }

    if (snappy_compress(data, data_len, output, &output_len) == SNAPPY_OK)
    {
        RETVAL_STRINGL(output, output_len, 1);
    }
    else
    {
        RETVAL_FALSE;
    }

    efree(output);
}

static PHP_FUNCTION(snappy_uncompress)
{
    int data_len;
    size_t output_len;
    char *data, *output = NULL;

    if (zend_parse_parameters(
            ZEND_NUM_ARGS() TSRMLS_CC, "s", &data, &data_len) == FAILURE)
    {
        return;
    }

    if (snappy_uncompressed_length(
            data, (size_t)data_len, &output_len) != SNAPPY_OK)
    {
        zend_error(E_WARNING, "snappy_uncompress : output length error");
        RETURN_FALSE;
    }

    output = (char *)emalloc(output_len);
    if (!output)
    {
        zend_error(E_WARNING, "snappy_uncompress : memory error");
        RETURN_FALSE;
    }

    if (snappy_uncompress(data, data_len, output, &output_len) == SNAPPY_OK)
    {
        RETVAL_STRINGL(output, output_len, 1);
    }
    else
    {
        zend_error(E_WARNING, "snappy_uncompress : data error");
        RETVAL_FALSE;
    }

    efree(output);
}
