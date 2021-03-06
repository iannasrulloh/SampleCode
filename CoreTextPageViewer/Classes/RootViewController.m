
/*
     File: RootViewController.m
 Abstract: A view controller that manages a search bar and a recent searches controller.
 The view controller creates a search bar to place in a tool bar. When the user commences a search, a recent searches controller is displayed in a popover.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
*/

#import "RootViewController.h"

@implementation RootViewController

@synthesize toolbar, samplesButton, fontFamsButton;
@synthesize samplesController, samplesPopoverController;
@synthesize fontFamsController, fontFamsPopoverController;
@synthesize coreTextScrollView;


#pragma mark -
#pragma mark Create and manage the search results controller

- (void)viewDidLoad {
    [super viewDidLoad];

	// initialize flag variable that tracks if scrollViewDidScroll is generated by user
    scrollFeedbackFromOtherControl = YES;
    
    // Create samples button
    samplesButton = [[UIBarButtonItem alloc] initWithTitle:@"Samples" style:UIBarButtonItemStyleBordered target:self action:@selector(samplesPopUp:)];

    // Create fontFams ("Fonts and Features") button
    fontFamsButton = [[UIBarButtonItem alloc] initWithTitle:@"Fonts" style:UIBarButtonItemStyleBordered target:self action:@selector(fontFamsPopUp:)];

	// Set buttons as items for the toolbar
    toolbar.items = [NSArray arrayWithObjects:samplesButton, fontFamsButton, nil];
    
    // Create and configure the samples controller
    SamplesController *aSamplesController = [[SamplesController alloc] initWithStyle:UITableViewStylePlain];
    self.samplesController = aSamplesController;
    samplesController.delegate = self;    
    
    // Create a navigation controller to contain the samples controller, and create the popover controller to contain the navigation controller.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:samplesController];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    self.samplesPopoverController = popover;
    samplesPopoverController.delegate = self;
    
    [navigationController release];
    [aSamplesController release];
    [popover release];
    
    // Create and configure the fontFams controller.
    FontFamsController *aFontFamsController = [[FontFamsController alloc] initWithStyle:UITableViewStyleGrouped];
    self.fontFamsController = aFontFamsController;
    fontFamsController.delegate = self;    
    
    // Create a navigation controller to contain the fontFams controller, and create the popover controller to contain the navigation controller.
    navigationController = [[UINavigationController alloc] initWithRootViewController:fontFamsController];
    popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    self.fontFamsPopoverController = popover;
    fontFamsPopoverController.delegate = self;
    
    [navigationController release];
    [aFontFamsController release];
    [popover release];
       
	// Initialize our CoreTextScrollView and set the initial sample document shown
    [coreTextScrollView reset:[[[AttributedStringDoc alloc] initWithFileNameFromBundle:@"Splash.xml"] autorelease] withDelegate:self];
	samplesController.selectedSample = @"Splash.xml";
}

#pragma mark -
#pragma mark Samples controller related methods

- (void)samplesPopUp:(id)sender {   
	// Present the samples popover
    [self.fontFamsPopoverController dismissPopoverAnimated:NO];
    [samplesPopoverController presentPopoverFromBarButtonItem:samplesButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)samplesController:(SamplesController *)controller didSelectString:(NSString *)sampleFileName {    
    // The user selected a row in the samples list, so load the specified sample document
    [coreTextScrollView reset:[[[AttributedStringDoc alloc] initWithFileNameFromBundle:sampleFileName] autorelease] withDelegate:self];
	// Dismiss the samples popover
    [self.samplesPopoverController dismissPopoverAnimated:YES];
	// Clear out selected font in fontFamsController as the new sample will
	// initially use the font and styles from the sample document data 
	[self.fontFamsController deselectAllFonts];
}


#pragma mark -
#pragma mark FontFams controller and methods

- (void)fontFamsPopUp:(id)sender {
	// Present the fontFams popover
    [self.samplesPopoverController dismissPopoverAnimated:NO];
    [fontFamsPopoverController presentPopoverFromBarButtonItem:fontFamsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)fontFamsController:(FontFamsController *)controller didSelectString:(NSString *)fontFamilyName {
    // The user selected a row in the font families list, so update our 
	// CoreTextScrollView with the new override font
	[coreTextScrollView fontFamilyChange:fontFamilyName];
    [self.fontFamsPopoverController dismissPopoverAnimated:YES];
}

- (void)fontFamsController:(FontFamsController *)controller didSelectFeaturesString:(NSString *)fontFeatureName {
    // The user selected a row in the font families features list, so update our
	// CoreTextScrollView with the new font feature.  Note that for simplicity we
	// only set one font feature at a time.
	[coreTextScrollView optionsChange:fontFeatureName];
    [self.fontFamsPopoverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	// Rotation will generate a scrollViewDidScroll - we want to ignore this	
    scrollFeedbackFromOtherControl = YES; 
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// Refresh the core text document layout to reflect the new orientation
	[self.coreTextScrollView relayoutDoc];
}

- (void)viewDidUnload {
    [super viewDidUnload];    
    self.toolbar = nil;
	self.samplesButton = nil;
	self.fontFamsButton = nil;
	self.samplesController = nil;
	self.samplesPopoverController = nil;
	self.fontFamsController = nil;
	self.fontFamsPopoverController = nil;
	self.coreTextScrollView = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {    
    [samplesButton release];
    [fontFamsButton release];
    [toolbar release];
    [super dealloc];
}

#pragma mark -
#pragma mark CoreTextScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // scrollViewDidScroll gets called from multiple reasons (if view is tied to a UIPageControl,
    // when the screen is rotated, when resizing the scrollview) and we are only interested in
    // changing the page when the user actually scrolled the view
    if (scrollFeedbackFromOtherControl) {
        // do nothing - the scroll was initiated from a control or user action that is not user dragging
        return;
    }	
    // Switch the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = coreTextScrollView.frame.size.width;
    int page = floor((coreTextScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	[coreTextScrollView setPage:page];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Switch the page when more than 50% of the previous/next page is visible
	CGFloat pageWidth = coreTextScrollView.frame.size.width;
	int page = floor((coreTextScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[coreTextScrollView setPage:page];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// At the begin of scroll dragging, reset the boolean used when scrolls 
	// originate from something other than user dragging
    scrollFeedbackFromOtherControl = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// At the end of scroll animation, reset the boolean used when scrolls 
	// originate from something other than user dragging
    scrollFeedbackFromOtherControl = YES;
}

// NOTE: Search functionality which was present in an earlier verison of this
// sample was removed to simplify the sample focus.  There will be separate
// samples that demonstrate search functionality, however the following
// commented-out method from the previous version shows one way of searching
// the text using either NSRegularExpression or NSString:rangeOfString.

#ifdef SEARCH_EXAMPLE_FROM_PREVIOUS_VERSION
- (void)finishSearchWithString:(NSString *)searchString {
    
    // Conduct the search. In this case, simply report the search term used.
    [recentSearchesPopoverController dismissPopoverAnimated:YES];
	
	// Clear out any current selection range
	[coreTextScrollView clearSelectionRanges];
	
	// Grab the current document text
	NSString* docString = coreTextScrollView.document.attributedString.string;
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 40000
    NSError *error = nil;
    
	// Use a NSRegularExpression to search the full document text
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchString options:NSRegularExpressionCaseInsensitive error:&error];
    if (regex) {
		// Enumerate over document text using a block, updating found ranges to selection set
        [regex enumerateMatchesInString:docString options:0 range:NSMakeRange(0, [docString length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [coreTextScrollView addSelectionRange:[result range]];
        }];
    }
#else
	
	// NSRegularExpression not available prior to iOS 4, so use standard NSString:rangeOfString searching
    NSRange searchRange = NSMakeRange(0, docString.length);
	while (searchRange.length > 0) {
		// Walk document text looking for search expression, adding found ranges to selection set
		NSRange foundRange = [docString rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSRegularExpressionSearch) range:searchRange];
		if (foundRange.length) {
			[coreTextScrollView addSelectionRange:foundRange];
			searchRange.location = foundRange.location + foundRange.length;
			searchRange.length =  docString.length - searchRange.location;
		}
		else {
			break;
		}
		
	}
#endif
	
    [coreTextScrollView refreshDoc];
	
    [searchBar resignFirstResponder];
}
#endif // SEARCH_EXAMPLE_FROM_PREVIOUS_VERSION

@end
