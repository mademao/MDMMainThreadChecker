Pod::Spec.new do |s|
    s.name         = 'MDMMainThreadChecker'
    s.version      = '1.0.0'
    s.summary      = '监测主线程UI是否在子线程调用的框架'
    s.homepage     = 'https://github.com/mademao/MDMMainThreadChecker'
    s.license      = 'GPL'
    s.authors      = {'mademao' => 'ismademao@gmail.com'}
    s.platform     = :ios, '9.0'
    s.source       = {:git => 'https://github.com/mademao/MDMMainThreadChecker.git', :tag => s.version}
    s.source_files = 'MDMMainThreadChecker/**/*.{h,m}'
    s.requires_arc = true
end
