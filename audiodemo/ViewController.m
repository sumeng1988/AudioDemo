//
//  ViewController.m
//  audiodemo
//
//  Created by sumeng on 7/28/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "ViewController.h"
#import "AudioAmrUtil.h"
#import "BubblePlayView.h"
#import "AudioRecordView.h"

@interface Cell : UITableViewCell

@property (nonatomic, strong) BubblePlayView *bubbleView;

@end

@implementation Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[BubblePlayView alloc] init];
        [self.contentView addSubview:_bubbleView];
    }
    return self;
}

@end

@interface ViewController () <AudioRecordViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AudioRecordView *recordView;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordView.delegate = self;
    
    _datas = [[NSMutableArray alloc] init];
}

#pragma mark - AudioRecordViewDelegate

- (void)recordView:(AudioRecordView *)recordView recordFinished:(NSString *)file duration:(NSTimeInterval)duration {
    [_datas addObject:@{@"file":file, @"duration":[NSNumber numberWithDouble:duration]}];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_datas.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *data = _datas[indexPath.row];
    cell.bubbleView.type = indexPath.row % 2;
    cell.bubbleView.url = [NSURL fileURLWithPath:[data objectForKey:@"file"]];
    cell.bubbleView.duration = ((NSNumber *)[data objectForKey:@"duration"]).doubleValue;
    cell.bubbleView.validator = [NSNumber numberWithInteger:indexPath.row];
    
    CGRect r = cell.bubbleView.frame;
    r.origin.x = indexPath.row % 2 == 0 ? 0 : tableView.frame.size.width-r.size.width;
    cell.bubbleView.frame = r;
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end
