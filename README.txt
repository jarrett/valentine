The goal of this project is to make valentine.rb run correctly.
It is broken right now and in need of some love. When it runs successfully, it'll tell you.

You will need the RMagick gem to run this. RMagick, in turn, depends on ImageMagick,
a Unix imaging library. On a Mac, the best procedure to get those two up
and running is the following:

1. Install MacPorts
2. Install the ImageMagick MacPort ('sudo port install tiff -macosx imagemagick +q8 +gs +wmf')
3. Install the RMagick gem ('gem install rmagick')