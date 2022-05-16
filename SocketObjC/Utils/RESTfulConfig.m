//
//  RESTfulConfig.m
//  SocketObjC
//
//  Created by regan on 2022/5/10.
//

#import "RESTfulConfig.h"

@implementation RESTfulConfig
+(NSString*)getSocketUrl{
    return [NSString stringWithFormat:@"%@",Socket_URL];
}
@end
