//
//  LHSceneGravityAreas.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneGravityAreas.h"

@implementation LHSceneGravityAreas

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/gravityAreasDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"GRAVITY AREAS DEMO\nObjects inside the gravity areas will get a radial or directional velocity."];
        
    }
    
    return self;
}

@end
