//
//  WGDNStorage.m
//  Comikon
//
//  Created by 7owen on 15/12/23.
//
//

#import "WGDNStorage.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "WGDNSRecord.h"
#import "pthread.h"
#import "WGDNSConfig.h"
#import "WGHost.h"

@interface WGDNStorage ()

@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, assign) pthread_mutex_t mutex;

@end

@implementation WGDNStorage

+ (instancetype)shareDNStorage {
    static id shareNDSCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNDSCache = [self new];
    });
    return shareNDSCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDB];
        _records = [NSMutableArray arrayWithCapacity:5];
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)cacheDNSRecord:(WGDNSRecord*)record {
    BOOL bFind = NO;
    pthread_mutex_lock(&_mutex);
    for (WGDNSRecord *_record in _records) {
        if ([_record.domain isEqualToString:record.domain]) {
            _record.ip = record.ip;
            _record.expiredDate = record.expiredDate;
            bFind = YES;
            break;
        }
    }
    
    if (!bFind) {
        [_records addObject:record];
    }
    pthread_mutex_unlock(&_mutex);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_queue inDatabase:^(FMDatabase *db) {
            if (![db executeUpdate:@"replace into record_cache (domain, ip, expired_date) values (?,?,?)", record.domain, record.ip, @(record.expiredDate)]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
            }
        }];
    });
}

- (WGDNSRecord*)getDNSRecordCacheForDomain:(NSString*)domain {
    
    __block WGDNSRecord *record = nil;
    
    pthread_mutex_lock(&_mutex);
    for (WGDNSRecord *_record in _records) {
        if ([_record.domain isEqualToString:domain]) {
            record = _record;
            break;
        }
    }
    pthread_mutex_unlock(&_mutex);
    
    if (!record) {
        [_queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"select ip, expired_date from record_cache where domain = ?", domain];
            if ([rs next]) {
                record = [WGDNSRecord new];
                record.domain = domain;
                record.ip = [rs stringForColumn:@"ip"];
                record.expiredDate = [rs doubleForColumn:@"expired_date"];
                
                pthread_mutex_lock(&_mutex);
                [_records addObject:record];
                pthread_mutex_unlock(&_mutex);
            }
            [rs close];
        }];
    }
    
    return record;
}

- (void)setIPBlacklist:(NSSet*)blacklist {
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:@"delete from ip_blacklist"]) {
            NSLog(@"%@",[db.lastError localizedDescription]);
            *rollback = YES;
        }
        for (NSString *ip in blacklist) {
            if (![db executeUpdate:@"insert into ip_blacklist (ip) values (?)", ip]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
        }
    }];
}

- (NSArray*)getIPBlacklist {
    NSMutableArray *blacklist = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select ip from ip_blacklist"];
        while ([rs next]) {
            [blacklist addObject:[rs stringForColumn:@"ip"]];
        }
    }];
    return blacklist;
}

- (void)setHosts:(NSArray*)hosts {
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:@"delete from host_list"]) {
            NSLog(@"%@",[db.lastError localizedDescription]);
            *rollback = YES;
        }
        for (WGHost *host in hosts) {
            if (![db executeUpdate:@"insert into host_list (ip, host) values (?,?)", host.ip, host.name]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
        }
    }];
}

- (NSArray*)getHosts {
    NSMutableArray *blacklist = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select host, ip from host_list"];
        while ([rs next]) {
            WGHost *host = [WGHost new];
            host.name = [rs stringForColumn:@"host"];
            host.ip = [rs stringForColumn:@"ip"];
            [blacklist addObject:host];
        }
    }];
    return blacklist;
}

#pragma mark private

- (void)initDB {
    if (!_queue) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:[WGDNSConfig databasePath]];
    }
    __block NSInteger dbVersion = [self dbVersion];
    if (dbVersion == 0) {
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if (![db executeUpdate:@"create table if not exists record_cache (domain TEXT primary key, ip TEXT, expired_date REAL)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            if(![db executeUpdate:@"create unique index if not exists record_cache_domain on record_cache(domain)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            
            if (![db executeUpdate:@"create table if not exists ip_blacklist (ip TEXT primary key)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            if(![db executeUpdate:@"create unique index if not exists ip_blacklist_ip on ip_blacklist(ip)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            
            if (![db executeUpdate:@"create table if not exists host_list (host TEXT primary key, ip TEXT)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            if(![db executeUpdate:@"create unique index if not exists host_list_host on host_list(host)"]) {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
            
            if ([self setDBVersion:dbVersion + 1 db:db]) {
                ++dbVersion;
            } else {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
        }];
    }
    /*
    if (dbVersion == 1) {
        [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            if ([self setDBVersion:dbVersion + 1 db:db]) {
                ++dbVersion;
            } else {
                NSLog(@"%@",[db.lastError localizedDescription]);
                *rollback = YES;
            }
        }];
    }
     */
}

- (NSInteger)dbVersion {
    __block NSInteger dbVersion = 0;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"pragma user_version;"];
        if ([rs next]) {
            dbVersion = [rs intForColumn:@"user_version"];
        }
        [rs close];
    }];
    return dbVersion;
}

- (BOOL)setDBVersion:(NSInteger)version db:(FMDatabase*)db {
    return [db executeUpdate:[NSString stringWithFormat:@"pragma user_version = %@;", @(version)]];
}

@end
