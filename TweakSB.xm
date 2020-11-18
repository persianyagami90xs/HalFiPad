#import "TweakCommon.h"

%hook SBControlCenterController
-(NSUInteger)presentingEdge {
    return 1;
}
%end

%hook CCSControlCenterDefaults
-(NSUInteger)_defaultPresentationGesture {
    return 1;
}
%end

%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled {
    return YES;
}
%end

%hook SpringBoard
-(NSUInteger)homeScreenRotationStyle {
    return 0;
}
%end

%hook SBIconListPageControl
-(void)setHidden:(bool)arg1 {
    arg1 = 1;
    %orig;
}
%end

// LockScreen Shortcuts
%hook CSQuickActionsViewController
+ (BOOL)deviceSupportsButtons {
	return isLSShortcuts;
}

- (BOOL)hasCamera {
	return isLSShortcuts;
}

- (BOOL)hasFlashlight {
	return isLSShortcuts;
}
%end

%hook CSQuickActionsView
- (void)_layoutQuickActionButtons {
    CGRect const screenBounds = [UIScreen mainScreen].bounds;
    int const y = screenBounds.size.height - 70 - [self _buttonOutsets].top;
    [self flashlightButton].frame = CGRectMake(46, y, 50, 50);
    [self cameraButton].frame = CGRectMake(screenBounds.size.width - 96, y, 50, 50);
}
%end

// Switch StatusBar
%group SwitchStatusBar
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if (statusBarMode == 5)
        return NSClassFromString(@"_UIStatusBarVisualProvider_Split61");
    else if (statusBarMode == 2 || (screenRound > 15 && statusBarMode == 1))
        return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    else if (statusBarMode == 1)
        return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end
%end

// Fix StatusBar X
%group StatusBarXFix
%hook SBIconListGridLayoutConfiguration
- (UIEdgeInsets)portraitLayoutInsets {
    UIEdgeInsets const x = %orig;
    NSUInteger const rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (rows==3) return %orig;
    return UIEdgeInsetsMake(x.top+10, x.left, x.bottom, x.right);
}
%end
%end

// Split 58 Calibrate
%group StatusBarCalibrate58
%hook _UIStatusBarVisualProvider_Split58
+(double)height {
    return 20;
}

+(CGSize)notchSize{
    CGSize const notSize = %orig;
    return CGSizeMake(notSize.width, 18);
}

+(CGSize)pillSize {
    return CGSizeMake(48, 18);
}
%end
%end

// Split 61 Calibrate
%group StatusBarCalibrate61
%hook _UIStatusBarVisualProvider_Split61
+(double)height {
    return 20;
}

+(CGSize)notchSize{
    CGSize const notSize = %orig;
    return CGSizeMake(notSize.width, 18);
}

+(CGSize)pillSize {
    return CGSizeMake(48, 18);
}
%end
%end

// Fix CCSB >= 13.4
%group FixCC134
%hook CCUIStatusBar
-(NSUInteger)leadingState {
    return 1;
}

-(NSUInteger)trailingState {
    return 1;
}
%end
%end

// No CCSB
%group NoCCStatusBar
%hook CCUIStatusBar
-(id)initWithFrame:(CGRect)arg1 {
    return nil;
}
%end

// NoBlurCC
%hook CCUIHeaderPocketView
-(void)setBackgroundAlpha:(double)arg1 {
    %orig(0.0);
}
%end
%end

// Fix CC Status Bar Overlay
%hook CCUIModularControlCenterOverlayViewController
- (void)setOverlayStatusBarHidden:(BOOL)arg1 {
    if (!isCCStatusbar || statusBarMode == 0) return;
    %orig;
}
%end

// CC StatusBar
%hook CCUIModularControlCenterOverlayViewController
- (void)dismissAnimated:(bool)arg1 withCompletionHandler:(id)arg2 {
    if(!isCCAnimation) {
        arg1 = 0;
    }
    %orig(arg1, arg2);
}
%end

// Fix CC Padding
%group CCStatusBar
%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    if (gesturesMode == 4) {
        if (statusBarMode == 2 || (screenRound > 15 && statusBarMode == 1))
            %orig(CGRectSetY(frame, -11));
        else if (statusBarMode == 3)
            %orig(CGRectSetY(frame, 9));
        else if (statusBarMode == 0)
            %orig(CGRectSetY(frame, -34));
        else
            %orig(CGRectSetY(frame, -15));
    } else {
        if(statusBarMode == 2 || (screenRound > 15 && statusBarMode == 1))
            %orig(CGRectSetY(frame, -20));
        else if (statusBarMode == 0)
            %orig(CGRectSetY(frame, -42));
        else if (statusBarMode == 3)
            %orig;
        else
            %orig(CGRectSetY(frame, -24));
    }
}
%end
%end

// Battery Percentage
%group BatteryPercentage
@interface _UIBatteryView : UIView
@property (nonatomic, copy, readwrite) UIColor *fillColor;
@property (nonatomic,retain) UILabel * percentageLabel;
@property CGFloat chargePercent;
- (UIColor *)_batteryColor;
@end

%hook _UIBatteryView
-(void)setShowsPercentage:(BOOL)arg1 {
    %orig(YES);
}

%new
- (UIColor *)_batteryColor {
    if (batteryColorMode == 1) {
        CGFloat chargePercent = self.chargePercent;
	    if(chargePercent >= 0.95) {
	    	return [UIColor colorWithRed:0.08 green:0.71 blue:1.00 alpha:1.0];
	    }
	    else if(chargePercent >= 0.90) {
	    	return [UIColor colorWithRed:0.43 green:0.78 blue:1.00 alpha:1.0];
	    }
	    else if(chargePercent >= 0.85) {
	    	return [UIColor colorWithRed:0.59 green:0.91 blue:1.00 alpha:1.0];
	    }
	    else if(chargePercent >= 0.80) {
	    	return [UIColor colorWithRed:0.47 green:1.00 blue:0.99 alpha:1.0];
	    }
	    else if(chargePercent >= 0.75) {
	    	return [UIColor colorWithRed:0.38 green:1.00 blue:0.79 alpha:1.0];
	    }
	    else if(chargePercent >= 0.70) {
	    	return [UIColor colorWithRed:0.40 green:0.90 blue:0.71 alpha:1.0];
	    }
	    else if(chargePercent >= 0.65) {
	    	return [UIColor colorWithRed:0.26 green:0.96 blue:0.54 alpha:1.0];
	    }
	    else if(chargePercent >= 0.60) {
	    	return [UIColor colorWithRed:0.26 green:1.00 blue:0.45 alpha:1.0];
	    }
	    else if(chargePercent >= 0.55) {
	    	return [UIColor colorWithRed:0.56 green:0.87 blue:0.21 alpha:1.0];
	    }
	    else if(chargePercent >= 0.50) {
	    	return [UIColor colorWithRed:0.84 green:0.95 blue:0.22 alpha:1.0];
	    }
	    else if(chargePercent >= 0.45) {
	    	return [UIColor colorWithRed:0.93 green:0.96 blue:0.21 alpha:1.0];
	    }
	    else if(chargePercent >= 0.40) {
	    	return [UIColor colorWithRed:0.97 green:0.92 blue:0.20 alpha:1.0];
	    }
	    else if(chargePercent >= 0.35) {
	    	return [UIColor colorWithRed:0.95 green:0.77 blue:0.19 alpha:1.0];
	    }
	    else if(chargePercent >= 0.30) {
	    	return [UIColor colorWithRed:1.00 green:0.76 blue:0.18 alpha:1.0];
	    }
	    else if(chargePercent >= 0.25) {
	    	return [UIColor colorWithRed:0.98 green:0.68 blue:0.19 alpha:1.0];
	    }
	    else if(chargePercent >= 0.20) {
	    	return [UIColor colorWithRed:0.96 green:0.57 blue:0.20 alpha:1.0];
	    }
	    else if(chargePercent >= 0.15) {
	    	return [UIColor colorWithRed:0.95 green:0.48 blue:0.20 alpha:1.0];
	    }
	    else if(chargePercent >= 0.10) {
	    	return [UIColor colorWithRed:0.93 green:0.39 blue:0.21 alpha:1.0];
	    }
	    else if(chargePercent >= 0.5) {
	    	return [UIColor colorWithRed:0.91 green:0.31 blue:0.22 alpha:1.0];
	    }
	    else {
	    	return [UIColor colorWithRed:0.89 green:0.24 blue:0.22 alpha:1.0];
	    }
    }
    return self.fillColor;
}

-(UIColor *)bodyColor {
    if (batteryColorMode == 0) return %orig;
    return [self _batteryColor];
}

-(UIColor *)pinColor {
    if (batteryColorMode == 0) return %orig;
    return [self _batteryColor];
}

-(void)setShowsInlineChargingIndicator:(BOOL)arg1 {
    if(isHideChargingIndicator) {
        arg1 = NO;
    }
    %orig(arg1);
}
%end

%hook _UIStatusBarStringView
-(void)setText:(NSString *)text {
    if ([text containsString:@"%"]) {
        if (isPercentChargingCC) {
            if (!([[UIDevice currentDevice] batteryState]==2)) return;
            else %orig;
        } else if (isHideStockPercent) return;
        else %orig;
    }
    else %orig(text);
}
%end
%end

// No Reachability
%hook SBReachabilityManager
-(BOOL)gestureRecognizerShouldBegin:(id)arg1 {
    return isReachability;
}
%end

// Original Buttons
%group OriginalButtons
%hook SBLockHardwareButtonActions
-(id)initWithHomeButtonType:(NSInteger)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBHomeHardwareButtonActions
-(id)initWitHomeButtonType:(NSInteger)arg1 {
     return %orig(1);
}
%end

int applicationDidFinishLaunching;
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    applicationDidFinishLaunching = 2;
    %orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
    if (applicationDidFinishLaunching == 2 && [arg1 isEqual:lockVol]) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(NSInteger)arg2 {
    return %orig(arg1, 1);
}
%end

%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(NSInteger)arg7 createGestures:(_Bool)arg8 {
    return %orig(arg1,arg2,arg3,arg4,arg5,arg6,1,arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(NSInteger)arg6 {
    return %orig(arg1,arg2,arg3,arg4,arg5,1);
}
%end

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(NSInteger)arg3 {
    return %orig(arg1,arg2,1);
}
%end
%end

// HomeBar SB
%group HomeBar
%hook SBFHomeGrabberSettings
- (BOOL)isEnabled {
    return isHomeBarSB;
}
%end
%end

// Edge Protect
%hook SBDeviceApplicationSceneHandle
-(BOOL)isEdgeProtectEnabledForHomeGesture {
    if (isEdgeProtect) return YES;
    return %orig;
}

// HomeBar Auto Hide
-(BOOL)isAutoHideEnabledForHomeAffordance {
    return isHomeBarAutoHide;
}
%end

// No HomeBar LS
%group NoHomeBarLS
%hook CSTeachableMomentsContainerView
-(void)setHomeAffordanceContainerView:(UIView *)arg1 {
    return;
}

-(void)setHomeAffordanceView:(UIView *)arg1 {
    return;
}
%end
%end

// No HomeBar
%group NoHomeBar
%hook MTLumaDodgePillSettings
-(void)setHeight:(double)arg1 {
    return %orig(0);
}
%end
%end

// No breadcum
%group NoBreadcrumb
%hook _UIStatusBarData
-(void)setBackNavigationEntry:(id)arg1 {
    return;
}
%end
%end

// HomeBar Custom
%group HomeBarCustom
%hook MTLumaDodgePillSettings
-(void)setMinWidth:(double)arg1 {
    arg1 = HomeBarWidth;
    %orig;
}

-(void)setMaxWidth:(double)arg1 {
    arg1 = HomeBarWidth;
    %orig;
}

-(void)setCornerRadius:(double)arg1 {
    arg1 = HomeBarRadius;
    %orig;
}

-(void)setHeight:(double)arg1 {
    arg1 = HomeBarHeight;
    %orig;
}
%end
%end

// Round Dock/AppSwitcher
%group RoundAppDock
%hook UITraitCollection
-(CGFloat)displayCornerRadius {
    return appDockRound;
}
%end
%end

// Rounded Screen Corner
%group RoundCorner
@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
@end

%hook _UIRootWindow
-(id)initWithDisplay:(id)arg1 {
    %orig;
    self.clipsToBounds = YES;
    self._continuousCornerRadius = screenRound;
    return self;
}
%end

%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return screenRound;
}
%end
%end

// No Gestures Keyboard
%hook SBHomeGesturePanGestureRecognizer
void resetTouch(SBHomeGesturePanGestureRecognizer *self, NSSet *touches, id event) {
    [self touchesEnded: touches withEvent: event];
    [self reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(id)event {
    UITouch *touch = [touches anyObject];
    BOOL reset = NO;
    if(gesturesMode == 2)
        reset = [touch locationInView:touch.view].x > touch.view.bounds.size.width / 2;
    else if(gesturesMode == 3)
        reset = [touch locationInView:touch.view].x < touch.view.bounds.size.width / 2;
    if (reset || isNoGesturesKeyboard || gesturesMode == 5) {
        resetTouch(self, touches, event);
        return;
    }
    return %orig;
}
%end

// Floating Dock
%group FloatingDock
%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
    return YES;
}
%end
// Recent Aplication
%hook SBFloatingDockSuggestionsModel
-(void)_setRecentsEnabled:(BOOL)arg1 {
    return %orig(isRecentApp);
}
%end
// In-App Dock
%hook SBFloatingDockBehaviorAssertion
-(BOOL)gesturePossible {
    if(!isInAppDock) return NO;
    return %orig;
}
%end

// Fix icon rows
%hook SBIconListView
-(NSUInteger)iconRowsForCurrentOrientation {
    if (%orig < 4) return %orig;
    return %orig+1;
}
%end
%end

// iPad Multitask
%group iPadMultitask
@interface FBApplicationInfo
@property (nonatomic,retain,readonly) NSURL *executableURL;
@end

@interface SBApplicationInfo : FBApplicationInfo
@end

@interface SBApplication
@property (nonatomic,readonly) SBApplicationInfo *info;
@end

%hook SBPlatformController
-(NSInteger)medusaCapabilities {
    return 2;
}
%end

%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
    return YES;
}
%end

%hook SBApplication
-(BOOL)isMedusaCapable {
    // Fix app only landscape
    NSString *pathURL = [self.info.executableURL.path stringByDeletingLastPathComponent];
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:[pathURL stringByAppendingString:@"/Info.plist"]];
    NSArray *orientations = [infoDict objectForKey:@"UISupportedInterfaceOrientations"];
    if ([orientations indexOfObject:@"UIInterfaceOrientationPortrait"] == NSNotFound) {
        return NO;
    }
    return YES;
}
-(BOOL)mainSceneWantsFullscreen {
    return screenMode;
}
%end
%end

// New Grid Switcher
%group NewGridSwitcher
%hook SBAppSwitcherSettings
-(void)setSwitcherStyle:(NSInteger)arg1 {
    return %orig(2);
}
%end
%end

// No icon Fly
%hook CSCoverSheetTransitionSettings
-(BOOL)iconsFlyIn {
    return !isNoIconsFly;
}
%end

// Fast Open App
%group FastOpenApp
%hook SBFFluidBehaviorSettings
-(void)setResponse:(double)arg1 {
        %orig(0.1);
}
%end
%end

// Reduce Rows
%group ReduceRows
%hook SBIconListGridLayoutConfiguration
- (NSUInteger)numberOfPortraitRows {
    if (%orig < 4) return %orig;
    return 5;
}
%end
%end

//Swipe To Screenshot
%group SwipeToScreenshot
@interface UIWindow(SS)
@property (nonatomic, retain) UIPanGestureRecognizer *ssGestureRecognizer;
- (void)ssScreenshot;
@end

@interface UIStatusBar_Modern : UIWindow
@end

@interface SpringBoard
-(void)takeScreenshot;
@end

%hook UIStatusBar_Modern
%property (nonatomic, retain) UIPanGestureRecognizer *ssGestureRecognizer;
%new
-(void)ssScreenshot {
    if (self.ssGestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    [(SpringBoard *)[UIApplication sharedApplication] takeScreenshot];
}

-(void)layoutSubviews {
    %orig;
    if (self.ssGestureRecognizer) return;
    self.ssGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ssScreenshot)];
    self.ssGestureRecognizer.minimumNumberOfTouches = 2;
    self.ssGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.ssGestureRecognizer];
}
%end
%end

// Force Orientation Landscape Lock
%group LandscapeLock
@interface SBOrientationLockManager : NSObject
-(void)lock:(UIInterfaceOrientation)orientation;
@end

@interface UIApplication (Private)
-(UIInterfaceOrientation)activeInterfaceOrientation;
@end

%hook SBOrientationLockManager
-(void)lock {
    [self lock:[[UIApplication sharedApplication] activeInterfaceOrientation]];
}
%end
%end

// No Dock Background : Normal Dock
%group NoNomalDockBG
@interface SBDockView : UIView {
    UIView *_backgroundView;
}
@end

%hook SBDockView
-(void)didMoveToWindow {
    %orig;
    UIView *view = [self valueForKey:@"_backgroundView"];
    view.hidden = YES;
}
%end
%end

// No Dock Background : Floating Dock
%group NoFloatingDockBG
@interface SBFloatingDockPlatterView : UIView {
    UIView *_backgroundView;
}
@end

%hook SBFloatingDockPlatterView
-(void)didMoveToWindow {
    %orig;
    UIView *view = [self valueForKey:@"_backgroundView"];
    view.hidden = YES;
}
%end
%end

// More Icon Dock
%group MoreIconDock
%hook SBIconListGridLayoutConfiguration
- (NSUInteger)numberOfPortraitColumns {
    NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (rows==1) {
        if (!isiPadDock) return 5;
        return 6;
    }
    return %orig;
}
%end

%hook SBDockIconListView
-(CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)arg1 numberOfIcons:(NSInteger)arg2 {
    if (arg2==5) {
            struct SBIconCoordinate cor1;
            cor1.row = 1;   cor1.col = 1;
            struct SBIconCoordinate cor2;
            cor2.row = 1;   cor2.col = 2;
            struct SBIconCoordinate cor3;
            cor3.row = 1;   cor3.col = 3;
            struct SBIconCoordinate cor4;
            cor4.row = 1;   cor4.col = 4;
            CGPoint originalPointForIcon1 = %orig(cor1, 4);
            CGPoint originalPointForIcon2 = %orig(cor2, 4);
            CGPoint originalPointForIcon3 = %orig(cor3, 4);
            CGPoint originalPointForIcon4 = %orig(cor4, 4);
            int defaultY  = originalPointForIcon1.y;
            int newIcon1X = originalPointForIcon1.x - (int)(originalPointForIcon1.x * 0.21);
            int newIcon2X = originalPointForIcon2.x - (int)(originalPointForIcon2.x * 0.21);
            int newIcon3X = originalPointForIcon3.x - (int)(originalPointForIcon3.x * 0.21);
            int newIcon4X = originalPointForIcon4.x - (int)(originalPointForIcon4.x * 0.21);
            int newIcon5X = originalPointForIcon4.x + (int)(originalPointForIcon4.x * 0.03);
            if (arg1.col == 1) return CGPointMake(newIcon1X, defaultY);else
            if (arg1.col == 2) return CGPointMake(newIcon2X, defaultY);else
            if (arg1.col == 3) return CGPointMake(newIcon3X, defaultY);else
            if (arg1.col == 4) return CGPointMake(newIcon4X, defaultY);else
            return CGPointMake(newIcon5X, defaultY);
    }
    return %orig;
}
%end
%end

// FaceID + Padlock Animation
%group PadLock
@interface SBDashBoardMesaUnlockBehaviorConfiguration : NSObject
- (BOOL)_isAccessibilityRestingUnlockPreferenceEnabled;
@end

@interface SBDashBoardBiometricUnlockController : NSObject
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface WGWidgetGroupViewController : UIViewController
@end

static CGFloat offset = 0;

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
    CGFloat const screenWidth = UIScreen.mainScreen.bounds.size.width;
	if (screenWidth <= 320) {
		offset = 20;
	} else if (screenWidth <= 375) {
		offset = 35;
	} else if (screenWidth <= 414) {
		offset = 28;
	}
    return %orig;
}

-(void)layoutSubviews {
	%orig;
	UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
	UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
	UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
	[timeView setFrame:CGRectSetY(timeView.frame, timeView.frame.origin.y + offset)];
	[dateSubtitleView setFrame:CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + offset)];
	[customSubtitleView setFrame:CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + offset)];
}
%end

%hook SBDashBoardLockScreenEnvironment
-(void)handleBiometricEvent:(NSInteger)arg1 {
	%orig;
	if (arg1 == 4) {
		SBDashBoardBiometricUnlockController* biometricUnlockController = MSHookIvar<SBDashBoardBiometricUnlockController*>(self, "_biometricUnlockController");
		SBDashBoardMesaUnlockBehaviorConfiguration* unlockBehavior = MSHookIvar<SBDashBoardMesaUnlockBehaviorConfiguration*>(biometricUnlockController, "_biometricUnlockBehaviorConfiguration");
		if ([unlockBehavior _isAccessibilityRestingUnlockPreferenceEnabled]) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[%c(SBLockScreenManager) sharedInstance] _finishUIUnlockFromSource:12 withOptions:nil];
			});
		}
	}
}
%end

%hook WGWidgetGroupViewController
-(void)updateViewConstraints {
    %orig;
	[self.view setFrame:CGRectSetY(self.view.frame, self.view.frame.origin.y + (offset/2))];
}
%end

%hook BSUICAPackageView
- (id)initWithPackageName:(id)arg1 inBundle:(id)arg2 {
	if (![arg1 hasPrefix:@"lock"]) return %orig;
	NSString* packageName = [arg1 stringByAppendingString:@"-896h"];
	return %orig(packageName, [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardUIServices.framework"]);
}
%end

%hook CSCombinedListViewController
-(UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets orig = %orig;
    orig.top += offset;
    return orig;
}
%end

%hook SBUIBiometricResource
-(id)init {
	id r = %orig;
	MSHookIvar<BOOL>(r, "_hasMesaHardware") = NO;
	MSHookIvar<BOOL>(r, "_hasPearlHardware") = YES;
	return r;
}
%end
%end

%group MakeSBClean
// NoWidgetFooter
@interface WGWidgetAttributionView
@property (nonatomic, assign, readwrite, getter=isHidden) BOOL hidden;
@end

%hook WGWidgetAttributionView
-(void)didMoveToWindow {
    %orig;
    self.hidden = YES;
}
%end

// NoPageDots
%hook SBIconListPageControl
- (id)initWithFrame:(struct CGRect)arg1 {
	return nil;
}
%end

%hook CSPageControl
-(id)initWithFrame:(struct CGRect)arg1 {
	return nil;
}
%end

// NoAppLabels
%hook SBMutableIconLabelImageParameters
-(void)setTextColor:(id)arg1 {
    %orig([UIColor clearColor]);
}
%end

// Folder
%hook SBFolderBackgroundView
- (id)initWithFrame:(struct CGRect)arg1{
  	return NULL;
}
%end

%hook SBFolderIconImageView
 - (void)setBackgroundView : (UIView *)backgroundView {}
%end
%end

// Tweak handle
%ctor {
    @autoreleasepool {
        updatePrefs();
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updatePrefs,
            CFSTR("com.hius.HalFiPadPrefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce
        );
        if (enabled) {
            // StatusBar Style
            if (statusBarMode != 0) {
                %init(SwitchStatusBar);
                if (statusBarMode == 4)
                    %init(StatusBarCalibrate58);
                else if(statusBarMode == 5)
                    %init(StatusBarCalibrate61);
                else if (statusBarMode == 3)
                    %init(StatusBarXFix);
            }
            if (gesturesMode != 0) {
                %init(CCStatusBar);
            } else {
                %init(FixCC134);
                isiPadMultitask = NO;
            }
            // iPad features
            if(isiPadDock) {
                %init(FloatingDock);
                if (isiPadMultitask)
                    %init(iPadMultitask);
            }
            if (isNewGridSwitcher) %init(NewGridSwitcher);
            // Global options
            if (isBatteryPercent) %init(BatteryPercentage);
            if (!isCCStatusbar) %init(NoCCStatusBar);
            if (isNoBreadcrumb) %init(NoBreadcrumb);
            if (!isiPXCombination) %init(OriginalButtons);
            // Round Corner
            if (screenRound > 0) %init(RoundCorner);
            if (appDockRound > 5) %init(RoundAppDock);
            // More options
            if (isMakeSBClean) %init(MakeSBClean);
            if (isMoreIconDock) %init(MoreIconDock);
            if (isFastOpenApp) %init(FastOpenApp);
            if (isNoDockBackgroud) {
                if(!isiPadDock)
                    %init(NoNomalDockBG);
                else
                    %init(NoFloatingDockBG);
            }
            if (isSwipeScreenshot) %init(SwipeToScreenshot);
            if (isReduceRows) %init(ReduceRows);
            if (isLandscapeLock) %init(LandscapeLock);
            if (isPadLock) %init(PadLock);

            // Home Bar
            if (isHomeBarAutoHide) {
                isHomeBarSB = YES;
            }
            if (!isHomeBarLS) {
                %init(NoHomeBarLS);
                if (!isHomeBarSB) %init(NoHomeBar);
            } else {
                %init(HomeBar);
            }
            if (isHomeBarSB || isHomeBarLS) {
                if (isHomeBarCustom) %init(HomeBarCustom);
            }

            if (isNoSwipeKeyboard) {
                [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *n) {isNoGesturesKeyboard = true;} ];
                [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *n) {isNoGesturesKeyboard = false;} ];
            }
            
            %init;
        }
    }
}