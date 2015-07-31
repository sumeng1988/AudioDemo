//
//  AudioRecordView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioRecordView.h"
#import "AudioManager.h"

@interface AudioRecordView () <AudioManagerDelegate>

@property (nonatomic, strong) UILabel *titleLbl;

@end

@implementation AudioRecordView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (void)initAudioRecordView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1;
    
    _isRecording = NO;
    
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.font = [UIFont systemFontOfSize:14];
    _titleLbl.textColor = [UIColor blackColor];
    _titleLbl.text = @"按住说话";
    [_titleLbl sizeToFit];
    _titleLbl.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:_titleLbl];
    
    [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)record {
    [self stop];
    
    _isRecording = YES;
    [AudioManager shared].delegate = self;
    [[AudioManager shared] recordWithValidator:_validator];
}

- (void)stop {
    _isRecording = NO;
    [[AudioManager shared] stopPlay];
}

- (void)onTouchDown:(id)sender {
    [self record];
    
    _titleLbl.text = @"松开发送";
    [_titleLbl sizeToFit];
    _titleLbl.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)onTouchUpInside:(id)sender {
    [[AudioManager shared] stopRecord];
    
    _titleLbl.text = @"按住说话";
    [_titleLbl sizeToFit];
    _titleLbl.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)onTouchUpOutside:(id)sender {
    [[AudioManager shared] stopRecord];
    
    _titleLbl.text = @"按住说话";
    [_titleLbl sizeToFit];
    _titleLbl.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - AudioManagerDelegate

- (void)didAudioRecordStarted:(AudioManager *)am {
    
}

- (void)didAudioRecordStoped:(AudioManager *)am file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully {
    _isRecording = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(recordView:recordFinished:duration:)]) {
        [_delegate recordView:self recordFinished:file duration:duration];
    }
}

- (void)didAudioRecord:(AudioManager *)am err:(NSError *)err {
    _isRecording = NO;
}

@end
