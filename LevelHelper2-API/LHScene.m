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



@implementation LHSceneNode
{
    LHScene* _scene;
}

-(void)dealloc{
    _scene = nil;
    LH_SUPER_DEALLOC();
}

+(instancetype)nodeWithScene:(LHScene*)val{
    return LH_AUTORELEASED([[self alloc] initNodeWithScene:val]);
}

- (instancetype)initNodeWithScene:(LHScene*)scn{
    if(self = [super init]){
        _scene = scn;
    }
    return self;
}
-(SKNode*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}
-(NSString*)uuid{
    return [_scene uuid];
}

@end




@implementation LHScene
{
    SKNode* _sceneNode;
    
    NSMutableArray* lateLoadingNodes;//gets nullified after everything is loaded
    
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    NSMutableDictionary* loadedTextures;
    NSMutableDictionary* loadedTextureAtlases;
    NSDictionary* tracedFixtures;
    
    NSArray* supportedDevices;
    CGSize  designResolutionSize;
    CGPoint designOffset;
    
    NSString* relativePath;
    
    SKNode* touchedNode;
    BOOL touchedNodeWasDynamic;
    
    NSMutableArray* ropeJoints;
    CGPoint ropeJointsCutStartPt;
    
    NSMutableDictionary* _loadedAssetsInformations;
    
    CGRect gameWorldRect;
    NSMutableArray* cameras;
    
    NSTimeInterval previousUpdateTime;
}


-(void)dealloc{
    
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_userProperty);
    LH_SAFE_RELEASE(_tags);
    
    LH_SAFE_RELEASE(ropeJoints);
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
        _sceneNode = [LHSceneNode nodeWithScene:self];
        [_sceneNode setName:@"LHSceneNode"];
        self.anchorPoint = CGPointMake(0, 1);
        [super addChild:_sceneNode];
        
        relativePath = [[NSString alloc] initWithString:[levelPlistFile stringByDeletingLastPathComponent]];
        
        designResolutionSize = designResolution;
        designOffset         = childrenOffset;
        self.scaleMode       = scaleMode;
        
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        
        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }

        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        if([dict boolForKey:@"useGlobalGravity"])
        {
            //more or less the same as box2d
            CGPoint gravityVector = [dict pointForKey:@"globalGravityDirection"];
            float gravityForce    = [dict floatForKey:@"globalGravityForce"];
            [self.physicsWorld setGravity:CGVectorMake(gravityVector.x,
                                                       gravityVector.y*gravityForce)];
//            [self.physicsWorld setSpeed:gravityForce];
        }
        
        [self setBackgroundColor:[dict colorForKey:@"backgroundColor"]];
        
        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        for(NSDictionary* childInfo in childrenInfo)
        {
            SKNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                        parent:_sceneNode];
            #pragma unused (node)
        }
        
        
        
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
                CGRect bRect = LHRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];
                offset.y -= self.size.height;
                CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
                                            (1.0f - bRect.origin.y)*designSize.height + offset.y,
                                            bRect.size.width*designSize.width ,
                                            -(bRect.size.height)*designSize.height);
                
                _sceneNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:skBRect];
                _sceneNode.physicsBody.dynamic = NO;
                if([[LHConfig sharedInstance] isDebug])
                {
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = CGPathCreateWithRect(skBRect,
                                                               nil);
                    debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:1];
                    [_sceneNode addChild:debugShapeNode];
                }
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
                
                if([[LHConfig sharedInstance] isDebug])
                {
                    CGRect gameWorldRectT = gameWorldRect;
                    gameWorldRectT.origin.x += 2;
                    gameWorldRectT.size.width -= 4;
                    gameWorldRectT.origin.y -= 2;
                    gameWorldRectT.size.height += 4;
                    
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = CGPathCreateWithRect(gameWorldRectT,nil);
                    
                    debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];
                    [_sceneNode addChild:debugShapeNode];
                }
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
        
        for(LHRopeJointNode* rope in ropeJoints){
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

-(SKNode*)sceneNode{
    return _sceneNode;
}

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(LHScene*)scene{
    return self;
}

- (SKNode*)childNodeWithName:(NSString *)name{
    return [_sceneNode childNodeWithName:name];
}

-(SKNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues
                       containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues
                         containsAny:any
                            forNode:_sceneNode];
}


-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:_sceneNode];
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

-(void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
    for(SKNode<LHNodeProtocol>* n in [_sceneNode children]){
        if([n conformsToProtocol:@protocol(LHNodeProtocol)]){
            [n update:currentTime
                delta:dt];
        }
    }
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
            [scene addRopeJointNode:jt];
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

+(SKNode<LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid
                                    forNode:(SKNode <LHNodeProtocol>*)selfNode{
    for(SKNode <LHNodeProtocol>* node in [selfNode children])
    {
        if([node respondsToSelector:@selector(uuid)]){
            NSString* nodeUUID = [node performSelector:@selector(uuid)];
            if(nodeUUID && [nodeUUID isEqualToString:uuid]){
                return node;
            }
            
            if([node respondsToSelector:@selector(childNodeWithUUID:)])
            {
                SKNode<LHNodeProtocol>* retNode = [node performSelector:@selector(childNodeWithUUID:)
                                             withObject:uuid];
                if(retNode){
                    return retNode;
                }
            }
        }
    }
    return nil;
}

+(NSMutableArray*)childrenOfType:(Class)type
                         forNode:(SKNode*)selfNode{
    
    NSMutableArray* temp = [NSMutableArray array];
    for(SKNode* child in [selfNode children]){
        if([child isKindOfClass:type]){
            [temp addObject:child];
        }
        
        if([child respondsToSelector:@selector(childrenOfType:)])
        {
            NSMutableArray* childArray = [child performSelector:@selector(childrenOfType:)
                                          withObject:type];
            if(childArray){
                [temp addObjectsFromArray:childArray];
            }
        }
    }
    return temp;
}

+(NSMutableArray*)childrenWithTags:(NSArray*)tagValues
                       containsAny:(BOOL)any
                          forNode:(SKNode*)selfNode
{
    NSMutableArray* temp = [NSMutableArray array];
    for(id<LHNodeProtocol> child in [selfNode children]){
        if([child conformsToProtocol:@protocol(LHNodeProtocol)])
        {
            NSArray* childTags =[child tags];

            int foundCount = 0;
            BOOL foundAtLeastOne = NO;
            for(NSString* tg in childTags)
            {
                for(NSString* st in tagValues){
                    if([st isEqualToString:tg])
                    {
                        ++foundCount;
                        foundAtLeastOne = YES;
                        if(any){
                            break;
                        }
                    }
                }
                
                if(any && foundAtLeastOne){
                    [temp addObject:child];
                    break;
                }
            }
            if(!any && foundAtLeastOne && foundCount == [tagValues count] && [childTags count] == [tagValues count]){
                [temp addObject:child];
            }

            if([child respondsToSelector:@selector(childrenWithTags:containsAny:)])
            {
                NSMutableArray* childArray = [child childrenWithTags:tagValues containsAny:any];
                if(childArray){
                    [temp addObjectsFromArray:childArray];
                }
            }
        }
    }
    return temp;
}



-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)removeRopeJointNode:(LHRopeJointNode*)node{
    [ropeJoints removeObject:node];
}
-(void)addRopeJointNode:(LHRopeJointNode*)node{
    if(!ropeJoints){
        ropeJoints = [[NSMutableArray alloc] init];
    }
    [ropeJoints addObject:node];
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

