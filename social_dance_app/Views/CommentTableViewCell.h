//
//  CommentTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentTableViewCell : UITableViewCell
@property (nonatomic, strong) Comment *comment;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
