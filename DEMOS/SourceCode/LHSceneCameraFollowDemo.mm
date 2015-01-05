//
//  LHSceneCameraFollowDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCameraFollowDemo.h"

@implementation LHSceneCameraFollowDemo
{
    BOOL didChangeX;
}
+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/cameraFollowDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"CAMERA FOLLOW DEMO\nDemonstrate a camera following an object (the tire sprite).\nThe camera is restricted and cannot go outside the game world rectangle.\nNotice how on the sides the candy will no longer be in the center and the camera stops following it.\nThe blue sky is added to the Back User Interface so it will always be on screen in the back.\nThis text is added in the Front User Interface node, so it will always be on screen.\n\nClick to change the gravity direction."];
        
        
    }
    
    return self;
}

#if TARGET_OS_IPHONE

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint curGravity = [self globalGravity];
    if(didChangeX){
        [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
        didChangeX = false;
    }
    else{
        didChangeX = true;
        [self setGlobalGravity:CGPointMake(-curGravity.x, curGravity.y)];
    }
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint curGravity = [self globalGravity];
    if(didChangeX){
        [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
        didChangeX = false;
    }
    else{
        didChangeX = true;
        [self setGlobalGravity:CGPointMake(-curGravity.x, curGravity.y)];
    }
    
    [super mouseDown:theEvent];
}
#endif

@end
