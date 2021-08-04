//
//  CommentTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CommentTableViewCellDelegate;

@interface CommentTableViewCell : UITableViewCell
@property (nonatomic, strong) Comment *comment;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) id<CommentTableViewCellDelegate> delegate;
- (void)updateAppearance;

@end

@protocol CommentTableViewCellDelegate <NSObject>
-(void)feedCell:(CommentTableViewCell *)feedCell didTap:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
