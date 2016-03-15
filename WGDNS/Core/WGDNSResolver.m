//
//  WGDNSResolver.m
//  Comikon
//
//  Created by 7owen on 15/12/31.
//
//

#import "WGDNSResolver.h"
#import "HappyDNS.h"
#import "WGDNSRecord.h"
#import "WGDNSConfig.h"

static const NSTimeInterval WGDNSLookupTimeout = 1.f;

const int WGDNSResolverHijackingCode = -7001;
const int WGDNSResolverDomainNotOwnCode = -7002;
const int WGDNSResolverDomainSeverError = -7003;

@interface WGDNSResolver ()

@property (nonatomic, assign) NSTimeInterval timeout;

@end

@implementation WGDNSResolver

- (instancetype)initWithServer:(NSString*)server {
    self = [super init];
    if (self) {
        _server = server;
        _timeout = WGDNSLookupTimeout;
    }
    return self;
}

- (NSArray*)query:(NSString*)domain error:(NSError**)error {
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////
@interface WGQNResolver ()

@property (nonatomic, strong) id <QNResolverDelegate> resolver;

@end

@implementation WGQNResolver

- (NSArray*)query:(NSString*)domain error:(NSError**)error {
    __block BOOL cancel = NO;
    QNDomain *qnDomain = [[QNDomain alloc] init:domain];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        cancel = YES;
    });
    NSArray *records = [_resolver query:qnDomain networkInfo:nil error:error];
    if (records.count && !cancel) {
        NSMutableArray *ret = [NSMutableArray array];
        for (QNRecord *r in records) {
            if (r.type == kQNTypeA && r.value) {
                WGDNSRecord *record = [WGDNSRecord new];
                record.domain = domain;
                record.ip = r.value;
                record.expiredDate = [[NSDate date]timeIntervalSince1970] + r.ttl;
                [ret addObject:record];
            }
        }
        return ret;
    }
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////

@implementation WGDirectDNSResolver

- (instancetype)initWithServer:(NSString*)server {
    self = [super initWithServer:server];
    if (self) {
        self.sId = 10;
        self.resolver = [[QNResolver alloc] initWithAddres:server];
    }
    return self;
}

- (NSArray*)query:(NSString*)domain error:(NSError**)error {
    NSArray *ret = [super query:domain error:error];
    if (ret.count) {
        NSLog(@"DNS Lookup succeeded. protocol:DirectDNS, server:%@", self.server);
    }
    return ret;
}

@end

////////////////////////////////////////////////////////////////////////////

@implementation WGDNSPodResolver

- (instancetype)initWithServer:(NSString*)server dnspodId:(NSString*)dnspodId dnspodKey:(NSString*)dnspodKe {
    self = [super initWithServer:server];
    if (self) {
        self.sId = 100;
        self.resolver = [[QNDnspodEnterprise alloc] initWithId:dnspodId key:dnspodKe server:server];
    }
    return self;
}

- (instancetype)initWithServer:(NSString*)server {
    self = [super initWithServer:server];
    if (self) {
        self.sId = 100;
        self.resolver = [[QNDnspodFree alloc] initWithServer:server];
    }
    return self;
}

- (NSArray*)query:(NSString*)domain error:(NSError**)error {
    NSArray *ret = [super query:domain error:error];
    if (ret.count) {
        NSLog(@"DNS Lookup succeeded. protocol:DNSPod, server:%@", self.server);
    }
    return ret;
}

@end

////////////////////////////////////////////////////////////////////////////

@implementation WGLocalDNSResolver

- (instancetype)initWithServer:(NSString*)server {
    self = [super initWithServer:server];
    if (self) {
        self.sId = NSIntegerMax;
        self.timeout = 300;
        self.resolver = [QNResolver systemResolver];
    }
    return self;
}

- (NSArray*)query:(NSString*)domain error:(NSError**)error {
    NSArray *ret = [super query:domain error:error];
    if (ret.count) {
        NSLog(@"DNS Lookup succeeded. protocol:LocalDNS");
    }
    return ret;
}

@end
