//
//  WebsocketManager.m
//  TestWebSocket
//
//  Created by regan on 2022/4/29.
//

#import "SocketService.h"
#import "AFNetworking.h"
#import "RESTfulConfig.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface SocketService ()<SRWebSocketDelegate>

@property(nonatomic, strong) NSTimer *headerBeatTimer; //心跳定時器
@property(nonatomic, strong) NSTimer *networkTestingTimer; //沒有網絡的時候檢測定時器
@property(nonatomic, assign) NSTimeInterval reConnectTime; //重連時間
@property(nonatomic, strong) NSMutableArray *sendDataArray; //存儲要發送給服務器的數據
@property(nonatomic, assign) BOOL isActiveClose; //用於判斷是否主動關閉長連接，如果是主動斷開連接，連接失敗的代理中，就不用執行 重新連接方法

@end


@implementation SocketService

+(instancetype)shared{
    static SocketService *__instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[SocketService alloc] init];
    });
    return __instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.reConnectTime = 0;
        self.isActiveClose = NO;
        self.sendDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//建立長連接
-(void)connectServer{
    if(self.webScoket){
        return;
    }
    
    self.webScoket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[RESTfulConfig getSocketUrl]]];
    self.webScoket.delegate = self;
    [self.webScoket open];
}

-(void)sendPing:(id)sender{
    NSLog(@"sendPing heart");
//    NSString *heart = @"heart";
    NSData *heartData = [[NSData alloc] initWithBase64EncodedString:@"heart" options:NSUTF8StringEncoding];
    [self.webScoket sendPing:heartData error:NULL];
    
}

//關閉長連接
-(void)webSocketClose{
    self.isActiveClose = YES;
    self.isConnect = NO;
    self.socketStatus = WebSocketStatusDefault;
    
    if (self.webScoket) {
        [self.webScoket close];
        self.webScoket = nil;
    }
    //關閉心跳定時器
    [self destoryHeartBeat];
    //關閉網絡檢測定時器
    [self destoryNetWorkStartTesting];
}

#pragma mark socket delegate
//已經連接
-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"已經連接,開啓心跳");
    self.isConnect = YES;
    self.socketStatus = WebSocketStatusConnect;
    [self initHeartBeat];//開始心跳
}

//連接失敗
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"連接失敗");
    self.isConnect = NO;
    self.socketStatus = WebSocketStatusDisConnect;
    NSLog(@"連接失敗，這裏可以實現掉線自動重連，要注意以下幾點");
    NSLog(@"1.判斷當前網絡環境，如果斷網了就不要連了，等待網絡到來，在發起重連");
    NSLog(@"2.判斷調用層是否需要連接，不需要的時候不k連接，浪費流量");
    NSLog(@"3.連接次數限制，如果連接失敗了，重試10次左右就可以了");
    //判斷網絡環境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        //沒有網絡,開啓網絡監測定時器
        [self noNetWorkStartTesting];//開啓網絡檢測定時器
    }else{
        [self reConnectServer];//連接失敗，重新連接
    }
    
}

//接收消息
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(webSocketDidReceiveMessage:)]) {
//        [self.delegate webSocketDidReceiveMessage:message];
//    }
    if(self.socketMessage) {
        self.socketMessage(message);
    }
}

//關閉連接
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    self.isConnect = NO;
    if (self.isActiveClose) {
        self.socketStatus = WebSocketStatusDefault;
        return;
    }else{
        self.socketStatus = WebSocketStatusDisConnect;
    }
    NSLog(@"被關閉連接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    [self destoryHeartBeat];  //斷開時銷燬心跳
    
    //判斷網絡
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        //沒有網絡,開啓網絡監測定時器
        [self noNetWorkStartTesting];
    }else{
        //有網絡
        NSLog(@"關閉網絡");
        self.webScoket = nil;
        [self reConnectServer];
    }
}


/**
 接受服務端發生Pong消息，我們在建立長連接之後會建立與服務器端的心跳包
 心跳包是我們用來告訴服務端：客戶端還在線，心跳包是ping消息，於此同時服務端也會返回給我們一個pong消息
 */
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData{
    NSLog(@"接受ping 數據  --> %@",pongData);
}

#pragma mark NSTimer
//初始化心跳
-(void)initHeartBeat{
    if (self.headerBeatTimer) {
        return;
    }
    [self destoryHeartBeat];
    dispatch_main_async_safe(^{
        self.headerBeatTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.headerBeatTimer forMode:NSRunLoopCommonModes];
    });
}

//重新連接
-(void)reConnectServer{
    
    //關閉之前的連接
    [self webSocketClose];
    
    //重連10次 2^10 = 1024
    if (self.reConnectTime > 1024) {
        self.reConnectTime = 0;
        return;
    }
    
    __weak typeof(self)ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.webScoket.readyState == SR_OPEN && ws.webScoket.readyState == SR_CONNECTING) {
            return ;
        }
        
        [ws connectServer];
        NSLog(@"重新連接......");
        if (ws.reConnectTime == 0) {//重連時間2的指數級增長
            ws.reConnectTime = 2;
        }else{
            ws.reConnectTime *= 2;
        }
    });
}

//發送心跳
-(void)senderheartBeat{
    NSLog(@"senderheartBeat");
    //和服務端約定好發送什麼作爲心跳標識，儘可能的減小心跳包大小
    __weak typeof (self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.webScoket.readyState == SR_OPEN) {
            [ws sendPing:nil];
        }else if (ws.webScoket.readyState == SR_CONNECTING){
            NSLog(@"正在連接中");
            [ws reConnectServer];
        }else if (ws.webScoket.readyState == SR_CLOSED || ws.webScoket.readyState == SR_CLOSING){
            NSLog(@"斷開，重連");
            [ws reConnectServer];
        }else{
            NSLog(@"沒網絡，發送失敗，一旦斷網 socket 會被我設置 nil 的");
        }
    });
}

//取消心跳
-(void)destoryHeartBeat{
    __weak typeof(self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.headerBeatTimer) {
            [ws.headerBeatTimer invalidate];
            ws.headerBeatTimer = nil;
        }
    });
}

//沒有網絡的時候開始定時 -- 用於網絡檢測
-(void)noNetWorkStartTestingTimer{
    __weak typeof(self)ws = self;
    dispatch_main_async_safe(^{
        ws.networkTestingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(noNetWorkStartTesting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:ws.networkTestingTimer forMode:NSDefaultRunLoopMode];
    });
}

//定時檢測網絡
-(void)noNetWorkStartTesting{
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        //關閉網絡檢測定時器
        [self destoryNetWorkStartTesting];
        //重新連接
        [self reConnectServer];
    }
}
//取消網絡檢測
-(void)destoryNetWorkStartTesting{
    __weak typeof(self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.networkTestingTimer) {
            [ws.networkTestingTimer invalidate];
            ws.networkTestingTimer = nil;
        }
    });
}

//發送數據給服務器
-(void)sendDataToServer:(NSString *)data{
    [self.sendDataArray addObject:data];
    
    //沒有網絡
    if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable){
        //開啓網絡檢測定時器
        [self noNetWorkStartTesting];
    }else{
        if (self.webScoket != nil) {
            //只有長連接OPEN開啓狀態才能調用send方法
            if (self.webScoket.readyState == SR_OPEN) {
                [self.webScoket send:data];
            }else if (self.webScoket.readyState == SR_CONNECTING){
                //正在連接
                NSLog(@"正在連接中，重連後會去自動同步數據");
            }else if(self.webScoket.readyState == SR_CLOSING || self.webScoket.readyState == SR_CLOSED){
                //調用 reConnectServer 方法重連,連接成功後 繼續發送數據
                [self reConnectServer];
            }
        }else{
            [self connectServer];//連接服務器
        }
    }
}

-(void) didReceiveMessage:(socketDidReceiveMessage) socketMessage {
    self.socketMessage = socketMessage;
}
@end
