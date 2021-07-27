//
//  UserSearchTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/27/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) PFUser *user;
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
