//
//  Comment.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "PFObject.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *text;

+(void) newCommentWithPost:(Post *)post withAuthor:(PFUser *)user withText:(NSString *)text withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
