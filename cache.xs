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

static void cache_visit(Cache* cache, CacheEntry* entry, void* arg)
{
    dTHX;
    dSP;
    if (!arg) {
        return;
    }
    ENTER;
    SAVETMPS;

    const char* key = (const char*) entry->key;
    int klen = key ? strlen(key) : 0;
    const char* val = (const char*) entry->val;
    int vlen = val ? strlen(val) : 0;

    PUSHMARK(SP);
    mXPUSHp(key, klen);
    mXPUSHp(val, vlen);
    PUTBACK;

    SV* cb = (SV*) arg;
    call_sv(cb, G_SCALAR | G_EVAL);

    SPAGAIN;

    PUTBACK;
    FREETMPS;
    LEAVE;
}

static MGVTBL session_magic_vtbl = { .svt_free = cache_dtor };

MODULE = Cache::utLRU        PACKAGE = Cache::utLRU
PROTOTYPES: DISABLE

#################################################################

Cache*
new(char* CLASS, int size = 0)
CODE:
{
    if (size <= 0) {
        size = 1000;
    }
    Cache* cache = cache_build(size);
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

void
visit(Cache* cache, SV* cb)
CODE:
{
    cache_iterate(cache, cache_visit, cb);
}
