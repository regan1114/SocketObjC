//
//  RESTfulConfig.h
//  SocketObjC
//
//  Created by regan on 2022/5/10.
//

#import <Foundation/Foundation.h>
#define Socket_URL @"wss://stream.yshyqxx.com/stream?streams=btcusdt@trade"

NS_ASSUME_NONNULL_BEGIN

@interface RESTfulConfig : NSObject

+(NSString*)getSocketUrl;

@end

NS_ASSUME_NONNULL_END
