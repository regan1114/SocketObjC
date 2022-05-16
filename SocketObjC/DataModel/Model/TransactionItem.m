//
//  TransactionModel.m
//  SocketObjC
//
//  Created by regan on 2022/5/10.
//

#import "TransactionItem.h"

@implementation TransactionItem

-(void) initWithDictionary:(NSDictionary*)item{
    //"e": "trade", // 事件類型
    self.eventName = [item objectForKey:@"e"];
    //"E": 123456789, // 事件時間
    self.evnetUnixTime = [[item objectForKey:@"E"] intValue];
    //"s": "BNBBTC", // 交易對
    self.transactionName = [item objectForKey:@"s"];
    //"t": 12345, // 交易ID
    self.transactionID = [[item objectForKey:@"t"] intValue];
    //"p": "0.001", // 成交價格
    self.price = [[item objectForKey:@"p"] floatValue];
    //"q": "100", // 成交數量
    self.amount = [[item objectForKey:@"q"] intValue];
    //"b": 88, // 買方的訂單ID
    self.buyer = [[item objectForKey:@"b"] intValue];
    //"a": 50, // 賣方的訂單ID
    self.seller = [[item objectForKey:@"a"] intValue];
    //"T": 123456785, // 成交時間
    self.time = [[item objectForKey:@"T"] intValue];
    //"m": true, // 買方是否是做市方。如true，則此次成交是一個主動賣出單，否則是一個主動買入單。
    self.isSellOrder = [[item objectForKey:@"m"] boolValue];
    //"M": true // 請忽略該字
    self.isM = [[item objectForKey:@"M"] boolValue];
}
@end
