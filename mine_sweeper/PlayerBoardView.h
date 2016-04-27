//
//  PlayerBoardView.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@class PlayerBoard;
@class GameViewController;
@class CellLocation;
@protocol IPlayerBoardViewDelegate;


@interface PlayerBoardView : GLKView <IPlayerBoardDelegate>

@property(weak) PlayerBoard *playerBoard; //DataModel delegate；必须为weak引用，否则循环引用

@property(weak) id<IPlayerBoardViewDelegate> listener; //Action handler delegate；必须为weak引用，否则会产生循环引用

- (void)drawRect:(CGRect)rect;

@end



//---------------------------------------------------------------------
/**
 * @protocol PlayerBoardViewDelegate;
 *
 * Used by PlayerBoardView to callback as actions listener
 */
@protocol IPlayerBoardViewDelegate <NSObject>

@optional
//delegate method for PlayerBoardView object to call
-(void)player:(PlayerBoardView *)player didSingleTapOnCell:(CellLocation *)location;

@optional
//delegate method for PlayerBoardView object to call
-(void)player:(PlayerBoardView *)player didDoubleTapOnCell:(CellLocation *)location;

@optional
-(void)player:(PlayerBoardView *)player didLongPressOnCell:(CellLocation *)location;
@end
