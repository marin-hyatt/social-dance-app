//
//  TutorialSettingViewController.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TutorialSettingDelegate <NSObject>

- (void)mirrorVideoChangedWithNewValue:(BOOL)isMirrored;
- (void)videoSpeedChangedWithNewMultiplier:(float)multiplier;
- (void)startTimeChangedToTime:(CMTime)startTime withReset:(BOOL)reset;
- (void)endTimeChangedToTime:(CMTime)endTime withReset:(BOOL)reset;

@end

@interface TutorialSettingViewController : UIViewController
@property (nonatomic, weak) id<TutorialSettingDelegate> delegate;
@property BOOL isMirrored;
@property float videoSpeedMutliplier;
@property NSString *startTimePlaceholder;
@property NSString *endTimePlaceholder;

@end

NS_ASSUME_NONNULL_END
