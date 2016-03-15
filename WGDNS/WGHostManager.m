//
//  WGHostManager.m
//  Comikon
//
//  Created by Wen on 15/3/12.
//
//

#import "WGHostManager.h"
#import "WGHost.h"
#import "WGDNStorage.h"

@implementation WGHostManager {
    NSArray *_hosts;
}

+ (void)load {
    [super load];
    [self instance];
}

+ (instancetype)instance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _hosts = [[WGDNStorage shareDNStorage]getHosts];
    }
    return self;
}

- (NSString*)getIPForHost:(NSString*)host {
    if (!host) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (WGHost *hostInfo in _hosts) {
        if ([hostInfo.name isEqualToString:host]) {
            [array addObject:hostInfo.ip];
        }
    }
    NSUInteger index = arc4random_uniform((u_int32_t)array.count);
    if (index < array.count) {
        return [array objectAtIndex:index];
    }
    return nil;
}

- (void)setHosts:(NSArray*)hosts {
    _hosts = hosts;
    [[WGDNStorage shareDNStorage]setHosts:_hosts];
}

@end
