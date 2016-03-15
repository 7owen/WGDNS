//
//  WGDNSRecord.h
//  Comikon
//
//  Created by 7owen on 15/12/23.
//
//

#import <Foundation/Foundation.h>

@interface WGDNSRecord : NSObject

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, assign) NSTimeInterval expiredDate;

@end
