//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneRopeJointDemo.h"

@implementation LHSceneRopeJointDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/ropeJointTest.plist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"ROPE JOINTS DEMO\nThe left most joint has a bigger z value then the sprites so its draw on top.\n\nThe right most joint can be cut - Make a line to cut it."];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    CGPoint gravity = [self globalGravity];
//    NSLog(@"Changing gravity direction %f %f.", gravity.x, gravity.y);
//    [self setGlobalGravity:CGPointMake(gravity.x, -gravity.y)];
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}
@end
