//
//  ProfileView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileView : UIView
@property PFUser *user;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *numFollowersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerButton;
-(void)updateAppearanceWithFollowerCount:(int)followerCount;
@end

NS_ASSUME_NONNULL_END
