//
//  WGHostManager.h
//  Comikon
//
//  Created by Wen on 15/3/12.
//
//

#import <Foundation/Foundation.h>

@interface WGHostManager : NSObject

+ (instancetype)instance;
- (NSString*)getIPForHost:(NSString*)host;
- (void)setHosts:(NSArray*)hosts;

@end
