//
//  WGIPBlacklistManager.h
//  Comikon
//
//  Created by Wen on 15/3/16.
//
//

#import <Foundation/Foundation.h>

@interface WGIPBlacklistManager : NSObject

+ (instancetype)shareManager;
- (BOOL)isContain:(NSString*)ipAddresses;
- (void)setIPBlacklist:(NSArray*)blacklist;

@end
