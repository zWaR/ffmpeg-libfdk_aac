1. Installing MinGW32 and MSYS

   + launch the 'install.cmd' (web installer)
   + wait until the installation is complete
   + launch the 'msys-shell.cmd' to start the MSYS shell

2. Building FFmpeg

   + in the msys shell type './ffmpeg-build.sh'
   + you have to press 'Enter' to build each package
   + watch out for errors during/after each package build
   + after success, ffmpeg is stored in 'msys\local\bin\ffmpeg.exe'