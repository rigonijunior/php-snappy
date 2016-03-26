# Summary #
This project has [moved to GitHub](https://github.com/kjdev/php-ext-snappy).

This extension provide API for communicating with [snappy](http://code.google.com/p/snappy/).



# Installation #
```
$ phpize
$ ./configure
$ make
# make install
```

A successful install will have created snappy.so and put it into the PHP extensions directory. You'll need to and adjust php.ini and add an extension=snappy.so line before you can use the extension.

# Function synopsis #
snappy\_compress — Compress a string
```
string snappy_compress ( string $data )
```

snappy\_uncompress —  Uncompress a compressed string
```
string snappy_uncompress ( string $data )
```