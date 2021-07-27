//
//  TutorialSettingViewController.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TutorialSettingDelegate <NSObject>

- (void)mirrorVideoChangedWithNewValue:(BOOL)isMirrored;
- (void)videoSpeedChangedWithNewMultiplier:(float)multiplier;

@end

@interface TutorialSettingViewController : UIViewController
@property (nonatomic, weak) id<TutorialSettingDelegate> delegate;
@property BOOL isMirrored;
@property float videoSpeedMutliplier;

@end

NS_ASSUME_NONNULL_END
