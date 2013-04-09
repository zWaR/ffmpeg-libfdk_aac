http://ffmpeg-builder.googlecode.com

1. Installing MinGW32/MSYS and building ffmpeg

   + launch the 'install.cmd' (web installer)
   + after ~15 minutes the installation is complete
   + the 'ffmpeg-build.sh' script is executed automatically
   + after ~30 minutes the build processes should be finished
   + the executable can be found in 'msys\local\bin\ffmpeg.exe'
   

2. Re-building ffmpeg

   + modify the script 'source\ffmpeg-build.sh' depending on your needs (i.e. x264 8bit instead of 10bit, ...)
   + launch the 'msys-shell.cmd' to start the MSYS shell
   + in the MSYS shell type 'ffmpeg-build.sh'
   + watch out for errors during/after each package build
   + after ~30 minutes the build processes should be finished
   + the executable can be found in 'msys\local\bin\ffmpeg.exe'