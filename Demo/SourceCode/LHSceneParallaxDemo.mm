//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneParallaxDemo.h"

@implementation LHSceneParallaxDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/parallaxDemo.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"PARALLAX DEMO\nDemonstrate using a parallax to give an illusion of depth.\nThe camera is following the tire sprite.\nThe parallax is following the camera.\nEach layer in the parallax has a different movement ratio making them move at different speeds.\nLayers in the back move slower then layer in the front.\nThe blue sky is added to the Back User Interface so it will always be on screen in the back.\nThis text is added in the Front User Interface node, so it will always be on screen."];
        
    }
    
    return self;
}

@end
