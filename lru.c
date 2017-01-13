#include <stdio.h>
#include <string.h>
#include "lru.h"

Cache* cache_build(int size)
{
    Cache* cache = (Cache*) malloc(sizeof(Cache));
    cache->size = size;
    cache->data = 0;
    /* fprintf(stderr, "LOG building cache for %d elements\n", cache->size); */
    return cache;
}

void cache_destroy(Cache* cache)
{
    /* fprintf(stderr, "LOG destroying cache for %d elements\n", cache->size); */
    free(cache);
}

const CacheVal cache_find(Cache* cache, const CacheKey key)
{
    CacheEntry* entry;
    HASH_FIND_STR(cache->data, key, entry);
    if (!entry) {
        /* fprintf(stderr, "LOG could not find key [%s] in cache\n", key); */
        return NULL;
    }

    /*
     * remove it (so the subsequent add
     * will throw it on the front of the list)
     */
    /* fprintf(stderr, "LOG found key [%s] in cache\n", key); */
    HASH_DELETE(hh, cache->data, entry);
    HASH_ADD_KEYPTR(hh, cache->data, entry->key, strlen(entry->key), entry);
    return entry->val;
}

void cache_add(Cache* cache, const CacheKey key, const CacheVal val)
{
    CacheEntry* entry = (CacheEntry*) malloc(sizeof(CacheEntry));
    entry->key = strdup(key);
    entry->val = strdup(val);
    HASH_ADD_KEYPTR(hh, cache->data, entry->key, strlen(entry->key), entry);
    /* fprintf(stderr, "LOG added key [%s] => [%s]\n", key, val); */

    /*
     * prune the cache to not exceed its size
     */
    int size = HASH_COUNT(cache->data);
    for (int j = cache->size; j < size; ++j) {
        CacheEntry* tmp;
        HASH_ITER(hh, cache->data, entry, tmp) {
            /*
             * prune the first entry
             * (loop is based on insertion order
             * so this deletes the oldest item)
             */
            /* fprintf(stderr, "LOG removing key [%s]\n", entry->key); */
            HASH_DELETE(hh, cache->data, entry);
            free((void*) entry->key);
            free((void*) entry->val);
            free(entry);
            break;
        }
    }
}
