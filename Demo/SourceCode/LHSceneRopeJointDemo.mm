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
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/ropeJointTest.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"ROPE JOINTS DEMO\nThe left most joint has a bigger z value then the sprites so its draw on top.\n\nThe right most joint can be cut - Make a line to cut it.\nWatch the console for didCutRopeJoint notification."];
    }
    
    return self;
}

-(void)didCutRopeJoint:(LHRopeJointNode *)joint
{
    NSLog(@"DID CUT ROPE JOINT %@", [joint name]);
}

#if TARGET_OS_IPHONE

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    [super mouseDown:theEvent];
}
#endif


@end
