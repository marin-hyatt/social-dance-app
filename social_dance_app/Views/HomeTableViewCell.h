//
//  HomeTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@end

NS_ASSUME_NONNULL_END
