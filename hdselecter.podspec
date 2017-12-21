Pod::Spec.new do |s|
s.name         = 'hdselecter'
s.version      = '0.0.1'
s.summary      = 'Address Selector Like JD'
s.homepage     = 'https://github.com/HugDream/hdselecter.git'
s.license      = 'MIT'
s.authors      = {'HugDream' => '1986530786@qq.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/HugDream/hdselecter.git', :tag => s.version}
s.source_files = 'hdselecter/hdselecter/**/*.{h,m,c}','yimediter/*.{h,m}'
s.resource     = 'hdselecter/hdselecter/*.bundle'
s.requires_arc = true
end
