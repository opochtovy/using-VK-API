//
//  OPPostCell.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPPostCell.h"

@implementation OPPostCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// that method counts height for each cell
+ (CGFloat) heightForText:(NSString *)text {
    
    CGFloat offset = 10.0;
    
    UIFont *font = [UIFont systemFontOfSize:17.f];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                paragraph, NSParagraphStyleAttributeName,
                                shadow, NSShadowAttributeName, nil];
    
    CGRect postTextRect = [text boundingRectWithSize:CGSizeMake(320 - 2 * offset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    CGRect likesRect = [@"Likes" boundingRectWithSize:CGSizeMake(320 - 2 * offset, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attributes
                                          context:nil];
    
//    CGRect postDateRect = likesRect;
    
    return CGRectGetHeight(postTextRect) + 2 * offset + 2 * CGRectGetHeight(likesRect) + 2 * offset;
    
}

@end
