//
//  WebsocketManager.h
//  TestWebSocket
//
//  Created by regan on 2022/4/29.
//


#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, WebSocketStatus){
    WebSocketStatusDefault = 0, //初始狀態，未連接
    WebSocketStatusConnect,     //已連接
    WebSocketStatusDisConnect,  //斷開連接
};

@protocol WebSocketManagerDelegate<NSObject>

-(void)webSocketDidReceiveMessage:(NSString *)string;

@end


@interface SocketService : NSObject

typedef void (^socketDidReceiveMessage) (NSString *);
@property (nonatomic , copy)  socketDidReceiveMessage socketMessage;
-(void) didReceiveMessage:(socketDidReceiveMessage) socketMessage;

@property(nonatomic, weak) id<WebSocketManagerDelegate> delegate;

@property(nonatomic, strong) SRWebSocket *webScoket;
@property(nonatomic, assign) BOOL isConnect; //是否連接
@property(nonatomic, assign) WebSocketStatus socketStatus;

+(instancetype)shared;
-(void)connectServer;//建立長連接
-(void)reConnectServer;//重新連接
-(void)webSocketClose;//關閉連接

@end

NS_ASSUME_NONNULL_END
