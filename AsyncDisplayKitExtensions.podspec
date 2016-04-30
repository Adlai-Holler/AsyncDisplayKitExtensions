Pod::Spec.new do |spec|
  spec.name = 'AsyncDisplayKitExtensions'
  spec.version = '1.0.0'
  spec.summary = "Swift syntactic sugar for AsyncDisplayKit."
  spec.homepage = 'https://github.com/Tripstr/AsyncDisplayKitExtensions'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = {
    'Adlai Holler' => 'adlai@tripstr.com',
  }
  spec.source = { :git => 'https://github.com/Tripstr/AsyncDisplayKitExtensions', :tag => "v#{spec.version}" }
  spec.source_files = 'AsyncDisplayKitExtensions/**/*.{h,swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  #spec.osx.deployment_target = '10.9'

  spec.dependency 'AsyncDisplayKit', '~> 1.9.7.2'
  spec.framework = "Foundation"
end
