//
//  MyScene.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene


+(id)scene{
    
    [[LHConfig sharedInstance] enableDebug];
    
    NSString* levelPath = @"levels/officerLevel.plist";
//    NSString* levelPath = @"levels/cameraTest.plist";
//    NSString* levelPath = @"levels/assetTestLevel.plist";
//    NSString* levelPath = @"levels/level01.plist";
//    NSString* levelPath = @"levels/level02-beziers.plist";
//    NSString* levelPath = @"levels/movementAnimationTest.plist";
//    NSString* levelPath = @"levels/parallaxTest.plist";
//    NSString* levelPath = @"levels/rectangleGravityArea.plist";
    
    return [[self alloc] initWithContentOfFile:levelPath];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];
    if(self){
        /*YOUR INITIALIZING CODE HERE*/
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    //DONT FORGET TO CALL SUPER
    [super touchesBegan:touches withEvent:event];
   
}

@end
