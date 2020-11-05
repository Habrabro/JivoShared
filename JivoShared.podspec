Pod::Spec.new do |spec|
  spec.name         = 'JivoShared'
  spec.version      = '1.0.15'
  spec.license      = { :type => 'MIT', :file => "LICENSE" }
  spec.homepage     = 'https://github.com/habrabro'
  spec.authors      = { 'Anton Karpushko' => 'karpushko@jivosite.com' }
  spec.summary      = 'JivoShared.'
  spec.requires_arc = true

  spec.ios.deployment_target  = '10.0'
  spec.swift_version = "5.0"
  spec.platform = :ios, "10.0"

  spec.source       = { :git => 'https://github.com/habrabro/jivoshared.git', :tag => "1.0.15" }
  # spec.public_header_files = "JivoShared.framework/Headers/*.h"
  spec.source_files = "**/*.*"
  # spec.vendored_frameworks = "JivoShared.framework"

  spec.framework    = 'SystemConfiguration'

  spec.dependency     'Realm'
  spec.dependency     'RealmSwift'
  spec.dependency     'JMTimelineKit'
  spec.dependency     'JMRepicKit'
  spec.dependency     'JMMarkdownKit'
  spec.dependency     'JMOnetimeCalculator'
  spec.dependency     'JMDesignKit'
  spec.dependency     'JMScalableView'
  spec.dependency     'JMCodingKit'

  spec.exclude_files = [
    'JivoShared/Info.plist'
  ]
end