//
//  WGDNSManager.h
//  Comikon
//
//  Created by Wen on 15/3/12.
//
//

#import <Foundation/Foundation.h>

@interface WGDNSManager : NSObject

+ (instancetype)instance;
- (NSString*)queryWithDomain:(NSString*)domain;

@end
