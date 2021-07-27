//
//  TutorialView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface TutorialView : UIView
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property AVPlayer *player;
@property AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property float playbackSpeed;
- (void)updateViewWithMirrorSetting:(BOOL)isMirrored;
- (void)mirrorViewWithSetting:(BOOL)isMirrored;
- (void)changePlaybackRateWithRate:(float)playbackSpeed;

@end

NS_ASSUME_NONNULL_END
