//
//  PlayerBoardView.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayerBoard;
@class PlayerBoardViewController;
@class CellLocation;
@protocol PlayerBoardViewDelegate;

@interface PlayerBoardView : UIView

//TODO: 修改为delegate模式
@property(weak) PlayerBoard *playerBoard; //DataModel delegate；必须为weak引用，否则循环引用

@property(weak) id<PlayerBoardViewDelegate> delegate; //Action handler delegate；必须为weak引用，否则会产生循环引用

//reload data callback
- (void)reloadData;
- (void)reloadDataAtRow:(int)row column:(int)column;
- (void)reloadDataInLocations:(NSArray<CellLocation *> *)locations;
- (void)drawRect:(CGRect)rect;

@end



//---------------------------------------------------------------------
/**
 * @protocol PlayerBoardViewDelegate;
 *
 * Used by PlayerBoardView to callback
 */
@protocol PlayerBoardViewDelegate <NSObject>

@optional
//delegate method for PlayerBoardView object to call
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didSingleTapOnCell:(CellLocation *)location;

@optional
//delegate method for PlayerBoardView object to call
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didDoubleTapOnCell:(CellLocation *)location;

@optional
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didLongPressOnCell:(CellLocation *)location;
@end
