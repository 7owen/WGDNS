//
//  WGHost.h
//  Comikon
//
//  Created by 7owen on 16/3/11.
//
//
#import <Foundation/Foundation.h>

static NSString *defaultHosts = @"\
54.248.88.232   d.bone.comikon.net  \n\
54.248.88.232   d.fuser.comikon.net \n\
54.248.88.232   d.pi.comikon.net    \n\
54.248.88.232   d.drm.comikon.net   \n\
54.248.88.232   d.fbank.comikon.net"
;

@interface WGHost : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ip;

@end
