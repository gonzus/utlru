#define PERL_NO_GET_CONTEXT      /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "lru.h"

#define CACHE_DEFAULT_SIZE 1000

static int cache_dtor(pTHX_ SV *sv, MAGIC *mg) {
    Cache* cache = (Cache*) mg->mg_ptr;
    cache_destroy(cache);
    return 0;
}

static void cache_visit(Cache* cache, CacheEntry* entry, void* arg)
{
    /* TODO: find out if we really need to call all these magic macros */
    dTHX;
    dSP;
    if (!arg) {
        return;
    }
    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    PUSHs(entry->key);
    PUSHs(entry->val);
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
        size = CACHE_DEFAULT_SIZE;
    }
    RETVAL = cache_build(size);
}
OUTPUT: RETVAL

void
add(Cache* cache, SV* key, SV* val)
CODE:
{
    if (!key || !SvOK(key) || !SvPOK(key)) {
        croak("add key argument must be a string");
    }
    if (!val || !SvOK(val) || !SvPOK(val)) {
        croak("add value argument must be a string");
    }
    cache_add(aTHX_ cache, key, val);
}

SV*
find(Cache* cache, SV* key)
CODE:
{
    if (!key || !SvOK(key) || !SvPOK(key)) {
        croak("find key argument must be a string");
    }
    RETVAL = cache_find(aTHX_ cache, key);
}
OUTPUT: RETVAL

void
visit(Cache* cache, SV* cb)
CODE:
{
    if (!cb || !SvOK(cb) || !SvROK(cb) || SvTYPE(SvRV(cb)) != SVt_PVCV) {
        croak("visit cb argument must be a coderef");
    }
    cache_iterate(aTHX_ cache, cache_visit, cb);
}
