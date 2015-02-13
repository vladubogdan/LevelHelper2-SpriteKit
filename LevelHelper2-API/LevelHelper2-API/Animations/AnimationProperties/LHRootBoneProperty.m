//
//  LHRootBoneProperty.m
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 7/10/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHRootBoneProperty.h"

#import "LHBoneFrame.h"
#import "LHAnimation.h"
#import "LHBone.h"
#import "LHBoneNodes.h"

@implementation LHRootBoneProperty

-(void)loadDictionary:(NSDictionary *)dict{
    if(!dict)return;
    [super loadDictionary:dict];
    
    NSArray* framesInfo = [dict objectForKey:@"Frames"];
    for(NSDictionary* frmInfo in framesInfo)
    {
        LHBoneFrame* frm = [LHBoneFrame frameWithDictionary:frmInfo property:self];
        [self addKeyFrame:frm];
    }
}

@end
