//
//  TransactionModel.h
//  SocketObjC
//
//  Created by regan on 2022/5/10.
//
@import UIKit;
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransactionItem : NSObject

//"e": "trade", // 事件類型
@property(nonatomic, strong) NSString *eventName;
//"E": 123456789, // 事件時間
@property(nonatomic) NSInteger evnetUnixTime;
//"s": "BNBBTC", // 交易對
@property(nonatomic, strong) NSString *transactionName;
//"t": 12345, // 交易ID
@property(nonatomic) NSInteger transactionID;
//"p": "0.001", // 成交價格
@property(nonatomic) CGFloat price;
//"q": "100", // 成交數量
@property(nonatomic) NSInteger amount;
//"b": 88, // 買方的訂單ID
@property(nonatomic) NSInteger buyer;
//"a": 50, // 賣方的訂單ID
@property(nonatomic) NSInteger seller;
//"T": 123456785, // 成交時間
@property(nonatomic) NSInteger time;
//"m": true,買方是否是做市方。如true，則此次成交是一個主動賣出單，否則是一個主動買入單。
@property(nonatomic) Boolean isSellOrder;
//"M": true // 請忽略該字
@property(nonatomic) Boolean isM;

-(void) initWithDictionary:(NSDictionary*)item;

@end

NS_ASSUME_NONNULL_END
