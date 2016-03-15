//
//  WGDNStorage.h
//  Comikon
//
//  Created by 7owen on 15/12/23.
//
//

#import <Foundation/Foundation.h>

@class WGDNSRecord;

@interface WGDNStorage : NSObject

+ (instancetype)shareDNStorage;
- (void)cacheDNSRecord:(WGDNSRecord*)record;
- (WGDNSRecord*)getDNSRecordCacheForDomain:(NSString*)domain;

- (void)setIPBlacklist:(NSSet*)blacklist;
- (NSArray*)getIPBlacklist;

- (void)setHosts:(NSArray*)hosts;
- (NSArray*)getHosts;

@end
