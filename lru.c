#include <stdio.h>
#include "gmem.h"
#include "lru.h"

Cache* cache_build(int size)
{
    Cache* cache;
    GMEM_NEW(cache, Cache*, sizeof(Cache));
    cache->size = size;
    cache->data = 0;
    /* fprintf(stderr, "LOG building cache for %d elements\n", cache->size); */
    return cache;
}

void cache_destroy(Cache* cache)
{
    /* fprintf(stderr, "LOG destroying cache for %d elements\n", cache->size); */
    GMEM_DEL(cache, Cache*, sizeof(Cache));
}

SV* cache_find(pTHX_ Cache* cache, SV* key)
{
    STRLEN klen = 0;
    char* kptr = 0;
    kptr = SvPV(key, klen);

    CacheEntry* entry;
    HASH_FIND(hh, cache->data, kptr, klen, entry);
    if (!entry) {
        /* fprintf(stderr, "LOG could not find key [%s] in cache\n", key); */
        return NULL;
    }

    /*
     * remove it; the subsequent add will throw it on the front of the list
     */
    /* fprintf(stderr, "LOG found key [%s] in cache\n", key); */
    HASH_DELETE(hh, cache->data, entry);
    HASH_ADD_KEYPTR(hh, cache->data, kptr, klen, entry);
    return entry->val;
}

void cache_add(pTHX_ Cache* cache, SV* key, SV* val)
{
    /* do not use gmem for these elements,
     * they will be deleted internally by ut */
    STRLEN klen = 0;
    char* kptr = 0;
    kptr = SvPV(key, klen);

    CacheEntry* entry = (CacheEntry*) malloc(sizeof(CacheEntry));
    entry->key = key;
    entry->val = val;

    /* increment perl refcounts */
    SvREFCNT_inc(key);
    SvREFCNT_inc(val);

    HASH_ADD_KEYPTR(hh, cache->data, kptr, klen, entry);
    /* fprintf(stderr, "LOG added key [%s] => [%s]\n", key, val); */

    /*
     * prune the cache to not exceed its size
     */
    int size = HASH_COUNT(cache->data);
    for (int j = cache->size; j < size; ++j) {
        CacheEntry* tmp;
        HASH_ITER(hh, cache->data, entry, tmp) {
            /*
             * prune the first entry; loop is based on insertion
             * order so this deletes the oldest item
             */
            /* fprintf(stderr, "LOG removing key [%s]\n", entry->key); */

            /* decrement perl refcounts */
            SvREFCNT_dec(entry->key);
            SvREFCNT_dec(entry->val);

            HASH_DELETE(hh, cache->data, entry);
            free(entry);
            break;
        }
    }
}

void cache_iterate(pTHX_ Cache* cache, CacheVisitor visitor, void* arg)
{
    CacheEntry* entry = 0;
    CacheEntry* tmp = 0;
    HASH_ITER(hh, cache->data, entry, tmp) {
        visitor(cache, entry, arg);
    }
}
