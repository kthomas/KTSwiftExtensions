Pod::Spec.new do |s|
  s.name = 'KTSwiftExtensions'
  s.version = '0.12.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Swift extensions'

  s.homepage = 'https://github.com/kthomas/KTSwiftExtensions'
  s.authors = { 'Kyle Thomas' => 'k.thomas@unmarkedconsulting.com' }
  s.source = { :git => 'https://github.com/kthomas/KTSwiftExtensions.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'

  s.dependency 'Alamofire'
  s.dependency 'AlamofireObjectMapper'
  s.dependency 'JWTDecode', '~> 1.0'

  s.ios.deployment_target = '9.3'
  s.ios.dependency 'MBProgressHUD', '~> 0.9.1'
end
