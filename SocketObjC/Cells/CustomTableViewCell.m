//
//  CustomTableViewCell.m
//  TestWebSocket
//
//  Created by regan on 2022/4/29.
//

#import "CustomTableViewCell.h"
#import "Masonry.h"

@interface CustomTableViewCell()
{
}
@property(strong , nonatomic) NSString *currentReuseIdentifier;
@end


@implementation CustomTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.lineBreakMode = NSLineBreakByClipping;
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.timeLabel];
    
    self.priceLabel = [[UILabel alloc]init];
    self.priceLabel.numberOfLines = 0;
    self.priceLabel.lineBreakMode = NSLineBreakByClipping;
    self.priceLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.priceLabel];
    
    self.contentLabel = [[UILabel alloc]init];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByClipping;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.contentLabel];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.mas_offset(10);
        make.top.mas_equalTo(self.contentView).with.offset(0);
        make.bottom.mas_equalTo(self.contentView).with.offset(0);
        make.width.mas_offset(80);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).with.mas_offset(0);
        make.top.mas_equalTo(self.contentView).with.offset(0);
        make.bottom.mas_equalTo(self.contentView).with.offset(0);
        make.right.mas_equalTo(self.contentLabel.mas_left).with.mas_offset(0);

    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).with.offset(0);
        make.top.mas_equalTo(self.contentView).with.offset(0);
        make.bottom.mas_equalTo(self.contentView).with.offset(0);
//        make.left.mas_equalTo(self.priceLabel.mas_right).with.mas_offset(0);
        make.width.mas_offset(80);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setOptionCellWithItem:(NSDictionary*)option
{
    NSString * timeStampString = [NSString stringWithFormat:@"%@",[option objectForKey:@"E"]];
    NSTimeInterval _interval=[timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.timeLabel.text =  strDate;
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f", [[option objectForKey:@"p"] floatValue]];
    self.contentLabel.text = [NSString stringWithFormat:@"%.6f",[[option objectForKey:@"q"] floatValue]];
}

@end
