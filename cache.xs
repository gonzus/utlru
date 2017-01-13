#define PERL_NO_GET_CONTEXT      /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "lru.h"

static int cache_dtor(pTHX_ SV *sv, MAGIC *mg) {
    Cache* cache = (Cache*) mg->mg_ptr;
    cache_destroy(cache);
    return 0;
}

static MGVTBL session_magic_vtbl = { .svt_free = cache_dtor };

MODULE = Cache::utLRU        PACKAGE = Cache::utLRU
PROTOTYPES: DISABLE

#################################################################

Cache*
new(char* CLASS, HV* opt = NULL)
CODE:
{
    Cache* cache = cache_build(1000);
    RETVAL = cache;
}
OUTPUT: RETVAL

void
add(Cache* cache, const char* key, const char* val)
CODE:
{
    cache_add(cache, (CacheKey) key, (CacheVal) val);
}

const char*
find(Cache* cache, const char* key)
CODE:
{
    RETVAL = cache_find(cache, (CacheKey) key);
}
OUTPUT: RETVAL
