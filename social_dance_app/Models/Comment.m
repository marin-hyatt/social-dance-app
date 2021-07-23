//
//  Comment.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "Comment.h"

@implementation Comment

@dynamic post;
@dynamic author;
@dynamic text;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void)newCommentWithPost:(Post *)post withAuthor:(PFUser *)user withText:(NSString *)text withCompletion:(PFBooleanResultBlock)completion {
    Comment *comment = [Comment new];
    comment.post = post;
    comment.author = user;
    comment.text = text;
    
    [comment saveInBackgroundWithBlock:completion];
}

@end
