//
//  Created by Michael May on 11/09/2013.
//  Copyright (c) 2013 Time Out. All rights reserved.
//

#import "TOUListItemPickerViewController.h"

#import "TOUCityRepository.h"
#import "TOUMeasurementService.h"
#import "TOUCitySwitchDelegate.h"
#import "TOUAPIURLProvider.h"

@interface TOUCitySwitchingViewController : TOUListItemPickerViewController <TOUListItemPickerSelectionDelegate>

-(TOUCityLocale*)cityLocaleForIndex:(NSUInteger)cityNamesWithLaguageIndex;

+(instancetype)citySwitcherViewControllerWithCityRepository:(id <TOUCityRepository>)cityRepository
                                         measurementService:(id<TOUMeasurementService>)measurementService
                                               citySwitcher:(id<TOUCitySwitchDelegate>)citySwitcher
                                                apiProvider:(id<TOUAPIURLProvider>)apiProvider;

@end
