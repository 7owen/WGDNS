//
//  WGIPBlacklistManager.m
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import "WGIPBlacklistManager.h"
#import "WGDNStorage.h"

static NSString *defaultBlacklistString = @"127.0.0.0/8,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8";

@interface WGIPBlacklistManager ()

@property (nonatomic, strong) NSSet *blackList;

@end

@implementation WGIPBlacklistManager

+ (instancetype)shareManager {
    static id shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [self new];
    });
    return shareManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSSet *defaultBlacklist = [NSSet setWithArray:[defaultBlacklistString componentsSeparatedByString:@","]];
        NSArray *blackList = [[WGDNStorage shareDNStorage]getIPBlacklist];
        _blackList = [defaultBlacklist setByAddingObjectsFromArray:blackList];
    }
    return self;
}

- (BOOL)isContain:(NSString*)ipAddresses {
    
    for (NSString *ip in _blackList) {
        if ([ip isKindOfClass:[NSString class]]) {
            if ([self p_isCIDRIPAddress:ip]) {
                if ([self p_isContain:ipAddresses inCIDRIPAddress:ip]) {
                    return YES;
                }
            } else {
                if ([self p_convertIP2Int:ip] == [self p_convertIP2Int:ipAddresses]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)setIPBlacklist:(NSArray*)blacklist {
    NSSet *oldSet = [_blackList copy];
    _blackList = [_blackList setByAddingObjectsFromArray:blacklist];
    if (![_blackList isEqualToSet:oldSet]) {
        [[WGDNStorage shareDNStorage]setIPBlacklist:_blackList];
    }
}

- (BOOL)p_isCIDRIPAddress:(NSString*)ip {
    return [ip rangeOfString:@"/"].location != NSNotFound;
}

- (BOOL)p_isContain:(NSString *)ipAddresses inCIDRIPAddress:(NSString*)CIDRIPAddress {
    NSArray *array = [CIDRIPAddress componentsSeparatedByString:@"/"];
    if (array.count != 2) {
        return NO;
    }
    int addr = [self p_convertIP2Int:[array objectAtIndex:0]];
    int rangeContains = [[array objectAtIndex:1]intValue];
    int mask = (-1)<<(32-rangeContains);
    
    int lowest = addr & mask;
    int highest = lowest - (~mask);
    int desAddr = [self p_convertIP2Int:ipAddresses];
    return lowest <= desAddr && desAddr <= highest;
}

- (int)p_convertIP2Int:(NSString*)IP {
    NSArray *ipSplits = [IP componentsSeparatedByString:@"."];
    if (ipSplits.count != 4) {
        return -1;
    }
    int a[4];
    for (int i = 0; i < 4; ++i) {
        a[i] = [[ipSplits objectAtIndex:i] intValue];
    }
    int addr = (( a[0] << 24 ) & 0xFF000000) | (( a[1] << 16 ) & 0xFF0000) | (( a[2] << 8 ) & 0xFF00) | ( a[3] & 0xFF);
    return addr;
}

@end
