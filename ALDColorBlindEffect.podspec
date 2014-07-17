Pod::Spec.new do |s|
  s.name         = "ALDColorBlindEffect"
  s.version      = "1.0.4"
  s.summary      = "See how people with color-blindness experience your App."

  s.description  = <<-DESC
                   
                   Using this very simple class, you can quickly get an idea of what your color-blind users will experience when they use your App. This is achieved by converting the colors and acuity of your App in real-time.
                   
                   DESC

  s.homepage     = "https://github.com/andydrizen/ALDColorBlindEffect"
  s.license      = { :type => 'BSD', :file => 'LICENCE' }
  s.author       = { "Andy Drizen" => "andydrizen@gmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/andydrizen/ALDColorBlindEffect.git", :tag => "#{s.version}" }
  s.source_files  = 'ALDColorBlindEffect.{h,m}'
  s.requires_arc = true
end
