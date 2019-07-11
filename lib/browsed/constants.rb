module Browsed
  class Constants
    
    BROWSERS  =   [
      :chrome,
      :firefox,
      :phantomjs
    ]
    
    RESOLUTIONS = {
      desktop: [
        [1920, 1080], #17%
        [1366, 768], #35%
        [1280, 1024], #5%
        [1280, 800], #4%
        [1024, 768] #3%
      ],
    
      phone:
      {
        '4'   =>  [320, 480],
        '5'   =>  [320, 568],
        '6'   =>  [375, 667],
        '6+'  =>  [414, 736]
      },
    
      tablet:
      {
        'standard'  =>  [1024, 768],
        'retina'    =>  [2048, 1536]
      }
    }
        
  end
end
