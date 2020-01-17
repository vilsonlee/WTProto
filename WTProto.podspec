#
#  Be sure to run `pod spec lint WTProto.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "WTProto"
  spec.version      = "1.0.5"
  spec.summary      = "WTProtocol re-encapsulates the XMPP communication protocol based on XMPPFramework. ."
  spec.description  = <<-DESC
  WTProtocol re-encapsulates the XMPP communicatio protcol based on XMPPFramework.
  WTProto is the most core class that manager the alnl the XMPP communication.
                   DESC

  spec.homepage     = "https://github.com/vilsonlee/WTProto"
  spec.author       = { "vilson" => "vilson.li@gzemt.com" }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/vilsonlee/WTProto.git", :tag => "#{spec.version}" }

  spec.source_files  = ['WTProtocal/WTProto/ThirdParty/**/*.{h,m}',
                        'WTProtocal/WTProto/MUC/**/*.{h,m}', 
                        'WTProtocal/WTProto/Utils/**/*.{h,m}',
                        'WTProtocal/WTProto/DataCenter/**/*.{h,m}', 
                        'WTProtocal/WTProto/Connection/**/*.{h,m}', 
                        'WTProtocal/WTProto/Tracker/**/*.{h,m}', 
                        'WTProtocal/WTProto/Roster/**/*.{h,m}', 
                        'WTProtocal/WTProto/stream/**/*.{h,m}', 
                        'WTProtocal/WTProto/message/**/*.{h,m}', 
                        'WTProtocal/WTProto/Interface/**/*.{h,m}']



  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "WTXMPPFramework"
  spec.dependency "AFNetworking"
  spec.dependency "SignalProtocolC"
  spec.dependency "SignalProtocolObjC"

end
