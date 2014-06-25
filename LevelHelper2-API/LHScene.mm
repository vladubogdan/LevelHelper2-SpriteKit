//
//  LHScene.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHShape.h"
#import "LHWater.h"
#import "LHNode.h"
#import "LHAsset.h"
#import "LHGravityArea.h"
#import "LHParallax.h"
#import "LHParallaxLayer.h"
#import "LHCamera.h"
#import "LHRopeJointNode.h"
#import "LHWeldJointNode.h"
#import "LHRevoluteJointNode.h"
#import "LHDistanceJointNode.h"
#import "LHPrismaticJointNode.h"
#import "LHGameWorldNode.h"
#import "LHUINode.h"


@implementation LHScene
{
    __unsafe_unretained LHGameWorldNode*    _gameWorldNode;
    __unsafe_unretained LHUINode*           _uiNode;
    
    
    NSMutableArray* lateLoadingNodes;//gets nullified after everything is loaded
    

    LHNodeProtocolImpl*         _nodeProtocolImp;
    
    
    
    NSMutableDictionary* loadedTextures;
    NSMutableDictionary* loadedTextureAtlases;
    NSDictionary* tracedFixtures;
    
    NSArray* supportedDevices;
    CGSize  designResolutionSize;
    CGPoint designOffset;
    
    NSString* relativePath;
    
    SKNode* touchedNode;
    BOOL touchedNodeWasDynamic;
    
    CGPoint ropeJointsCutStartPt;
    
    NSMutableDictionary* _loadedAssetsInformations;
    
    CGRect gameWorldRect;
    NSMutableArray* cameras;
    
    NSTimeInterval previousUpdateTime;
}


-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(relativePath);
    LH_SAFE_RELEASE(loadedTextures);
    LH_SAFE_RELEASE(loadedTextureAtlases);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(supportedDevices);
    LH_SAFE_RELEASE(cameras);
    LH_SAFE_RELEASE(_loadedAssetsInformations);
    
    LH_SUPER_DEALLOC();
}

#if TARGET_OS_IPHONE
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile]);
}
#else
+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile size:size]);
}
#endif


#if TARGET_OS_IPHONE
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile
#else
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile size:(CGSize)size
#endif
{
    
#if TARGET_OS_IPHONE
#else
    NSLog(@"Please note that support for Mac OS platform is partial. Some key elements are missing from SpriteKit on OS X SDK. When Apple updates the SDK i will be able to give full support.");
#endif
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:[levelPlistFile stringByDeletingPathExtension]
                                                     ofType:[levelPlistFile pathExtension]];
    if(!path)return nil;
    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!dict)return nil;

    int aspect = [dict intForKey:@"aspect"];
    CGSize designResolution = [dict sizeForKey:@"designResolution"];

    NSArray* devsInfo = [dict objectForKey:@"devices"];
    NSMutableArray* devices = [NSMutableArray array];
    for(NSDictionary* devInf in devsInfo){
        LHDevice* dev = [LHDevice deviceWithDictionary:devInf];
        [devices addObject:dev];
    }

    #if TARGET_OS_IPHONE
    LHDevice* curDev = [LHUtils currentDeviceFromArray:devices];
    #else
    LHDevice* curDev = [LHUtils deviceFromArray:devices withSize:size];
    #endif

    CGPoint childrenOffset = CGPointZero;
    
    CGSize sceneSize = curDev.size;
    float ratio = curDev.ratio;
    sceneSize.width = sceneSize.width/ratio;
    sceneSize.height = sceneSize.height/ratio;
    
    SKSceneScaleMode scaleMode = SKSceneScaleModeFill;
    if(aspect == 0)//exact fit
    {
        sceneSize = designResolution;
    }
    else if(aspect == 1)//no borders
    {
        float scalex = sceneSize.width/designResolution.width;
        float scaley = sceneSize.height/designResolution.height;
        scalex = scaley = MAX(scalex, scaley);
        
        childrenOffset.x = (sceneSize.width/scalex - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height/scaley - designResolution.height)*0.5;
        sceneSize = CGSizeMake(sceneSize.width/scalex, sceneSize.height/scaley);
        
        scaleMode = SKSceneScaleModeAspectFill;
    }
    else if(aspect == 2)//show all
    {
        childrenOffset.x = (sceneSize.width - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height - designResolution.height)*0.5;
    }


    if (self = [super initWithSize:sceneSize])
    {
        relativePath = [[NSString alloc] initWithString:[levelPlistFile stringByDeletingLastPathComponent]];
        
        designResolutionSize = designResolution;
        designOffset         = childrenOffset;
        self.scaleMode       = scaleMode;
        
        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }
        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        if([dict boolForKey:@"useGlobalGravity"])
        {
            //more or less the same as box2d
            CGPoint gravityVector = [dict pointForKey:@"globalGravityDirection"];
            float gravityForce    = [dict floatForKey:@"globalGravityForce"];
            
            CGPoint gravity = CGPointMake(gravityVector.x*gravityForce,
                                          gravityVector.y*gravityForce);
            [self setGlobalGravity:gravity];
        }
        
        
        [self setBackgroundColor:[dict colorForKey:@"backgroundColor"]];
        
        
        
        
        
        NSDictionary* phyBoundInfo = [dict objectForKey:@"physicsBoundaries"];
        if(phyBoundInfo)
        {
#if TARGET_OS_IPHONE
            CGSize scr = LH_SCREEN_RESOLUTION;
#else
            CGSize scr = self.size;
#endif
            NSString* rectInf = [phyBoundInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
            if(!rectInf){
                rectInf = [phyBoundInfo objectForKey:@"general"];
            }
            
            if(rectInf){
//                CGRect bRect = LHRectFromString(rectInf);
//                CGSize designSize = [self designResolutionSize];
//                CGPoint offset = [self designOffset];
//                offset.y -= self.size.height;
//                CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
//                                            (1.0f - bRect.origin.y)*designSize.height + offset.y,
//                                            bRect.size.width*designSize.width ,
//                                            -(bRect.size.height)*designSize.height);

                
                CGRect bRect = LHRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];
                CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
                                            self.size.height - bRect.origin.y*designSize.height + offset.y,
                                            bRect.size.width*designSize.width ,
                                            -bRect.size.height*designSize.height);

                
                
//                [self gameWorldNode].physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:skBRect];
//                [self gameWorldNode].physicsBody.dynamic = NO;

                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                                        to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                                  withName:@"LHPhysicsBottomBoundary"];
                }
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                                        to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                                  withName:@"LHPhysicsRightBoundary"];
                    
                }
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                                        to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                                  withName:@"LHPhysicsTopBoundary"];
                }
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                                        to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                                  withName:@"LHPhysicsLeftBoundary"];
                }

                
                #if LH_DEBUG
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = CGPathCreateWithRect(skBRect,
                                                               nil);
                    debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:1];
                    [[self gameWorldNode] addChild:debugShapeNode];
                #endif
            }
        }
        

        NSDictionary* gameWorldInfo = [dict objectForKey:@"gameWorld"];
        if(gameWorldInfo)
        {
#if TARGET_OS_IPHONE
            CGSize scr = LH_SCREEN_RESOLUTION;
#else
            CGSize scr = self.size;
#endif

            NSString* rectInf = [gameWorldInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
            if(!rectInf){
                rectInf = [gameWorldInfo objectForKey:@"general"];
            }
            
            if(rectInf){
                CGRect bRect = LHRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];

                gameWorldRect = CGRectMake(bRect.origin.x*designSize.width+ offset.x,
                                           (1.0f - bRect.origin.y)*designSize.height + offset.y,
                                           bRect.size.width*designSize.width ,
                                           -(bRect.size.height)*designSize.height);
                gameWorldRect.origin.y -= sceneSize.height;
                
#if LH_DEBUG
                    CGRect gameWorldRectT = gameWorldRect;
                    gameWorldRectT.origin.x += 2;
                    gameWorldRectT.size.width -= 4;
                    gameWorldRectT.origin.y -= 2;
                    gameWorldRectT.size.height += 4;
                    
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = CGPathCreateWithRect(gameWorldRectT,nil);
                    
                    debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];
                    [[self gameWorldNode] addChild:debugShapeNode];
#endif
            }
        }
        
        [self performLateLoading];
    }
    return self;
}

-(void)performLateLoading{
    if(!lateLoadingNodes)return;
    
    NSMutableArray* lateLoadingToRemove = [NSMutableArray array];
    for(SKNode* node in lateLoadingNodes){
        if([node respondsToSelector:@selector(lateLoading)]){
            if([(id<LHNodeProtocol>)node lateLoading]){
                [lateLoadingToRemove addObject:node];
            }
        }
    }
    [lateLoadingNodes removeObjectsInArray:lateLoadingToRemove];
    if([lateLoadingNodes count] == 0){
        LH_SAFE_RELEASE(lateLoadingNodes);
    }
}

-(void)createPhysicsBoundarySectionFrom:(CGPoint)from
                                     to:(CGPoint)to
                               withName:(NSString*)sectionName
{
//    SKShapeNode* drawNode = [SKShapeNode node];
//    [self addChild:drawNode];
//    [drawNode setZPosition:100];
//    [drawNode setName:sectionName];
    
//#ifndef NDEBUG
//    [drawNode drawSegmentFrom:from
//                           to:to
//                       radius:1
//                        color:[CCColor redColor]];
//#endif
    
#if LH_USE_BOX2D
    
    float PTM_RATIO = [self ptm];
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    b2Body* physicsBoundariesBody = [self box2dWorld]->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2EdgeShape groundBox;
    
    // top
    groundBox.Set(b2Vec2(from.x/PTM_RATIO,
                         from.y/PTM_RATIO),
                  b2Vec2(to.x/PTM_RATIO,
                         to.y/PTM_RATIO));
    physicsBoundariesBody->CreateFixture(&groundBox,0);
    
    
#else //spritekit
//    SKShapeNode* drawNode = [SKShapeNode node];
//    [self addChild:drawNode];
//    [drawNode setZPosition:100];
//    [drawNode setName:sectionName];
    
    
//    CCPhysicsBody* boundariesBody = [CCPhysicsBody bodyWithPillFrom:from to:to cornerRadius:0];
//    [boundariesBody setType:CCPhysicsBodyTypeStatic];
//    [drawNode setPhysicsBody:boundariesBody];
#endif
    
}



-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath
{
    if(!loadedTextureAtlases){
        loadedTextureAtlases = [[NSMutableDictionary alloc] init];
    }
 
    SKTextureAtlas* textureAtlas = nil;
    if(atlasPath){
        textureAtlas = [loadedTextureAtlases objectForKey:atlasPath];
        if(!textureAtlas){
            textureAtlas = [SKTextureAtlas atlasNamed:atlasPath];
            if(textureAtlas){
                [loadedTextureAtlases setObject:textureAtlas forKey:atlasPath];
            }
        }
    }
    
    return textureAtlas;
}

-(SKTexture*)textureWithImagePath:(NSString*)imagePath
{
    if(!loadedTextures){
        loadedTextures = [[NSMutableDictionary alloc] init];
    }
    
    SKTexture* texture = nil;
    if(imagePath){
        texture = [loadedTextures objectForKey:imagePath];
        if(!texture){
            texture = [SKTexture textureWithImageNamed:imagePath];
            if(texture){
                [loadedTextures setObject:texture forKey:imagePath];
            }
        }
    }
    
    return texture;
}

-(CGRect)gameWorldRect{
    return gameWorldRect;
}

-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName{
    if(!_loadedAssetsInformations){
        _loadedAssetsInformations = [[NSMutableDictionary alloc] init];
    }
    NSDictionary* info = [_loadedAssetsInformations objectForKey:assetFileName];
    if(!info){
        NSString* path = [[NSBundle mainBundle] pathForResource:assetFileName
                                                         ofType:@"plist"
                                                    inDirectory:[self relativePath]];
        if(path){
            info = [NSDictionary dictionaryWithContentsOfFile:path];
            if(info){
                [_loadedAssetsInformations setObject:info forKey:assetFileName];
            }
        }
    }
    return info;
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
//    CGVector grv = self.physicsWorld.gravity;
//    
//    [self.physicsWorld setGravity:CGVectorMake(grv.dx,
//                                              -grv.dy)];
//    
//    return;
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        ropeJointsCutStartPt = location;
        
//        NSArray* foundNodes = [self nodesAtPoint:location];
//        for(SKNode* foundNode in foundNodes)
//        {
//            if(foundNode.physicsBody){
//                touchedNode = foundNode;
//                touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
//                [touchedNode.physicsBody setAffectedByGravity:NO];                
//                return;
//            }
//        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//
//        if(touchedNode && touchedNode.physicsBody){
//            [touchedNode setPosition:location];
//        }
//    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        for(LHRopeJointNode* rope in [self childrenOfType:[LHRopeJointNode class]]){
            if([rope canBeCut]){
                [rope cutWithLineFromPointA:ropeJointsCutStartPt
                                   toPointB:location];
            }
        }
    }
    
    
    
//    if(touchedNode){
//    [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
//    touchedNode = nil;
//    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    if(touchedNode){
//    touchedNode.physicsBody.affectedByGravity = touchedNodeWasDynamic;
//    touchedNode = nil;
//    }
}
#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    ropeJointsCutStartPt = location;
    NSArray* foundNodes = [self nodesAtPoint:location];
    for(SKNode* foundNode in foundNodes)
    {
        if(foundNode.physicsBody){
            touchedNode = foundNode;
            touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
            [touchedNode.physicsBody setAffectedByGravity:NO];
            break;
        }
    }
    
    BOOL                dragActive = YES;
    NSEvent*            event = NULL;
    NSWindow            *targetWindow = [[NSApplication sharedApplication] mainWindow];
    
    while (dragActive) {
        event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                          untilDate:[NSDate distantFuture]
                                             inMode:NSEventTrackingRunLoopMode
                                            dequeue:YES];
        if(!event){
            continue;
        }
        switch ([event type])
        {
            case NSLeftMouseDragged:
            {
                CGPoint curLocation = [event locationInNode:self];
                
                if(touchedNode && touchedNode.physicsBody){
                    [touchedNode setPosition:curLocation];
                }
            }
                break;
                
                
            case NSLeftMouseUp:
                dragActive = NO;
                
                CGPoint curLocation = [event locationInNode:self];
                for(LHRopeJointNode* rope in ropeJoints){
                    if([rope canBeCut]){
                        [rope cutWithLineFromPointA:ropeJointsCutStartPt
                                           toPointB:curLocation];
                    }
                }
                
                if(touchedNode){
                    [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
                    touchedNode = nil;
                }
                
                break;
                
            default:
                break;
        }
    }
}
#endif

-(LHGameWorldNode*)gameWorldNode
{
    if(!_gameWorldNode){
        for(SKNode* n in [self children]){
            if([n isKindOfClass:[LHGameWorldNode class]]){
                _gameWorldNode = (LHGameWorldNode*)n;
                break;
            }
        }
    }
    return _gameWorldNode;
}
-(LHUINode*)uiNode{
    if(!_uiNode){
        for(SKNode* n in [self children]){
            if([n isKindOfClass:[LHUINode class]]){
                _uiNode = (LHUINode*)n;
                break;
            }
        }
    }
    return _uiNode;
}

-(LHScene*)scene{
    return self;
}


- (void)update:(NSTimeInterval)currentTime{
   
    [self performLateLoading];
    
    if(previousUpdateTime == 0){
        previousUpdateTime = currentTime;
    }

    [self update:currentTime
           delta:currentTime - previousUpdateTime];
    
    [super update:currentTime];
    
    previousUpdateTime = currentTime;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

-(void)update:(NSTimeInterval)currentTime delta:(float)dt{
    [_nodeProtocolImp update:currentTime delta:dt];
}


#pragma mark - BOX2D INTEGRATION

#if LH_USE_BOX2D
-(b2World*)box2dWorld{
    return [[self gameWorldNode] box2dWorld];
}
-(float)ptm{
    return 32.0f;
}
-(b2Vec2)metersFromPoint:(CGPoint)point{
    return b2Vec2(point.x/[self ptm], point.y/[self ptm]);
}
-(CGPoint)pointFromMeters:(b2Vec2)vec{
    return CGPointMake(vec.x*[self ptm], vec.y*[self ptm]);
}
-(float)metersFromValue:(float)val{
    return val/[self ptm];
}
-(float)valueFromMeters:(float)meter{
    return meter*[self ptm];
}
#endif //LH_USE_BOX2D

-(CGPoint)globalGravity{
    return [[self gameWorldNode] gravity];
}
-(void)setGlobalGravity:(CGPoint)gravity{
    [[self gameWorldNode] setGravity:gravity];
}


@end

















#pragma mark - PRIVATE CATEGORY

@implementation LHScene (LH_SCENE_NODES_PRIVATE_UTILS)

+(id)createLHNodeWithDictionary:(NSDictionary*)childInfo
                         parent:(SKNode*)prnt
{
    
    NSString* nodeType = [childInfo objectForKey:@"nodeType"];
    
    LHScene* scene = nil;
    if([prnt isKindOfClass:[LHScene class]]){
        scene = (LHScene*)prnt;
    }
    else if([[prnt scene] isKindOfClass:[LHScene class]]){
        scene = (LHScene*)[prnt scene];
    }

    if([nodeType isEqualToString:@"LHGameWorldNode"])
    {
        LHGameWorldNode* pNode = [LHGameWorldNode gameWorldNodeWithDictionary:childInfo
                                                                       parent:prnt];
        
        //[pNode setDebugDraw:YES];
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHUINode"])
    {
        LHUINode* pNode = [LHUINode uiNodeWithDictionary:childInfo
                                                  parent:prnt];
        return pNode;
    }
    if([nodeType isEqualToString:@"LHSprite"])
    {
        LHSprite* spr = [LHSprite spriteNodeWithDictionary:childInfo
                                                    parent:prnt];
        return spr;
    }
    else if([nodeType isEqualToString:@"LHNode"])
    {
        LHNode* nd = [LHNode nodeWithDictionary:childInfo
                                         parent:prnt];
        return nd;
    }
    else if([nodeType isEqualToString:@"LHBezier"])
    {
        LHBezier* bez = [LHBezier bezierNodeWithDictionary:childInfo
                                                    parent:prnt];
        return bez;
    }
    else if([nodeType isEqualToString:@"LHTexturedShape"])
    {
        LHShape* sp = [LHShape shapeNodeWithDictionary:childInfo
                                                parent:prnt];
        return sp;
    }
    else if([nodeType isEqualToString:@"LHWaves"])
    {
        LHWater* wt = [LHWater waterNodeWithDictionary:childInfo
                                                parent:prnt];
        return wt;
    }
    else if([nodeType isEqualToString:@"LHAreaGravity"])
    {
        LHGravityArea* gv = [LHGravityArea gravityAreaWithDictionary:childInfo
                                                              parent:prnt];
        return gv;
    }
    else if([nodeType isEqualToString:@"LHParallax"])
    {
        LHParallax* pr = [LHParallax parallaxWithDictionary:childInfo
                                                     parent:prnt];
        return pr;
    }
    else if([nodeType isEqualToString:@"LHParallaxLayer"])
    {
        LHParallaxLayer* lh = [LHParallaxLayer parallaxLayerWithDictionary:childInfo
                                                                    parent:prnt];
        return lh;
    }
    else if([nodeType isEqualToString:@"LHAsset"])
    {
        LHAsset* as = [LHAsset assetWithDictionary:childInfo
                                            parent:prnt];
        return as;
    }
    else if([nodeType isEqualToString:@"LHCamera"])
    {
        LHCamera* cm = [LHCamera cameraWithDictionary:childInfo
                                                scene:prnt];
        return cm;
    }
    else if([nodeType isEqualToString:@"LHRopeJoint"])
    {
        if(scene)
        {
            LHRopeJointNode* jt = [LHRopeJointNode ropeJointNodeWithDictionary:childInfo
                                                                        parent:prnt];
            [scene addLateLoadingNode:jt];
        }
    }
    else if([nodeType isEqualToString:@"LHWeldJoint"])
    {
        LHWeldJointNode* jt = [LHWeldJointNode weldJointNodeWithDictionary:childInfo
                                                                    parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHRevoluteJoint"]){
        
        LHRevoluteJointNode* jt = [LHRevoluteJointNode revoluteJointNodeWithDictionary:childInfo
                                                                                parent:prnt];

        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHDistanceJoint"]){
        
        LHDistanceJointNode* jt = [LHDistanceJointNode distanceJointNodeWithDictionary:childInfo
                                                                                parent:prnt];
        [scene addLateLoadingNode:jt];

    }
    else if([nodeType isEqualToString:@"LHPrismaticJoint"]){
        
        LHPrismaticJointNode* jt = [LHPrismaticJointNode prismaticJointNodeWithDictionary:childInfo
                                                                                   parent:prnt];
        [scene addLateLoadingNode:jt];
    }


    else{
//        NSLog(@"UNKNOWN NODE TYPE %@", nodeType);
    }
    
    return nil;
}


-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)addLateLoadingNode:(SKNode*)node{
    if(!lateLoadingNodes) {
        lateLoadingNodes = [[NSMutableArray alloc] init];
    }
    [lateLoadingNodes addObject:node];
}

-(NSString*)relativePath{
    return relativePath;
}

-(float)currentDeviceRatio{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            return [dev ratio];
        }
    }
    return 1.0f;
}

-(CGSize)designResolutionSize{
    return designResolutionSize;
}
-(CGPoint)designOffset{
    return designOffset;
}

-(NSString*)currentDeviceSuffix{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            NSString* suffix = [dev suffix];
            suffix = [suffix stringByReplacingOccurrencesOfString:@"@2x"
                                                       withString:@""];
            return suffix;
        }
    }
    return @"";
}
@end

