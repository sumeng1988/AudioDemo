//
//  AudioRecordView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioRecordViewDelegate;

@interface AudioRecordView : UIControl

@property (nonatomic, strong) id validator;
@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) id<AudioRecordViewDelegate> delegate;

@end

@protocol AudioRecordViewDelegate <NSObject>

@optional

- (void)recordView:(AudioRecordView *)recordView recordFinished:(NSString *)file duration:(NSTimeInterval)duration;

- (void)recordView:(AudioRecordView *)recordView recordFinishedXXX:(NSString *)file duration:(NSTimeInterval)duration;

@end