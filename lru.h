#ifndef LRU_H_
#define LRU_H_

#include "EXTERN.h"
#include "perl.h"
#include <uthash.h>

typedef struct CacheEntry {
    SV* key;
    SV* val;
    UT_hash_handle hh;
} CacheEntry;

typedef struct Cache {
    int size;
    CacheEntry* data;
} Cache;

Cache* cache_build(pTHX_ int size);
void cache_destroy(pTHX_ Cache* cache);

SV* cache_find(pTHX_ Cache* cache, SV* key);
void cache_add(pTHX_ Cache* cache, SV* key, SV* val);

typedef void (CacheVisitor)(Cache* cache, CacheEntry* entry, void* arg);
void cache_iterate(pTHX_ Cache* cache, CacheVisitor visitor, void* arg);

#endif
