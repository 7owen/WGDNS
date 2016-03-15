//
//  WGDNSConfig.m
//  Comikon
//
//  Created by 7owen on 16/1/2.
//
//

#import "WGDNSConfig.h"
#import "WGDNSResolver.h"

@implementation WGDNSConfig

+ (NSString*)modulePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"wgdns"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@",[error description]);
            return nil;
        }
    }
    return path;
}

+ (NSString*)databasePath {
    return [[self modulePath] stringByAppendingPathComponent:@"wgdns.sqlite"];
}

+ (NSArray*)DNSResolvers {
    return @[
      [[WGDirectDNSResolver alloc] initWithServer:@"223.5.5.5"],
      [[WGDirectDNSResolver alloc] initWithServer:@"223.6.6.6"],
      [[WGDirectDNSResolver alloc] initWithServer:@"114.114.114.114"],
      [[WGDNSPodResolver alloc] initWithServer:@"119.29.29.29" dnspodId:DNSPodId dnspodKey:DNSPodKey],
      ];
}

@end
