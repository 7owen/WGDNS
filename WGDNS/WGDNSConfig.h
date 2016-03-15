//
//  WGDNSConfig.h
//  Comikon
//
//  Created by 7owen on 16/1/2.
//
//

#import <Foundation/Foundation.h>


#define DNSPodId @"130"
#define DNSPodKey @"pUgIuXT0"

@interface WGDNSConfig : NSObject

+ (NSString*)modulePath;
+ (NSString*)databasePath;
+ (NSArray*)DNSResolvers;

@end
