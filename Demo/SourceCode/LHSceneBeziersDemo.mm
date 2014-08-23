//
//  LHSceneBeziersDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneBeziersDemo.h"

@implementation LHSceneBeziersDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/beziersDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"BEZIERS DEMO\nBeziers can be used to draw line shapes.\nBy disabling control points you can have part of the bezier as a straight line.\nIn LevelHelper, select a bezier and hold control to edit it.Right click to toggle control points.\nYou can draw the outline of a shape using beziers and then make that outline into a shape."];
        
    }
    
    return self;
}

@end
