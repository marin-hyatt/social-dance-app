//
//  DetailView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailView : UIView
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property AVPlayer *player;
@property AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
-(void)updateAppearanceWithPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
