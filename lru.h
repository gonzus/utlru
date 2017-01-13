#ifndef LRU_H_
#define LRU_H_

#include <uthash.h>

typedef char* CacheKey;
typedef char* CacheVal;

typedef struct CacheEntry {
    CacheKey key;
    CacheVal val;
    UT_hash_handle hh;
} CacheEntry;

typedef struct Cache {
    int size;
    CacheEntry* data;
} Cache;

Cache* cache_build(int size);
void cache_destroy(Cache* cache);

const CacheVal cache_find(Cache* cache, const CacheKey key);
void cache_add(Cache* cache, const CacheKey key, const CacheVal val);

#endif
