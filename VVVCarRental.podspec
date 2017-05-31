Pod::Spec.new do |s|
  s.name         = "VVVCarRental"
  s.version      = "0.5.0"
  s.summary      = "The official VroomVroomVroom SDK to compare and book rental cars,"
  s.description  = "The VroomVroomVroom iOS SDK allows you to implement a Car Rental company comparision search, and Car Rental booking into your app easily and quickly."
  s.homepage     = "https://vroomvroomvroom.com.au"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "James Swiney" => "james.swiney@vroomvroomvroom.com.au" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/vvvroom/vvv-ios-sdk.git", :tag => "0.5.0" }
  s.source_files  = "source/VVV/*"
  s.resources = "resources/*"
end
