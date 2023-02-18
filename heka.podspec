Pod::Spec.new do |s|
    s.name             = 'heka'
    s.version          = '0.1.0'
    s.summary          = 'Integrate fitness data sources into your app.'
    s.homepage         = 'https://www.hekahealth.co'
    s.license          = { :type => 'GNU AGPL', :file => 'LICENSE' }
    s.author           = { 'Heka' => 'contact@hekahealth.co' }
    s.source           = { :git => 'https://github.com/HekaHealth/heka-swift-package.git', :tag => s.version.to_s }
    s.ios.deployment_target = '13.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/heka/**/*'
  end