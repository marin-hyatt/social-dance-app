//
//  PlayerView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface PlayerView : UIView
@property NSLayoutConstraint *constraint;
@property AVPlayer *player;
- (void)updateAutolayoutWithHeight:(CGFloat) height withWidth:(CGFloat) width;
 

@end

NS_ASSUME_NONNULL_END
