Pod::Spec.new do |s|
  s.name = 'KTSwiftExtensions'
  s.version = '0.24.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Swift extensions'

  s.homepage = 'https://github.com/kthomas/KTSwiftExtensions'
  s.authors = { 'Kyle Thomas' => 'k.thomas@unmarkedconsulting.com' }
  s.source = { :git => 'https://github.com/kthomas/KTSwiftExtensions.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'

  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'AlamofireObjectMapper', '~> 4.0'
  s.dependency 'ObjectMapper', '~> 2.0'
  s.dependency 'JWTDecode', '~> 2.0'
  s.source_files = 'Source/common/**/*.swift'

  s.ios.deployment_target = '9.3'
  s.ios.source_files = 'Source/ios/**/*.swift'
  s.ios.dependency 'MBProgressHUD', '~> 1.0'

  s.osx.deployment_target = '10.11'
  s.osx.source_files = 'Source/osx/**/*.swift'
end
