//
//  OPCommentCell.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 22.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPCommentCell.h"

#import "OPComment.h"
#import "OPUser.h"
#import "OPGroup.h"

@implementation OPCommentCell

static CGFloat offset = 5.0;

static CGFloat sizeOfFont = 14.0;
static CGFloat sizeOfDateFont = 12.0;

static CGFloat ownerImageWidth = 40.0;
static CGFloat ownerImageHeight = 40.0;

#pragma mark - Private Methods

- (id)initWithComment:(OPComment *) comment cellHeight:(CGFloat) cellHeight reuseIdentifier:(NSString *) identifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    if (self) {
        
        UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        CGFloat windowWidth = window.bounds.size.width;
        
        UIFont *textFont = [UIFont systemFontOfSize:sizeOfFont];
        UIFont *nameFont = [UIFont boldSystemFontOfSize:sizeOfFont];
        UIFont *dateFont = [UIFont systemFontOfSize:sizeOfDateFont];
        
        // layoutView
        self.layoutView.frame = CGRectMake(0,
                                           0,
                                           windowWidth,
                                           cellHeight);
        
        // ownerImageView
        self.ownerImageView.frame = CGRectMake(offset,
                                               offset,
                                               ownerImageWidth,
                                               ownerImageHeight);
        
        // commentContentView
        CGFloat commentContentViewLeftOffset = offset + ownerImageWidth + offset;
        
        CGFloat commentContentViewWidth = windowWidth - (commentContentViewLeftOffset + offset);
        
        self.commentContentView.frame = CGRectMake(0,
                                                   offset,
                                                   commentContentViewWidth,
                                                   cellHeight - 2 * offset);
        
        // ownerNameLabel
        NSString *ownerName = [NSString string];
        
        if (comment.ownerID > 0) {
            
            ownerName = [comment.userAsOwner.firstName stringByAppendingFormat:@" %@", comment.userAsOwner.lastName];
            
        } else {
            
            ownerName = comment.groupAsOwner.name;
        }
        
        CGRect ownerNameRect = [OPCommentCell countRectForText:ownerName
                                                      forWidth:commentContentViewWidth
                                                       forFont:nameFont];
        
        self.ownerNameLabel.frame = CGRectMake(0,
                                               0,
                                               commentContentViewWidth,
                                               ownerNameRect.size.height);
        
        // commentTextLabel
        CGRect commentTextRect = [OPCommentCell countRectForText:comment.text
                                                        forWidth:commentContentViewWidth
                                                         forFont:textFont];
        
        self.commentTextLabel.frame = CGRectMake(0,
                                                 ownerNameRect.size.height + offset,
                                                 commentContentViewWidth,
                                                 commentTextRect.size.height);
        
        // dateLabel
        NSString *date = [OPCommentCell findStringForDate:comment.date];
        
        CGRect dateRect = [OPCommentCell countRectForText:date
                                                 forWidth:commentContentViewWidth
                                                  forFont:dateFont];
        
        self.dateLabel.frame = CGRectMake(0,
                                          ownerNameRect.size.height + offset + commentTextRect.size.height + offset,
                                          commentContentViewWidth,
                                          dateRect.size.height);
        
        // all texts for labels
        self.ownerNameLabel.text = ownerName;
        
        self.commentTextLabel.text = comment.text;
        self.commentTextLabel.textAlignment = NSTextAlignmentJustified;
        
        self.dateLabel.text = date;

    }
    
    return self;
}

- (void) countAllFramesForComment:(OPComment *) comment cellHeight:(CGFloat) cellHeight {
    
    self.comment = comment;
    self.cellHeight = cellHeight;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    CGFloat windowWidth = window.bounds.size.width;
    
    UIFont *textFont = [UIFont systemFontOfSize:sizeOfFont];
    UIFont *nameFont = [UIFont boldSystemFontOfSize:sizeOfFont];
    UIFont *dateFont = [UIFont systemFontOfSize:sizeOfDateFont];
    
    // layoutView
    self.layoutView.frame = CGRectMake(0,
                                       0,
                                       windowWidth,
                                       self.cellHeight);
    
    // ownerImageView
    self.ownerImageView.frame = CGRectMake(offset,
                                           offset,
                                           ownerImageWidth,
                                           ownerImageHeight);
    
    // commentContentView
    CGFloat commentContentViewLeftOffset = offset + ownerImageWidth + offset;
    
    CGFloat commentContentViewWidth = windowWidth - (commentContentViewLeftOffset + offset);
    
    self.commentContentView.frame = CGRectMake(commentContentViewLeftOffset,
                                               offset,
                                               commentContentViewWidth,
                                               self.cellHeight - 2 * offset);
    
    // ownerNameLabel
    NSString *ownerName = [NSString string];
    
    if (self.comment.ownerID > 0) {
        
        ownerName = [self.comment.userAsOwner.firstName stringByAppendingFormat:@" %@", self.comment.userAsOwner.lastName];
        
    } else {
        
        ownerName = self.comment.groupAsOwner.name;
    }
    
    CGRect ownerNameRect = [OPCommentCell countRectForText:ownerName
                                                  forWidth:commentContentViewWidth
                                                   forFont:nameFont];
    
    self.ownerNameLabel.frame = CGRectMake(0,
                                           0,
                                           commentContentViewWidth,
                                           ownerNameRect.size.height);
    
    // commentTextLabel
    CGRect commentTextRect = [OPCommentCell countRectForText:self.comment.text
                                                    forWidth:commentContentViewWidth
                                                     forFont:textFont];
    
    self.commentTextLabel.frame = CGRectMake(0,
                                             ownerNameRect.size.height + offset,
                                             commentContentViewWidth,
                                             commentTextRect.size.height);
    
    // dateLabel
    NSString *date = [OPCommentCell findStringForDate:self.comment.date];
    
    CGRect dateRect = [OPCommentCell countRectForText:date
                                             forWidth:commentContentViewWidth
                                              forFont:dateFont];
    
    self.dateLabel.frame = CGRectMake(0,
                                      ownerNameRect.size.height + offset + commentTextRect.size.height + offset,
                                      commentContentViewWidth,
                                      dateRect.size.height);
    
    // all texts for labels
    self.ownerNameLabel.text = ownerName;
    self.ownerNameLabel.textColor = [UIColor brownColor];
    
    self.commentTextLabel.text = self.comment.text;
    self.commentTextLabel.textAlignment = NSTextAlignmentJustified;
    
    self.dateLabel.text = date;
    self.dateLabel.textColor = [UIColor lightGrayColor];
    
}

+ (CGFloat) heightForComment:(OPComment *) comment {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    CGFloat windowWidth = window.bounds.size.width;
    
    UIFont *textFont = [UIFont systemFontOfSize:sizeOfFont];
    UIFont *nameFont = [UIFont boldSystemFontOfSize:sizeOfFont];
    UIFont *dateFont = [UIFont systemFontOfSize:sizeOfDateFont];
    
    CGFloat heightForComment = offset;
    
    // ownerName
    NSString *ownerName = [NSString string];
    
    if (comment.ownerID > 0) {
        
        ownerName = [comment.userAsOwner.firstName stringByAppendingFormat:@" %@", comment.userAsOwner.lastName];
        
    } else {
        
        ownerName = comment.groupAsOwner.name;
    }
    
    CGFloat ownerNameRectWidth = windowWidth - (offset + ownerImageWidth + offset + offset);
    
    CGRect ownerNameRect = [OPCommentCell countRectForText:ownerName
                                                  forWidth:ownerNameRectWidth
                                                   forFont:nameFont];
    
    heightForComment += ownerNameRect.size.height + offset; // или CGRectGetHeight(ownerNameRect)
    
    // commentText
    CGRect commentTextRect = [OPCommentCell countRectForText:comment.text
                                                    forWidth:ownerNameRectWidth
                                                     forFont:textFont];
    
    heightForComment += CGRectGetHeight(commentTextRect) + offset;
    
    // date
    NSString *date = [OPCommentCell findStringForDate:comment.date];
    
    CGRect dateRect = [OPCommentCell countRectForText:date
                                                    forWidth:ownerNameRectWidth
                                                     forFont:dateFont];
    
    heightForComment += CGRectGetHeight(dateRect) + offset;
    
    return heightForComment;
}

+ (CGRect) countRectForText:(NSString *) text forWidth:(CGFloat) width forFont:(UIFont *) font {
    
    NSDictionary *attributes = [OPCommentCell attributesForTextWithFont:font];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect;
}

+ (NSDictionary *) attributesForTextWithFont:(UIFont *) font {
    
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

+ (NSString *) findStringForDate:(NSInteger) timeInterval {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    [dateFormatter setDateFormat:@"yyyy"];
    
    NSString *aDateString = [NSString string];
    
    if (timeInterval) {
        
        if ([[dateFormatter stringFromDate:aDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
            
            [dateFormatter setDateFormat:@"dd MMMM"];
            
            if ([[dateFormatter stringFromDate:aDate] isEqualToString:[dateFormatter stringFromDate:currentDate]]) {
                
                [dateFormatter setDateFormat:@"HH:mm"];
                
                aDateString = [NSString stringWithFormat:@"сегодня в %@", [dateFormatter stringFromDate:aDate]];
                
            } else {
                
                [dateFormatter setDateFormat:@"dd MMM HH:mm"];
                
                aDateString = [dateFormatter stringFromDate:aDate];
            }
            
        } else {
            
            [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm"];
            
            aDateString = [dateFormatter stringFromDate:aDate];
        }
        
    }
    
    return aDateString;
}

@end
