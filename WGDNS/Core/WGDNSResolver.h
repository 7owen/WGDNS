//
//  WGDNSResolver.h
//  Comikon
//
//  Created by 7owen on 15/12/31.
//
//

#import <Foundation/Foundation.h>

extern const int WGDNSResolverHijackingCode;
extern const int WGDNSResolverDomainNotOwnCode;
extern const int WGDNSResolverDomainSeverError;

@interface WGDNSResolver : NSObject

@property (nonatomic, strong, readonly) NSString *server;
@property (nonatomic, assign) NSInteger sId;

- (instancetype)initWithServer:(NSString*)server;
- (NSArray*)query:(NSString*)domain error:(NSError**)error;

@end

@interface WGQNResolver : WGDNSResolver

@end

//指定DNS服务器IP,直接查询
@interface WGDirectDNSResolver : WGQNResolver

@end

//DNSPod推出的HTTP协议的域名解析服务
@interface WGDNSPodResolver : WGQNResolver

- (instancetype)initWithServer:(NSString*)server dnspodId:(NSString*)dnspodId dnspodKey:(NSString*)dnspodKey;

@end

//系统默认的DNS查询
@interface WGLocalDNSResolver : WGQNResolver

@end