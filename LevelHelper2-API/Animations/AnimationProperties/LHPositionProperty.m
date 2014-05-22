//
//  LHPositionProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHPositionProperty.h"
#import "LHPositionFrame.h"

@implementation LHPositionProperty

-(void)loadDictionary:(NSDictionary *)dict{
    if(!dict)return;
    [super loadDictionary:dict];
    
    NSArray* framesInfo = [dict objectForKey:@"Frames"];
    for(NSDictionary* frmInfo in framesInfo)
    {
        LHPositionFrame* frm = [LHPositionFrame frameWithDictionary:frmInfo
                                                           property:self];
        [self addKeyFrame:frm];
    }
}

@end
