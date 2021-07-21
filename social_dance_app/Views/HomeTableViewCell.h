//
//  HomeTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PlayerView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HomeTableViewCellDelegate;

@interface HomeTableViewCell : UITableViewCell
@property Post *post;
@property AVPlayer *player;
@property AVPlayerItem *playerItem;
@property AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (strong, nonatomic) IBOutlet PlayerView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) id<HomeTableViewCellDelegate> delegate;
-(void)updateAppearance;

@end

@protocol HomeTableViewCellDelegate <NSObject>
- (void)feedCell:(HomeTableViewCell *) feedCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
