//
//  WGDNSLookup.h
//  Comikon
//
//  Created by 7owen on 15/12/23.
//
//

#import <Foundation/Foundation.h>

@interface WGDNSLookup : NSObject

@property (nonatomic, strong) NSArray *resolvers;

+ (instancetype)shareDNSLookup;
- (NSArray*)lookupForDomain:(NSString*)domain;

@end
