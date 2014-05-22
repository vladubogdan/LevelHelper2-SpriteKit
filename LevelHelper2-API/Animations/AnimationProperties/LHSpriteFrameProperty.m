//
//  LHSpriteFrameProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSpriteFrameProperty.h"
#import "LHSpriteFrame.h"

@implementation LHSpriteFrameProperty

-(void)loadDictionary:(NSDictionary *)dict{
    if(!dict)return;
    [super loadDictionary:dict];
 
    NSArray* framesInfo = [dict objectForKey:@"Frames"];
    for(NSDictionary* frmInfo in framesInfo)
    {
        LHSpriteFrame* frm = [LHSpriteFrame frameWithDictionary:frmInfo
                                                       property:self];
        [self addKeyFrame:frm];
    }
}
@end
