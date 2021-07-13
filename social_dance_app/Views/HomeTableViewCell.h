//
//  HomeTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell
@property Post *post;
@property AVPlayer *player;
@property AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
-(void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
