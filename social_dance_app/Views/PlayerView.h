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


@property AVPlayer *player;
-(void)printDimensions;
 

@end

NS_ASSUME_NONNULL_END
