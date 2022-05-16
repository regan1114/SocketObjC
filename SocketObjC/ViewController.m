//
//  ViewController.m
//  SocketObjC
//
//  Created by regan on 2022/5/10.
//

#import "ViewController.h"
#import "SocketService.h"
#import "CustomTableViewCell.h"
#import "Masonry.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadData];
}

-(void)loadData {
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    [[SocketService shared] connectServer];
    [[SocketService shared] didReceiveMessage:^(NSString *message) {
        [self webSocketDidReceiveMessage:message];
    }];
}

-(UITableView *)tableView
{
    if(_tableView == nil){
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(20);
            make.left.right.bottom.equalTo(self.view);
        }];
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (void)webSocketDidReceiveMessage:(NSString *)string {
    
    NSStringEncoding  encoding = 0;
    NSData * jsonData = [string dataUsingEncoding:encoding];
    NSError * error=nil;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSDictionary *data = [parsedData objectForKey:@"data"];
    [self.dataSource insertObject:data atIndex:0];
    if(self.dataSource.count >= 40) {
        [self.dataSource removeLastObject];
    }
    [self.tableView reloadData];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomTableViewCell"];
    if(!cell){
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomTableViewCell"];
        [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"CustomTableViewCell"];
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    [cell setOptionCellWithItem:data];
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}


@end
