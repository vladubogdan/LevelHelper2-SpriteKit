//
//  MyScene.h
//  SpriteKitAPI-DEVELOPMENT
//

//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LevelHelper2API.h"

@interface LHSceneDemo : LHScene

+(id)scene;

-(void)nextDemo;
-(void)previousDemo;

+(void)createMultilineLabelAtPosition:(CGPoint)labelPosition
                        asChildOfNode:(SKNode*)parent
                             withText:(NSString*)text;

@end
