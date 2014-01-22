//
//  Created by Michael May on 11/09/2013.
//  Copyright (c) 2013 Time Out. All rights reserved.
//

#import "NSObjectNilCheckWithException.h"
#import "TOUCitySwitchingViewController.h"
#import "UIFont+TimeOut.h"
#import "TOUAppAppearance.h"
#import "TOUCity.h"
#import "TOUOmnitureMeasurementService.h"

__obfuscated const NSString *myPrivateString = @"myTestAPIString";

@interface TOUCitySwitchingViewController ()
@property (nonatomic, strong) id <TOUCityRepository> cityRepository;
@property (nonatomic, strong) id<TOUMeasurementService> measurementService;
@property (nonatomic, strong) id<TOUCitySwitchDelegate> citySwitcher;
@property (nonatomic, strong) id<TOUAPIURLProvider> apiProvider;
@end

@implementation TOUCitySwitchingViewController

#pragma mark - utility

-(TOUCityLocale*)cityLocaleForIndex:(NSUInteger)cityNamesWithLaguageIndex
{
    __block NSInteger cityLocaleCounter = 0;
    __block TOUCityLocale *cityLocale = nil;
    
    [self.cityRepository enumerateItemsUsingBlock:^(TOUCity *city, NSUInteger cityIndex, BOOL *stopCity) {
        [[city locales] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            if(cityLocaleCounter == cityNamesWithLaguageIndex) {
                cityLocale = (TOUCityLocale*)object;
                
                *stop = YES;
                *stopCity = YES;
            }
            
            cityLocaleCounter++;
        }];
    }];
    
    return cityLocale;
}

-(NSInteger)indexOfCityLocale:(TOUCityLocale*)cityLocale
{
    __block NSInteger cityIndexCounter = 0;
    __block BOOL found = NO;
    
    [self.cityRepository enumerateItemsUsingBlock:^(TOUCity *city, NSUInteger cityIndex, BOOL *stopCity) {
        [[city locales] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            if(cityLocale == (TOUCityLocale*)object) {
                *stop = YES;
                *stopCity = YES;
                found = YES;
            } else {
                cityIndexCounter++;
            }
        }];
    }];
    
    return (found) ? cityIndexCounter : -1;
}

-(NSArray*)cityNamesWithLaguageListFromCityLocales
{
    NSMutableArray *cityNamesWithLanguageList = [NSMutableArray array];
    
    [self.cityRepository enumerateItemsUsingBlock:^(TOUCity *city, NSUInteger cityIndex, BOOL *stopCity) {
        [[city locales] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
            TOUCityLocale *cityLocale = (TOUCityLocale*)object;
            
            NSAttributedString *cityWithLocale =[ self combineCityName:[self cityNameAttributedString:[cityLocale cityName]]
                                                        withCityLocale:[self cityLocaleAttributedString:[cityLocale languageName]]];
            
            [cityNamesWithLanguageList addObject:cityWithLocale];
        }];
    }];
    
    return cityNamesWithLanguageList;
}

-(NSMutableAttributedString *)cityNameAttributedString:(NSString *)cityName
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributesForString = @{NSFontAttributeName:[UIFont timeOutFontCategory4],
                                          NSParagraphStyleAttributeName:paragraphStyle,
                                          NSForegroundColorAttributeName:[TOUAppAppearance timeOutBackgroundAndBodyCopyColor]};
    
    NSMutableAttributedString *cityNameAttributedString  = [[NSMutableAttributedString alloc] initWithString:cityName
                                                                                                  attributes:attributesForString];
    
    return cityNameAttributedString;
}

-(NSMutableAttributedString *)cityLocaleAttributedString:(NSString *)cityLocale
{
    NSString *addBracketAndSpaceToCityLocale =[NSString stringWithFormat:@" (%@)",cityLocale];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributesForString = @{NSFontAttributeName:[UIFont timeOutFontCategory12],
                                          NSParagraphStyleAttributeName:paragraphStyle,
                                          NSForegroundColorAttributeName:[TOUAppAppearance timeOutBackgroundAndBodyCopyColor]};
    
    NSMutableAttributedString *cityNameAttributedString  = [[NSMutableAttributedString alloc] initWithString:addBracketAndSpaceToCityLocale
                                                                                                  attributes:attributesForString];
    
    return cityNameAttributedString;
}

-(NSMutableAttributedString *)combineCityName:(NSMutableAttributedString *)cityNameAttributedString
                               withCityLocale:(NSMutableAttributedString *) cityLocale
{
    NSMutableAttributedString * combineString= cityNameAttributedString;
    [combineString appendAttributedString:cityLocale];
    return combineString;
}



-(void)updateCitiesListFromRepository
{
    NSArray *cityNames = [self cityNamesWithLaguageListFromCityLocales];
    NSInteger currentlySelectedCityIndex = ([cityNames count] > 0) ? 0 : -1;
    
    TOUCityLocale *currentCityLocale = [[self citySwitcher] currentCityLocale];
    if(currentCityLocale) {
        currentlySelectedCityIndex = [self indexOfCityLocale:currentCityLocale];
    }
    
    [super reloadWithTitles:cityNames selectedItemIndex:currentlySelectedCityIndex];
}

- (IBAction)didReceiveTouchUpInsideShowCityButton:(id)sender
{
    [super didReceiveTouchUpInsideShowCityButton:sender];
   
    TOUCityLocale *cityLocaleToSwitchTo = [self cityLocaleForIndex:[super currentlySelectedItemIndex]];
    NSString *trackingString =[NSString stringWithFormat:@"choose %@ - %@",cityLocaleToSwitchTo.cityName,cityLocaleToSwitchTo.languageName];
    
    [self.measurementService logEventDidOccur:@""
                                         type:TOULinkTypeDefault
                               viewController:self
                                        title:trackingString
                                   properties:nil];

}

#pragma mark - City Repository Update Notifications

-(void)updateCitiesRepositoryDidSucceed:(NSNotification *)notification
{
    [self updateCitiesListFromRepository];
}

-(void)updateCitiesRepositoryDidFail:(NSNotification *)notification
{
    NSError *error = (NSError *)[notification object];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"sorry_error_message", @"iPhone", @"")
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedStringFromTable(@"ok_text", @"iPhone", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark -

-(void)updateCities
{
    [self.cityRepository update];
}

-(void)startObservingCitiesUpdates
{
    [self.cityRepository addSuccessObserver:self selector:@selector(updateCitiesRepositoryDidSucceed:)];
    [self.cityRepository addFailureObserver:self selector:@selector(updateCitiesRepositoryDidFail:)];
}

-(void)stopObservingCitiesUpdates
{
    [self.cityRepository removeFailureObserver:self];
    [self.cityRepository removeSuccessObserver:self];
}

#pragma mark - TOUListItemPickerSelectionDelegate

-(void)listItemPickerViewController:(TOUListItemPickerViewController *)citySwitcherViewController selectedDifferentCityAtIndex:(NSInteger)cityIndex
{
    TOUCityLocale *cityLocaleToSwitchTo = [self cityLocaleForIndex:cityIndex];
    
    [[self citySwitcher] switchApplicationToCityLocale:cityLocaleToSwitchTo];
}

-(void)listItemPickerViewControllerDidContinueWithoutChange:(TOUListItemPickerViewController *)citySwitcherViewController
{
    
}

#pragma mark -

- (void)updateEnableStateForConfirmSelectionButton
{
    [super updateEnableStateForConfirmSelectionButton];
    
    NSString *title;
    
    if([super currentlySelectedItemIndex] == [super initiallySelectedItemIndex]) {
        title = NSLocalizedStringFromTable(@"city-switcher-button-intial-title", @"iPhone", @"");
    }
    else {
        TOUCityLocale *cityLocaleToSwitchTo = [self cityLocaleForIndex:[super currentlySelectedItemIndex]];
        
        title = [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"city-switcher-button-title-after-city-select", @"iPhone", @""), cityLocaleToSwitchTo.cityName];
    }
    
    [super setShowButtonTitle:title];
}

#pragma mark -

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUp];
    
    if([[self cityRepository] hasItems]) {
        [self updateCitiesListFromRepository];
    } else {
        [self updateCities];
    }
    
    [[self measurementService] logViewControllerWasShown:self];
}

-(void) setUp
{
    [self setTitleLabel:NSLocalizedStringFromTable(@"city-switcher-title-text", @"iPhone", @"")];
    [self setIntroductoryText:NSLocalizedStringFromTable(@"city-switcher-introduction-text", @"iPhone", @"")];
    [self setShowButtonTitle:NSLocalizedStringFromTable(@"city-switcher-button-intial-title", @"iPhone", @"")];
    
}
#pragma mark -

-(id)initWithCityRepository:(id<TOUCityRepository>)cityRepository
         measurementService:(id<TOUMeasurementService>)measurementService
               citySwitcher:(id<TOUCitySwitchDelegate>)citySwitcher
                apiProvider:(id<TOUAPIURLProvider>)apiProvider
{
    self = [super init];
    
    checkIfNSObjectIsNilAndException(self);
    
    _cityRepository = cityRepository;
    _measurementService = measurementService;
    _citySwitcher = citySwitcher;
    _apiProvider = apiProvider;
    
    [super setTitle:NSLocalizedStringFromTable(@"city_switcher", @"iPhone", @"Menu and controller title for switch city")];
    
    [super setDelegate:self];
    
    [self startObservingCitiesUpdates];
    
    return self;
}

-(void)dealloc
{
    [self stopObservingCitiesUpdates];
}

+(instancetype)citySwitcherViewControllerWithCityRepository:(id <TOUCityRepository>)cityRepository
                                         measurementService:(id<TOUMeasurementService>)measurementService
                                               citySwitcher:(id<TOUCitySwitchDelegate>)citySwitcher
                                                apiProvider:(id<TOUAPIURLProvider>)apiProvider
{
    return [[self alloc] initWithCityRepository:(id <TOUCityRepository>)cityRepository
                             measurementService:(id<TOUMeasurementService>)measurementService
                                   citySwitcher:(id<TOUCitySwitchDelegate>)citySwitcher
                                    apiProvider:(id<TOUAPIURLProvider>)apiProvider];
}

@end
