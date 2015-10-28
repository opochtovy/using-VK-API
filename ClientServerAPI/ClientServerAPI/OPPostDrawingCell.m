//
//  OPPostDrawingCell.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 12.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPPostDrawingCell.h"

#import "OPPost.h"
#import "OPUser.h"
#import "OPGroup.h"
#import "OPAttachmentPhoto.h"
#import "OPAttachmentVideo.h"

#import "UIImageView+AFNetworking.h"

@interface OPPostDrawingCell ()

@property (assign, nonatomic) CGSize viewSize;

@end

@implementation OPPostDrawingCell

static CGFloat offset = 5.0;

static CGFloat fontOfSize = 14.0;
static CGFloat fontOfSizeForSecondary = 12.0;

static CGFloat postOwnerImageWidth = 40.0;
static CGFloat postOwnerImageHeight = 40.0;

static CGFloat postCopyOwnerImageWidth = 20.0;
static CGFloat postCopyOwnerImageHeight = 20.0;

static CGFloat videoWidth = 320.0;
static CGFloat videoHeight = 240.0;

- (id)initWithPost:(OPPost *)post reuseIdentifier:(NSString *)identifier {
    
    if (post) {
        self.post = post;
    }
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    if (self) {
        
        UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        
        self.viewSize = self.frame.size;
        
        // postOwnerImage
        
        CGRect postOwnerImageFrame = CGRectMake(offset,
                                               offset,
                                               postOwnerImageWidth,
                                               postOwnerImageHeight);
        
        self.postOwnerImageView = [[UIImageView alloc] initWithFrame:postOwnerImageFrame];
        
        [self addSubview:self.postOwnerImageView];
        
        // postOwnerNameLabel
        
        CGFloat postOwnerNameTopOffset = offset;
        
        NSString *postOwnerNameString = [NSString string];
        
        if (post.ownerID > 0) {
            
            postOwnerNameString = [post.postOwnerUser.firstName stringByAppendingFormat:@" %@", post.postOwnerUser.lastName];
            
        } else {
            
            postOwnerNameString = post.postOwnerGroup.name;
        }
        
        CGRect postOwnerNameRect = [OPPostDrawingCell countRectForPostText:postOwnerNameString];
        
        CGRect postOwnerNameFrame = CGRectMake(postOwnerImageWidth + 2 * offset,
                                       offset,
                                       postOwnerNameRect.size.width,
                                       postOwnerNameRect.size.height);
        
        UILabel *postOwnerNameLabel = [[UILabel alloc] initWithFrame:postOwnerNameFrame];
        
        postOwnerNameLabel.numberOfLines = 0;
        
        postOwnerNameLabel.font = [UIFont systemFontOfSize:fontOfSize];
        postOwnerNameLabel.textColor = [UIColor brownColor];
        
        postOwnerNameLabel.text = postOwnerNameString;
        
        [self addSubview:postOwnerNameLabel];
        
        // postCopyOwnerImage
        
        CGFloat postCopyOwnerNameTopOffset = postOwnerNameTopOffset + postOwnerNameRect.size.height + offset;
        
        CGRect postCopyOwnerImageFrame;
        
        if (self.post.copyOwnerID != 0) {
            
            postCopyOwnerImageFrame = CGRectMake(postOwnerImageWidth + 2 * offset,
                                                 postCopyOwnerNameTopOffset,
                                                 postCopyOwnerImageWidth,
                                                 postCopyOwnerImageHeight);
            
            self.postCopyOwnerImageView = [[UIImageView alloc] initWithFrame:postCopyOwnerImageFrame];
            
            [self addSubview:self.postCopyOwnerImageView];
            
        }
        
        // postCopyOwnerNameString
        
        NSString *postCopyOwnerNameString = [NSString string];
        
        if (post.copyOwnerID > 0) {
            
            postCopyOwnerNameString = [post.postCopyOwnerUser.firstName stringByAppendingFormat:@" %@", post.postCopyOwnerUser.lastName];
            
        } else {
            
            postCopyOwnerNameString = post.postCopyOwnerGroup.name;
        }
        
        CGRect postCopyOwnerNameRect = [OPPostDrawingCell countRectForSecondaryInfo:postCopyOwnerNameString];
        
        // copyPostDateString
        
        NSString *copyPostDateString = [OPPostDrawingCell findStringForDate:post.copyPostDate];
        CGRect copyPostDateRect = [OPPostDrawingCell countRectForSecondaryInfo:copyPostDateString];
        
        CGFloat postCopyOwnerHeight;
        
        if (self.post.copyOwnerID != 0) {
            
            // postCopyOwnerNameLabel
            
            postCopyOwnerHeight = ( (postCopyOwnerNameRect.size.height + copyPostDateRect.size.height) > postCopyOwnerImageHeight) ? (postCopyOwnerNameRect.size.height + copyPostDateRect.size.height) : postCopyOwnerImageHeight;
            
            CGRect postCopyOwnerNameFrame = CGRectMake(postOwnerImageWidth + 2 * offset + postCopyOwnerImageWidth + offset,
                                                       postCopyOwnerNameTopOffset,
                                                       postCopyOwnerNameRect.size.width,
                                                       postCopyOwnerNameRect.size.height);
            
            UILabel *postCopyOwnerNameLabel = [[UILabel alloc] initWithFrame:postCopyOwnerNameFrame];
            
            postCopyOwnerNameLabel.numberOfLines = 0;
            
            postCopyOwnerNameLabel.font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
            postCopyOwnerNameLabel.textColor = [UIColor purpleColor];
            
            postCopyOwnerNameLabel.text = postCopyOwnerNameString;
            
            [self addSubview:postCopyOwnerNameLabel];
            
            // copyPostDateLabel
            
            CGRect copyPostDateFrame = CGRectMake(postOwnerImageWidth + 2 * offset + postCopyOwnerImageWidth + offset,
                                                  postCopyOwnerNameTopOffset + postCopyOwnerNameRect.size.height + offset,
                                                  copyPostDateRect.size.width,
                                                  copyPostDateRect.size.height);
            
            UILabel *copyPostDateLabel = [[UILabel alloc] initWithFrame:copyPostDateFrame];
            
            copyPostDateLabel.numberOfLines = 0;
            
            copyPostDateLabel.font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
            copyPostDateLabel.textColor = [UIColor grayColor];
            
            copyPostDateLabel.text = copyPostDateString;
            
            [self addSubview:copyPostDateLabel];
            
            postCopyOwnerHeight += offset;
        }
        
        // postTextLabel
        
        CGFloat postTextTopOffset = postCopyOwnerNameTopOffset + postCopyOwnerHeight;
        
        CGRect postTextRect = [OPPostDrawingCell countRectForPostText:post.text];
        
        CGFloat postTextHeight = 0;
        
        if ([post.text length]) {
            
            CGRect postTextFrame = CGRectMake(postOwnerImageWidth + 2 * offset,
                                              postTextTopOffset,
                                              postTextRect.size.width,
                                              postTextRect.size.height);
            
            UILabel *postTextLabel = [[UILabel alloc] initWithFrame:postTextFrame];
            
            postTextLabel.numberOfLines = 0;
            postTextLabel.font = [UIFont systemFontOfSize:fontOfSize];
            postTextLabel.shadowColor = [UIColor whiteColor];
            postTextLabel.shadowOffset = CGSizeMake(1, 1);
            postTextLabel.textAlignment = NSTextAlignmentJustified;
            postTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            postTextLabel.text = post.text;
            
            [self addSubview:postTextLabel];
            
            postTextHeight = postTextRect.size.height + offset;
            
        }
        
        // attachment
        
        CGFloat attachmentTopOffset = postTextTopOffset + postTextHeight;
        
        CGFloat attachmentWidth;
        CGFloat attachmentHeight;
        
        if ([self.post.attachment count]) {
            
            attachmentHeight = [OPPostDrawingCell heightForAttachmentViewForPost:self.post];
            
            id attachment = [self.post.attachment firstObject];
            
            if ([attachment isKindOfClass:[OPAttachmentPhoto class]]) {
                
                OPAttachmentPhoto *attachmentPhoto = (OPAttachmentPhoto *)attachment;
                
                attachmentWidth = attachmentHeight * (float)attachmentPhoto.width / (float)attachmentPhoto.height;
                
            } else if ([attachment isKindOfClass:[OPAttachmentVideo class]]) {
                
                attachmentWidth = MIN(window.bounds.size.width - 3 * offset - postOwnerImageWidth, videoWidth);
                
            }
            
            CGRect attachmentFrame = CGRectMake(offset + postOwnerImageWidth + offset,
                                                attachmentTopOffset,
                                                attachmentWidth,
                                                attachmentHeight);
            
            self.attachmentImageView = [[UIImageView alloc] initWithFrame:attachmentFrame];
            
            [self addSubview:self.attachmentImageView];
            
        }
        
        // postDateLabel
        
        CGFloat postDateTopOffset = attachmentTopOffset + attachmentHeight + offset;
        
        NSString *postDateString = [OPPostDrawingCell findStringForDate:post.postDate];
        CGRect postDateRect = [OPPostDrawingCell countRectForSecondaryInfo:postDateString];
        
        CGRect postDateFrame = CGRectMake(postOwnerImageWidth + 2 * offset,
                                          postDateTopOffset,
                                          self.bounds.size.width - 2 * offset,
                                          postDateRect.size.height);
        
        UILabel *postDateLabel = [[UILabel alloc] initWithFrame:postDateFrame];
        
        postDateLabel.numberOfLines = 0;
        
        postDateLabel.font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
        postDateLabel.textColor = [UIColor brownColor];
        
        postDateLabel.text = postDateString;
        
        [self addSubview:postDateLabel];
        
        // likesLabel
        
        CGFloat likesTopOffset = postDateTopOffset + postDateRect.size.height;
        
        NSString *likesString = [NSString stringWithFormat:@"Лайки: %@", @(post.likesCount)];
        
        CGRect likesRect = [OPPostDrawingCell countRectForSecondaryInfo:likesString];
        
        CGRect likesFrame = CGRectMake(postOwnerImageWidth + 2 * offset,
                                       likesTopOffset,
                                       self.bounds.size.width/2 - 2 * offset,
                                       likesRect.size.height);
        
        UILabel *likesLabel = [[UILabel alloc] initWithFrame:likesFrame];
        
        likesLabel.font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
        likesLabel.textColor = [UIColor lightGrayColor];
        
        likesLabel.text = likesString;
        
        [self addSubview:likesLabel];
        
        // commentsLabel
        
        NSString *commentsString = [NSString stringWithFormat:@"Комментарии: %@", @(post.commentsCount)];
        
        CGRect commentsFrame = CGRectMake((self.bounds.size.width - postOwnerImageWidth - 2 * offset)/2,
                                          likesTopOffset,
                                          self.bounds.size.width/2 - 2 * offset,
                                          likesRect.size.height);
        
        UILabel *commentsLabel = [[UILabel alloc] initWithFrame:commentsFrame];
        
        commentsLabel.font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
        commentsLabel.textColor = [UIColor lightGrayColor];
        
        commentsLabel.text = commentsString;
        
        [self addSubview:commentsLabel];
        
    }
    return self;
    
}

#pragma mark - Private Methods
+ (CGRect) countRectForPostText:(NSString *)text {
    
    NSDictionary *attributes = [OPPostDrawingCell attributesForPostText];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(window.bounds.size.width - postOwnerImageWidth - 3 * offset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    return rect;
}

+ (CGRect) countRectForSecondaryInfo:(NSString *)text {
    
    NSMutableDictionary *dict = [[OPPostDrawingCell attributesForPostText] mutableCopy];
    
    UIFont *font = [UIFont systemFontOfSize:fontOfSizeForSecondary];
    [dict setValue:font forKey:NSForegroundColorAttributeName];
    
    NSDictionary *attributes = [dict copy];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(window.bounds.size.width - postOwnerImageWidth - postCopyOwnerImageWidth - 4 * offset, CGFLOAT_MAX) // учитываем отступы по горизонтали
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    return rect;
}

+ (NSDictionary *) attributesForPostText {
    
    UIFont *font = [UIFont systemFontOfSize:fontOfSize];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(1, 1);
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentJustified];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor grayColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                shadow, NSShadowAttributeName,
                                paragraph, NSParagraphStyleAttributeName, nil];
    return attributes;
}

+ (NSString *) findStringForDate:(NSInteger) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:date];
    
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *postDateString = [NSString string];
    
    if (date) {
        
        if ([[dateFormatter stringFromDate:postDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
            
            [dateFormatter setDateFormat:@"dd MMMM"];
            
            if ([[dateFormatter stringFromDate:postDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
                
                [dateFormatter setDateFormat:@"HH:mm"];
                
                postDateString = [NSString stringWithFormat:@"сегодня в %@", [dateFormatter stringFromDate:postDate]];
                
            } else {
                
                [dateFormatter setDateFormat:@"dd MMM HH:mm"];
                
                postDateString = [dateFormatter stringFromDate:postDate];
            }
            
        } else {
            
            [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm"];
            
            postDateString = [dateFormatter stringFromDate:postDate];
        }
        
    }
    
    return postDateString;
}

+ (CGFloat) heightForAttachmentViewForPost:(OPPost *) post {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    CGFloat attachmentWidth;
    CGFloat attachmentHeight;
    
    if ([post.attachment count]) {
        
        id attachment = [post.attachment firstObject];
        
        CGFloat width = window.bounds.size.width - postOwnerImageWidth - 3 * offset;
        
        if ([attachment isKindOfClass:[OPAttachmentPhoto class]]) {
            
            OPAttachmentPhoto *attachmentPhoto = (OPAttachmentPhoto *)attachment;
            
            attachmentWidth = MIN(width, (float)attachmentPhoto.width);
            attachmentHeight = attachmentWidth * (float)attachmentPhoto.height / (float)attachmentPhoto.width;
            
        } else if ([attachment isKindOfClass:[OPAttachmentVideo class]]) {
            
            attachmentWidth = MIN(width, videoWidth);
            attachmentHeight = attachmentWidth * videoHeight / videoWidth;
            
        }
        
    }
    
    return attachmentHeight;
}

+ (CGFloat) heightForPost:(OPPost *) post {
    
    NSString *postOwnerNameString = [NSString string];
    
    if (post.ownerID > 0) {
        
        postOwnerNameString = [post.postOwnerUser.firstName stringByAppendingFormat:@" %@", post.postOwnerUser.lastName];
        
    } else {
        
        postOwnerNameString = post.postOwnerGroup.name;
    }
    CGRect postOwnerNameRect = [self countRectForPostText:postOwnerNameString];
    
    NSString *postCopyOwnerNameString = [NSString string];
    
    if (post.copyOwnerID > 0) {
        
        postCopyOwnerNameString = [post.postCopyOwnerUser.firstName stringByAppendingFormat:@" %@", post.postCopyOwnerUser.lastName];
        
    } else {
        
        postCopyOwnerNameString = post.postCopyOwnerGroup.name;
    }
    CGRect postCopyOwnerNameRect = [self countRectForSecondaryInfo:postCopyOwnerNameString];
    
    NSString *copyPostDateString = [OPPostDrawingCell findStringForDate:post.copyPostDate];
    CGRect copyPostDateRect = [self countRectForSecondaryInfo:copyPostDateString];
    
    CGFloat postCopyOwnerHeight = 0;
    
    if ([postCopyOwnerNameString length] > 0) {
        
        postCopyOwnerHeight = ( (CGRectGetHeight(postCopyOwnerNameRect) + CGRectGetHeight(copyPostDateRect)) > postCopyOwnerImageHeight) ? (CGRectGetHeight(postCopyOwnerNameRect) + CGRectGetHeight(copyPostDateRect)) : postCopyOwnerImageHeight;
        
        postCopyOwnerHeight += offset;
        
    }
    
    CGRect postTextRect;
    CGFloat postTextHeight = 0;
    if ([post.text length]) {
        
        postTextRect = [self countRectForPostText:post.text];
        postTextHeight = CGRectGetHeight(postTextRect) + offset;
    }
    
    // attachmentHeight
    CGFloat attachmentHeight;
    if ([post.attachment count]) {
        attachmentHeight = [self heightForAttachmentViewForPost:post] + offset;
    }
    
    NSString *postDateString = [OPPostDrawingCell findStringForDate:post.postDate];
    CGRect postDateRect = [self countRectForSecondaryInfo:postDateString];
    
    NSString *likesString = [NSString stringWithFormat:@"Лайки: %@", @(post.likesCount)];
    CGRect likesRect = [self countRectForSecondaryInfo:likesString];
    
    return CGRectGetHeight(postOwnerNameRect) + 2 * offset + postCopyOwnerHeight + offset + postTextHeight + attachmentHeight + CGRectGetHeight(likesRect) + offset + CGRectGetHeight(postDateRect) + offset;
    
}

@end
