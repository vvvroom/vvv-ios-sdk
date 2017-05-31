# VroomVroomVroom iOS SDK
The VroomVroomVroom iOS SDK allows you to implement a Car Rental company comparison search, and Car Rental booking into your app easily and quickly.

## Requirements

Our SDK is compatible with iOS apps supporting iOS 9.0 and above. It requires Xcode 8.0+ to build the source.

The SDK requires either Swift version 3.0 or Objective C.

## Getting Started

### Cocoapods

The VroomVroomVroom iOS SDK is a CocoaPod written in Swift. CocoaPods is a dependency manager for Cocoa projects. 
You can install it with the following command:

`$ gem install cocoapods`

To integrate VroomVroomVroom into your Xcode project, navigate to the directory that contains your project
and create a new Podfile with `pod init` or open an existing one,
then add `pod 'VVVCarRental'` to the main loop. Make sure to add the line `use_frameworks!` as this is a swift project.

`use_frameworks!`

```
target 'Your Project Name' do
pod 'VVVCarRental'
end
```

Then, run the following command to install the dependency:

`$ pod install`

In swift you simply `import VVVCarRental` in Objective C you `#import <VVVCarRental/VVVCarRental-Swift.h>` to use in your classes.

For Objective-C projects, set the <b>Embedded Content Contains Swift Code</b> flag in your project to <b>Yes</b> (found under <b>Build Options</b> in the <b>Build Settings</b> tab).

### Manually Add Subprojects

You can integrate VroomVroomVroom into your project manually without using a dependency manager.

Drag the `VVV.xcodeproj` project into your project as a subproject

In your project's Build Target, click on the General tab and then under Embedded Binaries click the + button. Choose the VVV.framework in your project.

In swift you simply `import vvv` in Objective C you will `#import <VVV/VVV-Swift.h>` to use in your classes.

For Objective-C projects, set the <b>Embedded Content Contains Swift Code</b> flag in your project to <b>Yes</b> (found under <b>Build Options</b> in the <b>Build Settings</b> tab).

Now build your project and everything should be good to go!

## Initializing the SDK

Init the SDK with your API key, typically done in your APP delegate.

Swift:
```swift
import VVVCarRental

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Initialize the Client with your API Key
         APIClient.setupWith(key: "Your API Key",domain:"Your provided domain")
        return true
    }
```

Objective C:
```objectivec
#import <VVVCarRental/VVVCarRental-swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Initialize the Client with your API Key
     [VVVAPICLient setupWithKey:@"Your API Key" domain:@"Your provided domain"];
    
    return YES;
}
```

## Performing a Simple Search

Perform a search to compare all suppliers at an Airport for a specified dateRange, provides an object containing an array of all results from all suppliers sorted by price.

Swift:
```swift
//Create a global handler variable
let handler = SearchHandler()

 func search() {
        
       //Set the handler delegate to recieve search updates.
        self.handler.delegate = self
        
        //Search at the Brisbane Airport code, at the default date range, as a resident of Australia who is over 30.
        self.handler.search(atAirportCode: "BNE", dateRange: DateRange(), residencyCode: "AU", age: .thirty)
 }

//Implement Delegate methods to recieve all results, or an error if search failed.
 func searchHandlerFinishedSearching(searchResults: SearchResults) {
        print("\(searchResults.all.count) results found")
 }
    
 func searchHandlerFinishedEarly(error: String) {
        print("failed with error \(error)")
 }
 ```

Objective C:

```objectivec
//Create a global handler variable
@property (strong,nonatomic) VVVSearchHandler *handler;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init the handler
    self.handler = [[VVVSearchHandler alloc] init];
    
    //Set the handler delegate to recieve search updates.
    self.handler.delegate = self;
}

-(void)search {

    //Search at the Brisbane Airport code, at the default date range, as a resident of Australia who is over 30.
    [self.handler searchAtAirportCode:@"BNE" dateRange:[[VVVDateRange alloc] init] residencyCode:@"AU" age:VVVAgeGroupThirty];
}

//Implement Delegate methods to recieve all results, or an error if search failed.
-(void)searchHandlerFinishedSearchingWithSearchResults:(VVVSearchResults *)searchResults {
   NSLog(@"%lu results found",(unsigned long)searchResults.all.count);
}

-(void)searchHandlerFinishedEarlyWithError:(NSString *)error {
   NSLog(@"failed with error %@",error);
}
```

## Selecting a Search Result

Selecting a search results provides a pending booking object, which provides more information about the vehicle including extras available and price breakdown.  It is also the first step before creating a booking.

Swift:
```swift
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //These are our results from the search, so we find the result we want, in this case the selected one from a tableview
        let searchResult = self.searchResults.all[indexPath.row]
        
        //Now we use our searchHandler to select the result, and wait for the delegate callbacks.
        self.handler.select(result: searchResult)
    }
    
    //The handler delegate callback if successful will return a pending booking object
    func searchHandlerCreated(pendingBooking: PendingBooking) {
        print("pending booking created for \(pendingBooking.name)")
    }
    
    //The handler delegate callback if failed will return the error that occured
    func searchHandlerFailedPendingBookingWith(error: String) {
        print("failed to create pending booking with error \(error)")
    }

```

Objective C:

```objectivec


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //These are our results from the search, so we find the result we want, in this case the selected one from a tableview
    VVVSearchResult *result = [self.results.all objectAtIndex:indexPath.row];
    
    //Now we use our searchHandler to select the result, and wait for the delegate callbacks.
    [self.handler selectWithResult:result];
   
}

//The handler delegate callback if successful will return a pending booking object
-(void)searchHandlerCreatedWithPendingBooking:(VVVPendingBooking *)pendingBooking {
   NSLog(@"pending booking created for %@",pendingBooking.name);
}

//The handler delegate callback if failed will return the error that occured
-(void)searchHandlerFailedPendingBookingWithError:(NSString *)error {
     NSLog(@"failed to create pending booking with error %@",error);
}

```

## Creating a Rental Booking

After selecting a search result, you can use the PendingBooking object to create a Rental Car booking with Vroom which will in turn create the booking with the Supplier.  First Driver details must be entered in the pending booking, then it can be submitted to create a booking.

Swift:
```swift 

 func createBooking(pendingBooking:PendingBooking) {
        
        //Add the standard entry details for the driver.
        pendingBooking.driver.title = "Mr"
        pendingBooking.driver.firstName = "Tim"
        pendingBooking.driver.lastName = "Cook"
        pendingBooking.driver.email = "tim.cook@apple.com"
        
        //Add the phone number WITHOUT the country code.  The country code is auto populated from the country of residency of the search.
        pendingBooking.driver.phoneNumber = "5555551234"
        
        //Check for any invalid details.
        let invalid = pendingBooking.driver.invalidDetails()
        
        if invalid.count > 0 {
            print("handle invalid detail types provided in the array.")
        } else {
            print("everything is good continue")
        }
        
        //If the booking is at an Airport we can add the flight number, so the supplier can hold the vehicle if the flight is delayed.  The flight number is checked for valid formatting before adding.
        if pendingBooking.add(flightNumber: "QA123") {
            print("flight number is valid and added successfully")
        }
        
        //Once we are happy with the details we can submit our pending booking to create a booking.
        pendingBooking.submit { (booking, error) in
            
            //If we recieved a booking in response the booking was successfully placed, otherwise we will recieve an error.
            if let booking = booking {
                print("booking for \(booking.driver.fullName) created successfully!")
            }
        }
    }
```

Objective C:
```objectivec
-(void)createBooking:(VVVPendingBooking*)pendingBooking {
    
    //Add the standard entry details for the driver.
    [pendingBooking.driver setTitle:@"Mr"];
    [pendingBooking.driver setFirstName:@"Tim"];
    [pendingBooking.driver setLastName:@"Cook"];
    [pendingBooking.driver setEmail:@"tim.cook@apple.com"];
    
    //Add the phone number WITHOUT the country code.  The country code is auto populated from the country of residency of the search.
    [pendingBooking.driver setPhoneNumber:@"5555551234"];

    if ([pendingBooking addWithFlightNumber:@"QA123"]) {
        NSLog(@"flight number is valid and added successfully");
    }
    
    //Once we are happy with the details we can submit our pending booking to create a booking.
    [pendingBooking submitWithCompletion:^(VVVBooking * _Nullable booking, NSString * _Nullable error) {
        
        if (booking != nil) {
            NSLog(@"booking for %@ created successfully!",booking.driver.fullName);
        }
        
    }];
    
}
```

## Cancelling a Booking

You can cancel a booking with a simple function on the Booking object

Swift:
```swift
func cancel(booking:Booking) {
        
        //Cancel the booking via the cancel function on the booking object, resulting in a success boolean or an error message.
        booking.cancel { (success, error) in
            if success {
                print("Booking has been cancelled")
            }
        }
        
}
```

Objective C:
```objectivec

- (void)cancelBooking:(VVVBooking*)booking {
    
    //Cancel the booking via the cancel function on the booking object, resulting in a success boolean or an error message.
    [self.booking cancelWithCompletion:^(BOOL success, NSString * _Nullable error) {
        if (success) {
            NSLog(@"Booking has been cancelled")
        }
    }];
    
}


```

## Find an existing Booking

You can fetch an existing Booking from Vroom if you have the lastname and the SupplierConfirmation of a booking, just call the class method below on the Booking Class.

Swift:
```swift

//Fetch with lastname and confirmation is a class method for the Booking Class, returning a booking if found, otherwise an error message.
 Booking.fetchWith(lastName: "Tester", confirmation: "285487497") { (booking, error) in
    if let booking = booking {
        print("booking found for \(booking.driver.fullName)")
    }
 }
```

Objective C:
```objectivec

//Fetch with lastname and confirmation is a class method for the Booking Class, returning a booking if found, otherwise an error message.
 [VVVBooking fetchWithLastName:@"Tester" confirmation:@"285487497" completion:^(VVVBooking * _Nullable booking, NSString * _Nullable error) {
        
        if (booking != nil) {
            NSLog(@"Booking found for %@",booking.driver.fullName)
        }

}];
```

## Location Autocomplete Search

The VroomVroomVroom contains an autocompleting location search API which searches a combination of popular Car Rental locations and Apple Places.  The initial search provides simple results with a title and subtitle, these can then be selected to provide full location details which can then be attached to a VroomVroomVroom Search Object.

Swift:
```swift
func fetchTopVroomLocations() {
       
        //Passing in nil or an empty string to the search field will fetch all of the VroomVroomVroom top Rental locations.
        LocationManager.shared.locationResultsFor(search: nil) { (locationResults) in
            let location = locationResults.first
            print("The first result is \(location?.title) \(location?.subtitle)")
        }
        
}
    
    func searchFieldDidChange(searchText:String) {
        
        //Passing in a string will provide location results based on the string, you can call this function in quick succession without any issues eg. Attached it to a UITextfield delegate method.
        LocationManager.shared.locationResultsFor(search: searchText) { (locationResults) in
            let location = locationResults.first
            print("The first result is \(location?.title) \(location?.subtitle)")
        }
        
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Once we find the location we wanted to search for we can fetch the full location details.
        let location = self.locationResults[indexPath.row]
        
        //Use the location manager to select the location and return the full details.
        LocationManager.shared.selectLocation(result: location) { (fullLocationDetails) in
            print("Now we have all the details to pass onto a rental car search.")
        }
    }
```

Objective C:
```objectivec

-(void)fetchVroomTopLocations {
    
    //Passing in nil or an empty string to the search field will fetch all of the VroomVroomVroom top Rental locations.
    [[VVVLocationManager shared] locationResultsForSearch:nil completion:^(NSArray<id<VVVLocationSearchResult>> * _Nonnull locationSearchResults) {
        
        id<VVVLocationSearchResult> firstLocationResult = locationSearchResults[0];
        NSLog(@"The first result is %@ %@",[firstLocationResult title],[firstLocationResult subtitle]);
    }];
    
}

-(void)searchFieldDidChange:(NSString*)searchText {
    
    //Passing in a string will provide location results based on the string, you can call this function in quick succession without any issues eg. Attached it to a UITextfield delegate method.
    [[VVVLocationManager shared] locationResultsForSearch:searchText completion:^(NSArray<id<VVVLocationSearchResult>> * _Nonnull locationSearchResults) {
        
        id<VVVLocationSearchResult> firstLocationResult = locationSearchResults[0];
        NSLog(@"The first result is %@ %@",[firstLocationResult title],[firstLocationResult subtitle]);
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Once we find the location we wanted to search for we can fetch the full location details.
    id<VVVLocationSearchResult> location = locationSearchResults[indexPath.row];
    
    //Use the location manager to select the location and return the full details.
    [VVVLocationManager shared] selectLocationWithResult:location completion:^(VVVLocation * _Nullable fullLocationDetails) {
        NSLog(@"Now we have all the details to pass onto a rental car search.")
    }
   
}

```
