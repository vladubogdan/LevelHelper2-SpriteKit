//
//  LHBoneFrame.h
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 7/10/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHFrame.h"

@interface LHBoneFrameInfo : NSObject

-(float)rotation;
-(void)setRotation:(float)rot;
-(CGPoint)position;
-(void)setPosition:(CGPoint)pt;

@end

@interface LHBoneFrame : LHFrame

-(LHBoneFrameInfo*)boneFrameInfoForBoneNamed:(NSString*)nm;

@end
