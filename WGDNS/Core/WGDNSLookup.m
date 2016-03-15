//
//  WGDNSLookup.m
//  Comikon
//
//  Created by 7owen on 15/12/23.
//
//

#import "WGDNSLookup.h"
#import "WGDNSRecord.h"
#import "WGDNSResolver.h"
#import "WGDNSConfig.h"

@implementation WGDNSLookup

+ (void)load {
    [super load];
    [self shareDNSLookup];
}

+ (instancetype)shareDNSLookup {
    static id shareDNSLookup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDNSLookup = [self new];
    });
    return shareDNSLookup;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.resolvers = [WGDNSConfig DNSResolvers];
    }
    return self;
}

- (void)setResolvers:(NSArray *)resolvers {
    if (resolvers != _resolvers) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:resolvers];
        [array sortUsingComparator:^NSComparisonResult(WGDNSResolver *obj1, WGDNSResolver *obj2) {
            return [@(obj1.sId)compare:@(obj2.sId)];
        }];
        [array addObject:[[WGLocalDNSResolver alloc]initWithServer:@"localhost"]];
        _resolvers = array;
    }
}

- (NSArray*)lookupForDomain:(NSString*)domain {
    for (WGDNSResolver *resolver in _resolvers) {
        NSError *error = nil;
        NSArray *records = [resolver query:domain error:&error];
        if (error != nil) {
            if (error.code == WGDNSResolverDomainNotOwnCode) {
                continue;
            }
        }
        if (records.count) {
            return records;
        }
    }
    return nil;
}

@end
