//
//  CustomTableViewCell.h
//  TestWebSocket
//
//  Created by regan on 2022/4/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCell : UITableViewCell

@property(nonatomic , strong) UILabel *timeLabel;
@property(nonatomic , strong) UILabel *priceLabel;
@property(nonatomic , strong) UILabel *contentLabel;


-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void) setOptionCellWithItem:(NSDictionary*)option;

@end

NS_ASSUME_NONNULL_END
