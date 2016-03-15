//
//  WGDNSManager.m
//  Comikon
//
//  Created by Wen on 15/3/12.
//
//

#import "WGDNSManager.h"
#import "WGHostManager.h"
#import "WGIPBlacklistManager.h"
#import "WGDNSLookup.h"
#import "WGDNStorage.h"
#import "WGDNSRecord.h"

@implementation WGDNSManager

+ (instancetype)instance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (NSString*)queryWithDomain:(NSString*)domain {
    if (!domain) {
        return nil;
    }
    
    WGDNSRecord *record = [[WGDNStorage shareDNStorage]getDNSRecordCacheForDomain:domain];
    NSLog(@"Is cache ip expired?");
    BOOL isExpired = [self isExpired:record];
    if (isExpired) {
        NSLog(@"DNS cache ttl expired. domain:%@, cache ip:%@", domain, record.ip);
    }
    if (record && !isExpired) {
        return record.ip;
    } else {
        WGDNSRecord *newRecord = nil;
        NSArray *ret = [[WGDNSLookup shareDNSLookup]lookupForDomain:domain];
        if (ret.count) {
            newRecord = [ret objectAtIndex:(NSInteger)arc4random_uniform((u_int32_t)ret.count)];
        }
        if (newRecord.ip) {
            NSLog(@"Succeeded for DNS lookup.");
            if (![[WGIPBlacklistManager shareManager] isContain:newRecord.ip]) {
                NSLog(@"IP not in blacklist.");
                [[WGDNStorage shareDNStorage]cacheDNSRecord:newRecord];
                NSLog(@"Cache DNS lookup result. domain:%@, ip:%@", domain, newRecord.ip);
                return newRecord.ip;
            } else {
                NSString *hostIp = [[WGHostManager instance] getIPForHost:domain];
                NSLog(@"IP on blacklist. Using the domain(%@) mapping ip:%@.", domain, hostIp);
                return hostIp;
            }
        } else if (record.ip) {
            NSString *cacheIp = record.ip;
            NSLog(@"DNS lookup faild. Using the previous ip(%@) lookup results. host:%@", cacheIp, domain);
            return cacheIp;
        } else {
            NSString *hostIp = [[WGHostManager instance] getIPForHost:domain];
            NSLog(@"DNS lookup faild, and not cache. Using the domain(%@) mapping ip:%@.", domain, hostIp);
            return hostIp;
        }
    }
}

- (BOOL)isExpired:(WGDNSRecord*)record {
    return ([[NSDate date]timeIntervalSince1970] > record.expiredDate);
}

@end
