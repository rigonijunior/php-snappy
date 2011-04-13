dnl config.m4 for extension snappy

dnl Comments in this file start with the string 'dnl'.
dnl Remove where necessary. This file will not work
dnl without editing.

dnl Check PHP version:

AC_MSG_CHECKING([PHP version])
tmp_version=$PHP_VERSION
if test -z "$tmp_version"; then
  if test -z "$PHP_CONFIG"; then
    AC_MSG_ERROR([php-config not found])
  fi
  php_version=`$PHP_CONFIG --version 2> /dev/null | head -n 1 | sed -e 's#\([0-9]\.[0-9]*\.[0-9]*\)\(.*\)#\1#'`
else
  php_version=`echo "$VERSION" | sed -e 's#\([0-9]\.[0-9]*\.[0-9]*\)\(.*\)#\1#'`
fi

if test -z "$php_version"; then
  AC_MSG_ERROR([failed to detect PHP version, please report])
fi

ac_IFS=$IFS
IFS="."
set $php_version
IFS=$ac_IFS
hs_php_version=`expr [$]1 \* 1000000 + [$]2 \* 1000 + [$]3`

if test "$hs_php_version" -le "5000000"; then
  AC_MSG_ERROR([You need at least PHP 5.0.0 to be able to use this version of snappy. PHP $php_version found])
else
  AC_MSG_RESULT([$php_version, ok])
fi

dnl If your extension references something external, use with:

PHP_ARG_WITH(snappy, for snappy support,
Make sure that the comment is aligned:
[  --with-snappy                 Include snappy support])

dnl compiler C++:

dnl PHP_REQUIRE_CXX()

dnl snappy include dir

PHP_ARG_WITH(snappy-includedir, for snappy header,
[  --with-snappy-includedir=DIR  snappy header files], yes)

if test "$PHP_SNAPPY" != "no"; then
  dnl # check with-path

  if test "$PHP_SNAPPY_INCLUDEDIR" != "no" && test "$PHP_SNAPPY_INCLUDEDIR" != "yes"; then
    if test -r "$PHP_SNAPPY_INCLUDEDIR/snappy.h"; then
      SNAPPY_DIR="$PHP_SNAPPY_INCLUDEDIR"
    else
      AC_MSG_ERROR([Can't find snappy headers under "$PHP_SNAPPY_INCLUDEDIR"])
    fi
  else
    SEARCH_PATH="/usr/local /usr"     # you might want to change this
    SEARCH_FOR="/include/snappy-c.h"  # you most likely want to change this
    if test -r $PHP_SNAPPY/$SEARCH_FOR; then # path given as parameter
      SNAPPY_DIR="$PHP_SNAPPY/include"
    else # search default path list
      AC_MSG_CHECKING([for snappy files in default path])
      for i in $SEARCH_PATH ; do
        if test -r $i/$SEARCH_FOR; then
          SNAPPY_DIR="$i/include"
          AC_MSG_RESULT(found in $i)
        fi
      done
    fi
  fi

  if test -z "$SNAPPY_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Can't find snappy headers])
  fi

  dnl # add include path

  PHP_ADD_INCLUDE($SNAPPY_DIR)

  dnl # check for lib

  LIBNAME=snappy
  AC_MSG_CHECKING([for snappy])
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  AC_TRY_COMPILE(
  [
    #include "$SNAPPY_DIR/snappy-c.h"
  ],[
    snappy_max_compressed_length(1);
  ],[
    AC_MSG_RESULT(yes)
    PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $SNAPPY_DIR/lib, SNAPPY_SHARED_LIBADD)
    AC_DEFINE(HAVE_SNAPPYLIB,1,[ ])
  ],[
    AC_MSG_RESULT([error])
    AC_MSG_ERROR([wrong snappy lib version or lib not found : $SNAPPY_DIR])
  ])
  AC_LANG_RESTORE

  PHP_SUBST(SNAPPY_SHARED_LIBADD)

  ifdef([PHP_INSTALL_HEADERS],
  [
    PHP_INSTALL_HEADERS([ext/snappy], [php_snappy.h])
  ], [
    PHP_ADD_MAKEFILE_FRAGMENT
  ])

  PHP_NEW_EXTENSION(snappy, snappy.c, $ext_shared)
fi
