//
//  OPCommentCell.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 22.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPComment;

@interface OPCommentCell : UITableViewCell

@property (strong, nonatomic) OPComment *comment;
@property (assign, nonatomic) CGFloat cellHeight;

@property (weak, nonatomic) IBOutlet UIView *layoutView;

@property (weak, nonatomic) IBOutlet UIImageView *ownerImageView;

@property (weak, nonatomic) IBOutlet UIView *commentContentView;

@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (id)initWithComment:(OPComment *) comment cellHeight:(CGFloat) cellHeight reuseIdentifier:(NSString *) identifier;

- (void) countAllFramesForComment:(OPComment *) comment cellHeight:(CGFloat) cellHeight;

+ (CGFloat) heightForComment:(OPComment *) comment;

+ (CGRect) countRectForText:(NSString *) text forWidth:(CGFloat) width forFont:(UIFont *) font;

+ (NSString *) findStringForDate:(NSInteger) timeInterval;

@end
