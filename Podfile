
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'icert' do

   pod 'Fabric'#, '~> 1.6.3'
   pod 'Crashlytics'#, '3.7.2'
   #   pod 'Spring'
   #   pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'

  pod 'iCarousel'
  # https://www.cocoacontrols.com/search?q=cover
#  pod 'BeastComponents', :git => 'https://github.com/istsest/BeastComponents.git'

  pod 'EFQRCode'
  pod 'NSDate+TimeAgo'
  pod 'SwiftyUserDefaults'#, '2.2.0'
  pod 'ReSwift'#, '2.0.0'
  pod 'UITextView+Placeholder'#, '~> 1.2'
  pod 'SwiftWebSocket'#, '2.6.3'

  if ['ctslin'].include?(ENV['USER'])
    pod 'SwiftEasyKit', :path => '../SwiftEasyKit'
    else
    pod 'SwiftEasyKit', :git => 'https://github.com/cactis/SwiftEasyKit.git'
  end

  target 'icertTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'icertUITests' do
    inherit! :search_paths
  end

end

