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

@protocol PlayerViewDelegate <NSObject>

- (void)displayVideoThumbnail;
- (void)removeVideoThumbnail;

@end

@interface PlayerView : UIView
@property NSLayoutConstraint *constraint;
@property AVPlayer *player;
@property (weak, nonatomic) id<PlayerViewDelegate> delegate;
- (void)updateAutolayoutWithHeight:(CGFloat) height withWidth:(CGFloat) width;
 

@end

NS_ASSUME_NONNULL_END
